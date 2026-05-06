"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { toast } from "sonner";

import { AuthCard } from "@/components/auth/auth-card";
import { BackButton } from "@/components/ui/back-button";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Skeleton } from "@/components/ui/skeleton";
import { ThemeSwitcher } from "@/components/ui/theme-switcher";
import { apiClient } from "@/lib/api-client";

const REST_DEFAULTS = [60, 90, 120, 180];

export const SettingsScreen = () => {
  const [restDefault, setRestDefault] = useState("90");
  const [notifState, setNotifState] = useState<NotificationPermission | "unsupported">("unsupported");
  const router = useRouter();
  const queryClient = useQueryClient();
  const meQuery = useQuery({
    queryKey: ["me"],
    queryFn: apiClient.getMe,
    retry: false,
  });
  const preferencesMutation = useMutation({
    mutationFn: apiClient.updatePreferences,
    onSuccess: ({ user }) => {
      queryClient.setQueryData(["me"], { user });
      toast.success("Preferences updated");
    },
    onError: (error: Error) => toast.error(error.message),
  });
  const logoutMutation = useMutation({
    mutationFn: apiClient.logout,
    onSuccess: async () => {
      queryClient.removeQueries({ queryKey: ["me"] });
      toast.success("Signed out");
      router.push("/");
    },
  });

  useEffect(() => {
    if (typeof window !== "undefined" && "Notification" in window) {
      setNotifState(Notification.permission);
    }
  }, []);

  const handleEnableNotifications = async () => {
    const result = await Notification.requestPermission();
    setNotifState(result);
    if (result === "granted") toast.success("Notifications enabled");
    else if (result === "denied") toast.error("Notifications blocked — enable them in browser settings");
  };

  useEffect(() => {
    if (typeof window === "undefined") return;
    setRestDefault(window.localStorage.getItem("liftiq-rest-default") ?? "90");
  }, []);

  if (meQuery.isLoading) {
    return (
      <Card>
        <CardContent className="pt-6">
          <Skeleton className="h-72" />
        </CardContent>
      </Card>
    );
  }

  if (meQuery.isError || !meQuery.data) {
    return (
      <div className="grid min-h-[calc(100vh-8rem)] place-items-center">
        <AuthCard onSuccess={() => meQuery.refetch()} />
      </div>
    );
  }

  return (
    <div className="space-y-12">
      <header className="space-y-3">
        <BackButton fallbackHref="/" />
        <p className="eyebrow">Settings</p>
        <h1 className="font-display text-4xl font-bold tracking-editorial text-ink leading-tight">
          Make it yours.
        </h1>
      </header>

      <Section eyebrow="01" title="Theme" description="Five moods, one editorial DNA. Pick the room you train in.">
        <ThemeSwitcher layout="grid" />
      </Section>

      <Section eyebrow="02" title="Units" description="Volume is stored in kilograms; pick how it's shown.">
        <div className="space-y-2 max-w-xs">
          <Label htmlFor="unit-select">Display unit</Label>
          <Select
            value={meQuery.data.user.preferredUnit}
            onValueChange={(value) =>
              preferencesMutation.mutate({ preferredUnit: value as "kg" | "lb" })
            }
          >
            <SelectTrigger id="unit-select" disabled={preferencesMutation.isPending}>
              <SelectValue placeholder="Choose a unit" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="kg">Kilograms (kg)</SelectItem>
              <SelectItem value="lb">Pounds (lb)</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </Section>

      <Section eyebrow="03" title="Profile" description="Used for milestone tuning where it matters.">
        <div className="space-y-2 max-w-xs">
          <Label htmlFor="gender-select">Gender</Label>
          <Select
            value={meQuery.data.user.gender}
            onValueChange={(value) =>
              preferencesMutation.mutate({
                gender: value as "MALE" | "FEMALE" | "NON_BINARY" | "PREFER_NOT_TO_SAY",
              })
            }
          >
            <SelectTrigger id="gender-select" disabled={preferencesMutation.isPending}>
              <SelectValue placeholder="Choose a gender" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="MALE">Male</SelectItem>
              <SelectItem value="FEMALE">Female</SelectItem>
              <SelectItem value="NON_BINARY">Non-binary</SelectItem>
              <SelectItem value="PREFER_NOT_TO_SAY">Prefer not to say</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </Section>

      <Section eyebrow="04" title="Rest timer" description="Default the workout screen reaches for first.">
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-2 max-w-md">
          {REST_DEFAULTS.map((seconds) => {
            const active = restDefault === String(seconds);
            return (
              <Button
                key={seconds}
                type="button"
                variant={active ? "default" : "outline"}
                onClick={() => {
                  if (typeof window !== "undefined") {
                    window.localStorage.setItem("liftiq-rest-default", String(seconds));
                  }
                  setRestDefault(String(seconds));
                }}
              >
                {seconds < 120 ? `${seconds}s` : `${seconds / 60}m`}
              </Button>
            );
          })}
        </div>
      </Section>

      <Section
        eyebrow="05"
        title="Notifications"
        description="Rest alerts use local browser notifications on this device."
      >
        <div className="flex items-center justify-between gap-3 border-y border-rule py-4">
          <div className="space-y-0.5">
            <p className="text-ink">
              {notifState === "granted"
                ? "Enabled"
                : notifState === "denied"
                  ? "Blocked in browser"
                  : notifState === "unsupported"
                    ? "Unavailable on this device"
                    : "Not enabled"}
            </p>
            <p className="text-sm text-ink-muted">
              {notifState === "denied"
                ? "Allow notifications in your browser site settings to enable."
                : "Used for rest timer alerts during workouts."}
            </p>
          </div>
          {notifState === "default" ? (
            <Button size="sm" variant="outline" onClick={handleEnableNotifications}>
              Enable
            </Button>
          ) : null}
        </div>
      </Section>

      <Section eyebrow="06" title="Account" description="Sign out on this device.">
        <Button
          variant="outline"
          className="text-danger border-danger/40 hover:bg-danger/5"
          onClick={() => logoutMutation.mutate()}
          disabled={logoutMutation.isPending}
        >
          {logoutMutation.isPending ? "Signing out…" : "Sign out"}
        </Button>
      </Section>
    </div>
  );
};

const Section = ({
  eyebrow,
  title,
  description,
  children,
}: {
  eyebrow: string;
  title: string;
  description?: string;
  children: React.ReactNode;
}) => (
  <section className="space-y-5">
    <header className="space-y-2 border-b border-rule pb-3">
      <p className="eyebrow">{eyebrow}</p>
      <h2 className="font-display text-2xl font-semibold tracking-editorial text-ink">{title}</h2>
      {description ? <p className="text-sm text-ink-muted leading-6 max-w-md">{description}</p> : null}
    </header>
    {children}
  </section>
);
