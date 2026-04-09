"use client";

import { useQuery } from "@tanstack/react-query";
import { BellRing, MoonStar, Palette, TimerReset } from "lucide-react";
import { useEffect, useState } from "react";

import { AuthCard } from "@/components/auth/auth-card";
import { useTheme, themes } from "@/components/providers/theme-provider";
import { BackButton } from "@/components/ui/back-button";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { ScreenHero } from "@/components/ui/screen-hero";
import { Skeleton } from "@/components/ui/skeleton";
import { apiClient } from "@/lib/api-client";

const REST_DEFAULTS = [60, 90, 120, 180];

export const SettingsScreen = () => {
  const { theme, setTheme } = useTheme();
  const [restDefault, setRestDefault] = useState("90");
  const meQuery = useQuery({
    queryKey: ["me"],
    queryFn: apiClient.getMe,
    retry: false,
  });
  const notificationState =
    typeof window !== "undefined" && "Notification" in window ? Notification.permission : "unsupported";

  useEffect(() => {
    if (typeof window === "undefined") {
      return;
    }

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
    <div className="app-grid">
      <ScreenHero
        eyebrow="Settings"
        title="Keep the app feeling like your app."
        actions={<BackButton fallbackHref="/" />}
      />

      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Palette className="h-4 w-4 text-primary" />
            Theme
          </CardTitle>
          <CardDescription>Use the original LiftIQ themes from the old app and keep the palette consistent across screens.</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-2">
            <Label htmlFor="theme-select">Colour theme</Label>
            <Select value={theme} onValueChange={(value) => setTheme(value as (typeof themes)[number]["value"])}>
              <SelectTrigger id="theme-select">
                <SelectValue placeholder="Choose a theme" />
              </SelectTrigger>
              <SelectContent>
                {themes.map((option) => (
                  <SelectItem key={option.value} value={option.value}>
                    {option.label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <TimerReset className="h-4 w-4 text-primary" />
            Rest timer
          </CardTitle>
          <CardDescription>Set the quick default the workout screen should use first.</CardDescription>
        </CardHeader>
        <CardContent className="grid grid-cols-2 gap-2">
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
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <BellRing className="h-4 w-4 text-primary" />
            Notifications
          </CardTitle>
          <CardDescription>Rest alerts use local browser notifications on this device.</CardDescription>
        </CardHeader>
        <CardContent className="flex items-center justify-between gap-3">
          <div>
            <p className="font-medium text-foreground">
              {notificationState === "granted"
                ? "Enabled"
                : notificationState === "denied"
                  ? "Blocked"
                  : notificationState === "unsupported"
                    ? "Unavailable"
                    : "Not enabled"}
            </p>
            <p className="text-sm text-muted-foreground">Turn them on from the active workout timer tools.</p>
          </div>
          <MoonStar className="h-5 w-5 text-muted-foreground" />
        </CardContent>
      </Card>
    </div>
  );
};
