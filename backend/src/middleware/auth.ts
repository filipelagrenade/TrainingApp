import { createHash } from "node:crypto";
import type { NextFunction, Request, Response } from "express";

import { env } from "../config/env";
import { AppError } from "../lib/errors";
import { prisma } from "../lib/prisma";

const hashToken = (token: string): string =>
  createHash("sha256").update(token).digest("hex");

export const authMiddleware = async (
  request: Request,
  _response: Response,
  next: NextFunction,
): Promise<void> => {
  const token = request.cookies?.[env.SESSION_COOKIE_NAME];

  if (!token) {
    next();
    return;
  }

  const session = await prisma.session.findUnique({
    where: {
      tokenHash: hashToken(token),
    },
    include: {
      user: true,
    },
  });

  if (!session || session.expiresAt < new Date()) {
    next();
    return;
  }

  request.currentUser = session.user;
  request.sessionToken = token;
  next();
};

export const requireAuth = (request: Request, _response: Response, next: NextFunction): void => {
  if (!request.currentUser) {
    next(new AppError(401, "UNAUTHORIZED", "You need to sign in first"));
    return;
  }

  next();
};
