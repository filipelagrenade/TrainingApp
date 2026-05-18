"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Bell, CheckCheck } from "lucide-react";
import { useState } from "react";

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
import { cn } from "@/lib/utils";

export const NotificationBell = () => {
  const [open, setOpen] = useState(false);
  const queryClient = useQueryClient();

  const countQuery = useQuery({
    queryKey: ["notification-count"],
    queryFn: apiClient.getUnreadNotificationCount,
    refetchInterval: 30_000,
  });

  const notificationsQuery = useQuery({
    queryKey: ["notifications"],
    queryFn: apiClient.getNotifications,
    enabled: open,
  });

  const markReadMutation = useMutation({
    mutationFn: apiClient.markNotificationRead,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["notifications"] });
      await queryClient.invalidateQueries({ queryKey: ["notification-count"] });
    },
  });

  const markAllReadMutation = useMutation({
    mutationFn: apiClient.markAllNotificationsRead,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["notifications"] });
      await queryClient.invalidateQueries({ queryKey: ["notification-count"] });
    },
  });

  const unreadCount = countQuery.data?.count ?? 0;

  return (
    <>
      <button
        type="button"
        onClick={() => setOpen(true)}
        className="relative inline-flex items-center justify-center rounded-md p-2 text-ink-muted transition-colors hover:text-ink"
      >
        <Bell className="h-5 w-5" />
        {unreadCount > 0 ? (
          <span className="absolute -right-0.5 -top-0.5 flex h-4 min-w-4 items-center justify-center rounded-full bg-red-500 px-1 font-mono text-[10px] font-bold text-white">
            {unreadCount > 9 ? "9+" : unreadCount}
          </span>
        ) : null}
      </button>

      <Sheet open={open} onOpenChange={setOpen}>
        <SheetContent side="bottom" className="max-h-[80vh] overflow-y-auto">
          <SheetHeader>
            <div className="flex items-center justify-between">
              <SheetTitle>Notifications</SheetTitle>
              {unreadCount > 0 ? (
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() => markAllReadMutation.mutate()}
                  disabled={markAllReadMutation.isPending}
                >
                  <CheckCheck className="mr-1.5 h-3.5 w-3.5" />
                  Mark all read
                </Button>
              ) : null}
            </div>
            <SheetDescription>Recent activity</SheetDescription>
          </SheetHeader>

          <div className="space-y-2 px-6 pb-6 pt-4">
            {notificationsQuery.isLoading ? (
              <div className="space-y-2">
                {Array.from({ length: 3 }).map((_, i) => (
                  <Skeleton key={i} className="h-16" />
                ))}
              </div>
            ) : notificationsQuery.data?.length ? (
              notificationsQuery.data.map((notification) => (
                <button
                  key={notification.id}
                  type="button"
                  onClick={() => {
                    if (!notification.read) {
                      markReadMutation.mutate(notification.id);
                    }
                  }}
                  className={cn(
                    "w-full rounded-md border p-3 text-left transition-colors",
                    notification.read
                      ? "border-rule bg-surface"
                      : "border-ink/10 bg-surface-raised",
                  )}
                >
                  <div className="flex items-start justify-between gap-2">
                    <p className={cn("text-sm", notification.read ? "text-ink-muted" : "font-semibold text-ink")}>
                      {notification.title}
                    </p>
                    {!notification.read ? (
                      <span className="mt-1 h-2 w-2 shrink-0 rounded-full bg-red-500" />
                    ) : null}
                  </div>
                  {notification.body ? (
                    <p className="mt-0.5 text-xs text-ink-muted">{notification.body}</p>
                  ) : null}
                  <p className="mt-1 text-[10px] text-ink-muted">
                    {new Date(notification.createdAt).toLocaleString()}
                  </p>
                </button>
              ))
            ) : (
              <div className="rounded-md border border-dashed border-rule p-6 text-center text-sm text-ink-muted">
                No notifications yet.
              </div>
            )}
          </div>
        </SheetContent>
      </Sheet>
    </>
  );
};
