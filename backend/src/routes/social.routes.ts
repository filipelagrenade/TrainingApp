import { Router } from "express";
import { z } from "zod";

import { sendSuccess } from "../lib/http";
import { requireAuth } from "../middleware/auth";
import {
  followUser,
  getFeed,
  getLeaderboard,
  joinChallenge,
  listFollowing,
  listChallenges,
  searchUsers,
  unfollowUser,
} from "../services/social.service";

const socialRouter = Router();

socialRouter.use(requireAuth);

socialRouter.get("/leaderboard", async (_request, response, next) => {
  try {
    const leaderboard = await getLeaderboard();
    sendSuccess(response, leaderboard);
  } catch (error) {
    next(error);
  }
});

socialRouter.get("/feed", async (request, response, next) => {
  try {
    const feed = await getFeed(request.currentUser!.id);
    sendSuccess(response, feed);
  } catch (error) {
    next(error);
  }
});

socialRouter.get("/challenges", async (request, response, next) => {
  try {
    const challenges = await listChallenges(request.currentUser!.id);
    sendSuccess(response, challenges);
  } catch (error) {
    next(error);
  }
});

socialRouter.get("/following", async (request, response, next) => {
  try {
    const users = await listFollowing(request.currentUser!.id);
    sendSuccess(response, users);
  } catch (error) {
    next(error);
  }
});

socialRouter.post("/challenges/:challengeId/join", async (request, response, next) => {
  try {
    const participant = await joinChallenge(request.currentUser!.id, request.params.challengeId);
    sendSuccess(response, participant);
  } catch (error) {
    next(error);
  }
});

socialRouter.get("/search", async (request, response, next) => {
  try {
    const query = z.string().min(1).parse(request.query.q);
    const users = await searchUsers(request.currentUser!.id, query);
    sendSuccess(response, users);
  } catch (error) {
    next(error);
  }
});

socialRouter.post("/follow/:userId", async (request, response, next) => {
  try {
    const follow = await followUser(request.currentUser!.id, request.params.userId);
    sendSuccess(response, follow, 201);
  } catch (error) {
    next(error);
  }
});

socialRouter.delete("/follow/:userId", async (request, response, next) => {
  try {
    await unfollowUser(request.currentUser!.id, request.params.userId);
    sendSuccess(response, { ok: true });
  } catch (error) {
    next(error);
  }
});

export { socialRouter };
