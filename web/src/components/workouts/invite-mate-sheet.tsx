"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Send } from "lucide-react";
import { toast } from "sonner";

import { Button } from "@/components/ui/button";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet";
import { Skeleton } from "@/components/ui/skeleton";
import { apiClient } from "@/lib/api-client";

export const InviteMateSheet = ({
  open,
  onOpenChange,
  sessionId,
  workoutTitle,
  programWorkoutId,
  templateId,
}: {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  sessionId: string | null;
  workoutTitle: string;
  programWorkoutId?: string | null;
  templateId?: string | null;
}) => {
  const queryClient = useQueryClient();

  const followingQuery = useQuery({
    queryKey: ["following"],
    queryFn: apiClient.getFollowing,
    enabled: open,
  });

  const inviteMutation = useMutation({
    mutationFn: (toUserId: string) =>
      apiClient.createWorkoutInvite({
        toUserId,
        fromSessionId: sessionId ?? undefined,
        programWorkoutId: programWorkoutId ?? undefined,
        templateId: templateId ?? undefined,
        workoutTitle,
      }),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["notification-count"] });
      toast.success("Invite sent!");
      onOpenChange(false);
    },
    onError: (error: Error) => toast.error(error.message),
  });

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent side="bottom" className="max-h-[70vh] overflow-y-auto">
        <SheetHeader>
          <SheetTitle>Invite a mate</SheetTitle>
          <SheetDescription>Pick someone to train with you on &quot;{workoutTitle}&quot;</SheetDescription>
        </SheetHeader>

        <div className="space-y-2 px-6 pb-6 pt-4">
          {followingQuery.isLoading ? (
            <div className="space-y-2">
              {Array.from({ length: 3 }).map((_, i) => (
                <Skeleton key={i} className="h-14" />
              ))}
            </div>
          ) : followingQuery.data?.length ? (
            followingQuery.data.map((user) => (
              <div
                key={user.id}
                className="flex items-center justify-between gap-3 rounded-md border border-rule bg-surface p-3"
              >
                <div>
                  <p className="text-sm font-semibold text-ink">{user.displayName}</p>
                  <p className="text-xs text-ink-muted">Level {user.level}</p>
                </div>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => inviteMutation.mutate(user.id)}
                  disabled={inviteMutation.isPending}
                >
                  <Send className="mr-1.5 h-3.5 w-3.5" />
                  Invite
                </Button>
              </div>
            ))
          ) : (
            <div className="rounded-md border border-dashed border-rule p-6 text-center text-sm text-ink-muted">
              Follow people to invite them to train with you.
            </div>
          )}
        </div>
      </SheetContent>
    </Sheet>
  );
};
