import { AppError } from "../lib/errors";
import { prisma } from "../lib/prisma";
import { getChallengeShowcase } from "./challenge.service";

export const getMyProfile = async (userId: string) => {
  const [user, showcase] = await Promise.all([
    prisma.user.findUniqueOrThrow({
      where: { id: userId },
    }),
    getChallengeShowcase(userId),
  ]);

  return {
    user,
    showcase,
    editable: true,
  };
};

export const getPublicProfile = async (viewerId: string, profileUserId: string) => {
  const [user, showcase, following] = await Promise.all([
    prisma.user.findUnique({
      where: { id: profileUserId },
    }),
    getChallengeShowcase(profileUserId),
    prisma.follow.findUnique({
      where: {
        followerId_followingId: {
          followerId: viewerId,
          followingId: profileUserId,
        },
      },
    }),
  ]);

  if (!user) {
    throw new AppError(404, "PROFILE_NOT_FOUND", "That profile could not be found.");
  }

  return {
    user,
    showcase,
    editable: viewerId === profileUserId,
    isFollowing: Boolean(following),
  };
};

export const updateProfileShowcase = async (
  userId: string,
  input: {
    selectedTitleKey?: string | null;
    selectedBadgeKey?: string | null;
  },
) => {
  const showcase = await getChallengeShowcase(userId);

  if (input.selectedTitleKey) {
    const foundTitle = showcase.unlockedTitles.find((title) => title.key === input.selectedTitleKey);
    if (!foundTitle) {
      throw new AppError(400, "TITLE_NOT_UNLOCKED", "That title has not been unlocked yet.");
    }
  }

  if (input.selectedBadgeKey) {
    const foundBadge = showcase.unlockedBadges.find((badge) => badge.key === input.selectedBadgeKey);
    if (!foundBadge) {
      throw new AppError(400, "BADGE_NOT_UNLOCKED", "That badge has not been unlocked yet.");
    }
  }

  const selectedTitle =
    input.selectedTitleKey === undefined
      ? undefined
      : input.selectedTitleKey === null
        ? { key: null, label: null }
        : showcase.unlockedTitles.find((title) => title.key === input.selectedTitleKey) ?? null;

  const selectedBadge =
    input.selectedBadgeKey === undefined
      ? undefined
      : input.selectedBadgeKey === null
        ? { key: null, label: null }
        : showcase.unlockedBadges.find((badge) => badge.key === input.selectedBadgeKey) ?? null;

  return prisma.user.update({
    where: { id: userId },
    data: {
      selectedTitleKey: selectedTitle?.key,
      selectedTitleLabel: selectedTitle?.label,
      selectedBadgeKey: selectedBadge?.key,
      selectedBadgeLabel: selectedBadge?.label,
      selectedBadgeIconKey:
        selectedBadge && "iconKey" in selectedBadge ? selectedBadge.iconKey : null,
    },
  });
};
