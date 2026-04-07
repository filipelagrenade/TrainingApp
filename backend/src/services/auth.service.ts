import { createHash, randomBytes } from "node:crypto";

import { AuthProvider, type Session, type User } from "@prisma/client";
import bcrypt from "bcryptjs";

import { env } from "../config/env";
import { AppError } from "../lib/errors";
import { prisma } from "../lib/prisma";

const SESSION_TTL_MS = env.SESSION_TTL_DAYS * 24 * 60 * 60 * 1000;

export const createSessionToken = (): string => randomBytes(32).toString("hex");

const hashToken = (token: string): string => createHash("sha256").update(token).digest("hex");

export const registerUser = async (input: {
  email: string;
  password: string;
  displayName: string;
  userAgent?: string;
}): Promise<{ user: User; session: Session; token: string }> => {
  const existing = await prisma.user.findUnique({
    where: { email: input.email.toLowerCase() },
  });

  if (existing) {
    throw new AppError(409, "EMAIL_IN_USE", "That email address is already registered.");
  }

  const passwordHash = await bcrypt.hash(input.password, 10);
  const token = createSessionToken();
  const tokenHash = hashToken(token);

  const result = await prisma.$transaction(async (transaction) => {
    const user = await transaction.user.create({
      data: {
        email: input.email.toLowerCase(),
        displayName: input.displayName,
      },
    });

    await transaction.authIdentity.create({
      data: {
        userId: user.id,
        provider: AuthProvider.EMAIL,
        providerSubject: user.email,
        passwordHash,
      },
    });

    const session = await transaction.session.create({
      data: {
        userId: user.id,
        tokenHash,
        userAgent: input.userAgent,
        expiresAt: new Date(Date.now() + SESSION_TTL_MS),
      },
    });

    return { user, session };
  });

  return { ...result, token };
};

export const loginUser = async (input: {
  email: string;
  password: string;
  userAgent?: string;
}): Promise<{ user: User; session: Session; token: string }> => {
  const identity = await prisma.authIdentity.findUnique({
    where: {
      provider_providerSubject: {
        provider: AuthProvider.EMAIL,
        providerSubject: input.email.toLowerCase(),
      },
    },
    include: {
      user: true,
    },
  });

  if (!identity?.passwordHash) {
    throw new AppError(401, "INVALID_CREDENTIALS", "Incorrect email or password.");
  }

  const passwordMatches = await bcrypt.compare(input.password, identity.passwordHash);

  if (!passwordMatches) {
    throw new AppError(401, "INVALID_CREDENTIALS", "Incorrect email or password.");
  }

  const token = createSessionToken();
  const session = await prisma.session.create({
    data: {
      userId: identity.userId,
      tokenHash: hashToken(token),
      userAgent: input.userAgent,
      expiresAt: new Date(Date.now() + SESSION_TTL_MS),
    },
  });

  return {
    user: identity.user,
    session,
    token,
  };
};

export const logoutUser = async (token: string | undefined): Promise<void> => {
  if (!token) {
    return;
  }

  await prisma.session.deleteMany({
    where: {
      tokenHash: hashToken(token),
    },
  });
};
