"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Download, SlidersHorizontal } from "lucide-react";
import { useEffect, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import { toast } from "sonner";

import { AuthCard } from "@/components/auth/auth-card";
import { BackButton } from "@/components/ui/back-button";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { EmptyState } from "@/components/ui/empty-state";
import { KeypadProvider } from "@/components/ui/keypad-context";
import { Label } from "@/components/ui/label";
import { NumberField } from "@/components/ui/number-field";
import { Segmented } from "@/components/ui/segmented";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Skeleton } from "@/components/ui/skeleton";
import { Stepper } from "@/components/ui/stepper";
import { Switch } from "@/components/ui/switch";
import { ThemeSwitcher } from "@/components/ui/theme-switcher";
import { apiClient } from "@/lib/api-client";
import type { UserExercisePreference, UserSettings } from "@/lib/types";
import { usePushNotifications, type PushNotificationsApi } from "@/lib/use-push-notifications";
import { cn } from "@/lib/utils";

const REST_PRESETS = [
  { value: 60, label: "60s" },
  { value: 90, label: "90s" },
  { value: 120, label: "2m" },
  { value: 180, label: "3m" },
] as const;

const PLATE_DENOMINATIONS: Record<"kg" | "lb", number[]> = {
  kg: [25, 20, 15, 10, 5, 2.5, 1.25],
  lb: [55, 45, 35, 25, 10, 5, 2.5],
};

const formatSeconds = (seconds: number) =>
  seconds >= 60
    ? `${Math.floor(seconds / 60)}:${String(seconds % 60).padStart(2, "0")}`
    : `${seconds}s`;

/** Human summary of what an exercise preference remembers. */
const describePreference = (preference: UserExercisePreference): string => {
  const parts: string[] = [];
  if (preference.unilateral !== null) {
    parts.push(preference.unilateral ? "Unilateral on" : "Unilateral off");
  }
  if (preference.trackingMode !== null) {
    parts.push(`Tracking: ${preference.trackingMode.replaceAll("_", " ").toLowerCase()}`);
  }
  if (preference.barWeight !== null) {
    parts.push(`Bar weight ${preference.barWeight}`);
  }
  if (typeof preference.restSeconds === "number") {
    parts.push(`Rest ${formatSeconds(preference.restSeconds)}`);
  }
  return parts.length ? parts.join(" • ") : "Customised mid-workout";
};

export const SettingsScreen = () => {
  const [notifState, setNotifState] = useState<NotificationPermission | "unsupported">("unsupported");
  const push = usePushNotifications();
  const migrationRan = useRef(false);
  const router = useRouter();
  const queryClient = useQueryClient();
  const meQuery = useQuery({
    queryKey: ["me"],
    queryFn: apiClient.getMe,
    retry: false,
  });
  const preferencesQuery = useQuery({
    queryKey: ["exercise-preferences"],
    queryFn: apiClient.getExercisePreferences,
    enabled: meQuery.isSuccess,
  });
  const exercisesQuery = useQuery({
    queryKey: ["exercises"],
    queryFn: apiClient.getExercises,
    enabled: meQuery.isSuccess,
  });
  const preferencesMutation = useMutation({
    mutationFn: apiClient.updatePreferences,
    onSuccess: ({ user }) => {
      queryClient.setQueryData(["me"], { user });
      toast.success("Preferences updated");
    },
    onError: (error: Error) => toast.error(error.message),
  });
  const settingsMutation = useMutation({
    mutationFn: apiClient.updateSettings,
    onSuccess: ({ user }) => {
      queryClient.setQueryData(["me"], { user });
    },
    onError: (error: Error) => toast.error(error.message),
  });
  const resetPreferenceMutation = useMutation({
    mutationFn: apiClient.deleteExercisePreference,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["exercise-preferences"] });
      toast.success("Preference reset");
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

  const settings = meQuery.data?.user.settings;
  const updateSettings = settingsMutation.mutate;
  const settingsPending = settingsMutation.isPending;

  useEffect(() => {
    if (typeof window !== "undefined" && "Notification" in window) {
      setNotifState(Notification.permission);
    }
  }, []);

  // One-time migration of the legacy localStorage rest settings to the
  // server-side user settings. Runs once per mount, only after the user
  // record has loaded, and removes both legacy keys afterwards.
  useEffect(() => {
    if (migrationRan.current || !settings || typeof window === "undefined") return;
    migrationRan.current = true;

    const legacyRest = window.localStorage.getItem("liftiq-rest-default");
    const legacyAutoRest = window.localStorage.getItem("liftiq-auto-rest");
    if (legacyRest === null && legacyAutoRest === null) return;

    const rest: Partial<UserSettings["rest"]> = {};
    const parsedRest = legacyRest === null ? Number.NaN : Number.parseInt(legacyRest, 10);
    if (Number.isFinite(parsedRest) && parsedRest > 0 && parsedRest !== settings.rest.workingSeconds) {
      rest.workingSeconds = parsedRest;
    }
    if (legacyAutoRest !== null) {
      const autoStart = legacyAutoRest !== "false";
      if (autoStart !== settings.rest.autoStart) {
        rest.autoStart = autoStart;
      }
    }

    window.localStorage.removeItem("liftiq-rest-default");
    window.localStorage.removeItem("liftiq-auto-rest");

    if (Object.keys(rest).length > 0) {
      updateSettings({ rest });
    }
  }, [settings, updateSettings]);

  const downloadExport = (format: "csv" | "json") => {
    if (typeof window === "undefined") return;
    const anchor = document.createElement("a");
    anchor.href = apiClient.workoutsExportUrl(format);
    anchor.rel = "noopener";
    document.body.appendChild(anchor);
    anchor.click();
    anchor.remove();
  };

  const handleEnableNotifications = async () => {
    const result = await Notification.requestPermission();
    setNotifState(result);
    if (result === "granted") toast.success("Notifications enabled");
    else if (result === "denied") toast.error("Notifications blocked — enable them in browser settings");
  };

  if (meQuery.isLoading) {
    return (
      <Card>
        <CardContent className="pt-6">
          <Skeleton className="h-72" />
        </CardContent>
      </Card>
    );
  }

  if (meQuery.isError || !meQuery.data || !settings) {
    return (
      <div className="grid min-h-[calc(100vh-8rem)] place-items-center">
        <AuthCard onSuccess={() => meQuery.refetch()} />
      </div>
    );
  }

  const user = meQuery.data.user;
  const unit = user.preferredUnit;
  const selectedPlates = settings.plates[unit];

  // Cardio settings also feed the cardio progression / goal-ring queries, so
  // persist via the shared settings mutation then refresh those reads.
  const saveCardioSettings = (cardio: Partial<UserSettings["cardio"]>) => {
    if (settingsPending) return;
    settingsMutation.mutate(
      { cardio },
      {
        onSuccess: () => {
          void queryClient.invalidateQueries({ queryKey: ["me"] });
          void queryClient.invalidateQueries({ queryKey: ["cardio-progression"] });
          toast.success("Cardio settings updated");
        },
      },
    );
  };

  const togglePlate = (denomination: number) => {
    if (settingsPending) return;
    const next = selectedPlates.includes(denomination)
      ? selectedPlates.filter((plate) => plate !== denomination)
      : [...selectedPlates, denomination].sort((a, b) => b - a);
    updateSettings({ plates: unit === "kg" ? { kg: next } : { lb: next } });
  };

  const exerciseNames = new Map((exercisesQuery.data ?? []).map((exercise) => [exercise.id, exercise.name]));
  const exercisePreferences = preferencesQuery.data?.preferences ?? [];

  return (
    <div className="space-y-12">
      <header className="space-y-3">
        <BackButton fallbackHref="/" />
        <p className="eyebrow">Settings</p>
        <h1 className="font-display text-4xl font-bold tracking-editorial text-ink leading-tight">
          Make it yours.
        </h1>
      </header>

      <Section eyebrow="01" title="Theme" description="Dark for the gym floor, light for daylight. Same DNA either way.">
        <ThemeSwitcher layout="grid" />
      </Section>

      <Section eyebrow="02" title="Units" description="Volume is stored in kilograms; pick how it's shown.">
        <div className="space-y-2 max-w-xs">
          <Label htmlFor="unit-select">Display unit</Label>
          <Select
            value={user.preferredUnit}
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
            value={user.gender}
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

      <Section
        eyebrow="04"
        title="Advanced tracking"
        description="Extra inputs on every set, for lifters who log more than weight and reps."
      >
        <div className="max-w-md divide-y divide-rule border-y border-rule">
          <ToggleRow
            id="advanced-tracking"
            title="Advanced tracking"
            description="Master switch for RPE and tempo logging."
            checked={settings.advancedTracking.enabled}
            disabled={settingsPending}
            onCheckedChange={(enabled) => updateSettings({ advancedTracking: { enabled } })}
          />
          {settings.advancedTracking.enabled ? (
            <>
              <ToggleRow
                id="advanced-rpe"
                title="RPE"
                description="Rate of perceived exertion on working sets."
                checked={settings.advancedTracking.rpe}
                disabled={settingsPending}
                onCheckedChange={(rpe) => updateSettings({ advancedTracking: { rpe } })}
                indent
              />
              <ToggleRow
                id="advanced-tempo"
                title="Tempo"
                description="Eccentric / pause / concentric cadence per set."
                checked={settings.advancedTracking.tempo}
                disabled={settingsPending}
                onCheckedChange={(tempo) => updateSettings({ advancedTracking: { tempo } })}
                indent
              />
              <ToggleRow
                id="advanced-readiness"
                title="Readiness check-in"
                description="A quick sleep/energy/soreness check before program workouts nudges the day's suggested loads."
                checked={settings.advancedTracking.readiness}
                disabled={settingsPending}
                onCheckedChange={(readiness) =>
                  updateSettings({ advancedTracking: { readiness } })
                }
                indent
              />
            </>
          ) : null}
        </div>
      </Section>

      <Section eyebrow="05" title="Rest timer" description="Defaults the workout screen reaches for first.">
        <div className="max-w-md space-y-6">
          <RestDurationControl
            label="Working sets"
            value={settings.rest.workingSeconds}
            disabled={settingsPending}
            onChange={(workingSeconds) => updateSettings({ rest: { workingSeconds } })}
          />
          <RestDurationControl
            label="Warm-up sets"
            value={settings.rest.warmupSeconds}
            disabled={settingsPending}
            onChange={(warmupSeconds) => updateSettings({ rest: { warmupSeconds } })}
          />
          <div className="border-t border-rule">
            <ToggleRow
              id="auto-rest"
              title="Auto-start after each set"
              description="Begin the rest countdown when you complete a set."
              checked={settings.rest.autoStart}
              disabled={settingsPending}
              onCheckedChange={(autoStart) => updateSettings({ rest: { autoStart } })}
            />
          </div>
        </div>
      </Section>

      <Section
        eyebrow="06"
        title="Cardio"
        description="Your weekly active-minutes goal powers the cardio goal ring; the distance unit applies to cardio screens."
      >
        <div className="max-w-md space-y-6">
          <KeypadProvider>
            <div className="space-y-2">
              <Label htmlFor="cardio-weekly-goal">Weekly active-minutes goal</Label>
              <div className="max-w-[12rem]">
                <NumberField
                  id="cardio-weekly-goal"
                  kind="generic"
                  label="Weekly active minutes goal"
                  value={settings.cardio.weeklyMinutesGoal}
                  placeholder="min"
                  allowDecimal={false}
                  min={0}
                  max={10080}
                  onCommit={(value) =>
                    saveCardioSettings({ weeklyMinutesGoal: value ?? 0 })
                  }
                />
              </div>
              <p className="text-sm text-ink-muted">
                The WHO suggests 150 minutes of moderate activity per week.
              </p>
            </div>
          </KeypadProvider>
          <div className="space-y-2 border-t border-rule pt-4">
            <p className="text-sm text-ink">Default distance unit</p>
            <Segmented
              options={[
                { value: "km", label: "Kilometres" },
                { value: "mi", label: "Miles" },
              ]}
              value={settings.cardio.defaultDistanceUnit}
              onChange={(defaultDistanceUnit) => saveCardioSettings({ defaultDistanceUnit })}
            />
          </div>
        </div>
      </Section>

      <Section
        eyebrow="07"
        title="Plate inventory & bars"
        description={`What's actually on your rack. The plate calculator only suggests plates you own (${unit}).`}
      >
        <div className="max-w-md space-y-6">
          <div className="space-y-2">
            <p className="text-sm text-ink">Available plates ({unit})</p>
            <div className="flex flex-wrap gap-2">
              {PLATE_DENOMINATIONS[unit].map((denomination) => {
                const selected = selectedPlates.includes(denomination);
                return (
                  <button
                    key={denomination}
                    type="button"
                    role="checkbox"
                    aria-checked={selected}
                    aria-label={`${denomination} ${unit} plate`}
                    disabled={settingsPending}
                    onClick={() => togglePlate(denomination)}
                    className={cn(
                      "num touch-target rounded-md border px-4 py-2 text-sm font-semibold transition-colors disabled:opacity-50",
                      selected
                        ? "border-rule-strong bg-surface-sunken text-ink"
                        : "border-rule text-ink-subtle hover:text-ink-muted",
                    )}
                  >
                    {denomination}
                  </button>
                );
              })}
            </div>
          </div>
          <div className="space-y-3 border-t border-rule pt-4">
            <p className="text-sm text-ink">Bar weights</p>
            <div className="grid gap-3 sm:grid-cols-3">
              <LabeledStepper
                label="Barbell"
                value={settings.barWeights.barbell}
                onChange={(barbell) => updateSettings({ barWeights: { barbell } })}
              />
              <LabeledStepper
                label="EZ bar"
                value={settings.barWeights.ezBar}
                onChange={(ezBar) => updateSettings({ barWeights: { ezBar } })}
              />
              <LabeledStepper
                label="Trap bar"
                value={settings.barWeights.trapBar}
                onChange={(trapBar) => updateSettings({ barWeights: { trapBar } })}
              />
            </div>
          </div>
        </div>
      </Section>

      <Section
        eyebrow="08"
        title="Previous values"
        description="Where set placeholders come from while you log."
      >
        <div className="max-w-md space-y-2">
          <Segmented
            options={[
              { value: "slot", label: "This slot" },
              { value: "anywhere", label: "Anywhere" },
            ]}
            value={settings.previousValueScope}
            onChange={(previousValueScope) => {
              if (!settingsPending) updateSettings({ previousValueScope });
            }}
          />
          <p className="text-sm text-ink-muted leading-6">
            {settings.previousValueScope === "slot"
              ? "Pre-fill from the same exercise slot in this program — strict week-over-week comparison."
              : "Pre-fill from the last time you did the exercise anywhere, planned or not."}
          </p>
        </div>
      </Section>

      <Section
        eyebrow="09"
        title="Exercise preferences"
        description="Per-exercise tweaks remembered from your workouts."
      >
        {preferencesQuery.isLoading || exercisesQuery.isLoading ? (
          <div className="max-w-md space-y-2">
            <Skeleton className="h-14" />
            <Skeleton className="h-14" />
          </div>
        ) : exercisePreferences.length ? (
          <div className="max-w-md divide-y divide-rule border-y border-rule">
            {exercisePreferences.map((preference) => (
              <div key={preference.id} className="flex items-center justify-between gap-3 py-3">
                <div className="min-w-0 space-y-0.5">
                  <p className="truncate text-ink">
                    {exerciseNames.get(preference.exerciseId) ?? "Unknown exercise"}
                  </p>
                  <p className="truncate text-sm text-ink-muted">{describePreference(preference)}</p>
                </div>
                <Button
                  size="sm"
                  variant="outline"
                  disabled={resetPreferenceMutation.isPending}
                  onClick={() => resetPreferenceMutation.mutate(preference.exerciseId)}
                >
                  Reset
                </Button>
              </div>
            ))}
          </div>
        ) : (
          <EmptyState
            className="max-w-md"
            icon={SlidersHorizontal}
            title="No exercise preferences yet"
            description="Preferences appear here when you customise an exercise mid-workout."
          />
        )}
      </Section>

      <Section
        eyebrow="10"
        title="Notifications"
        description="Rest alerts use local browser notifications on this device."
      >
        <div className="flex items-center justify-between gap-3 border-y border-rule py-4 max-w-md">
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

      <Section
        eyebrow="11"
        title="Reminders"
        description="Push reminders for supplement schedules. This switch controls whether THIS device/browser receives them — each schedule also has its own reminder toggle in the schedule editor."
      >
        <RemindersControl push={push} />
      </Section>

      <Section
        eyebrow="12"
        title="Your data"
        description="Export every completed workout. It's yours — take it anywhere."
      >
        <div className="flex flex-wrap gap-2">
          <Button variant="outline" onClick={() => downloadExport("csv")}>
            <Download className="h-4 w-4" />
            Export CSV
          </Button>
          <Button variant="outline" onClick={() => downloadExport("json")}>
            <Download className="h-4 w-4" />
            Export JSON
          </Button>
        </div>
      </Section>

      <Section eyebrow="13" title="Account" description="Sign out on this device.">
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

const ToggleRow = ({
  id,
  title,
  description,
  checked,
  disabled,
  onCheckedChange,
  indent = false,
}: {
  id: string;
  title: string;
  description?: string;
  checked: boolean;
  disabled?: boolean;
  onCheckedChange: (checked: boolean) => void;
  indent?: boolean;
}) => (
  <div className={cn("flex items-center justify-between gap-3 py-3", indent && "pl-4")}>
    <label htmlFor={id} className="min-w-0 cursor-pointer space-y-0.5">
      <p className="text-ink">{title}</p>
      {description ? <p className="text-sm text-ink-muted">{description}</p> : null}
    </label>
    <Switch id={id} checked={checked} disabled={disabled} onCheckedChange={onCheckedChange} />
  </div>
);

/**
 * Device-level Web Push toggle for supplement reminders. Reflects the live
 * subscription/permission state and disables itself when push is unsupported,
 * blocked, or the server has no VAPID keys.
 */
const RemindersControl = ({ push }: { push: PushNotificationsApi }) => {
  const { supported, permission, subscribed, serverEnabled, busy, enable, disable, sendTest } =
    push;

  const serverDisabled = serverEnabled === false;
  const blocked = permission === "denied";
  const toggleDisabled = busy || !supported || serverDisabled || (blocked && !subscribed);

  let statusLine: string;
  if (!supported) {
    statusLine = "Not available on this device";
  } else if (serverDisabled) {
    statusLine = "Not available on the server";
  } else if (subscribed) {
    statusLine = "Enabled on this device";
  } else if (blocked) {
    statusLine = "Blocked in browser";
  } else {
    statusLine = "Off";
  }

  let hint: string;
  if (!supported) {
    hint = "This browser doesn't support push notifications.";
  } else if (serverDisabled) {
    hint = "Push notifications are turned off on the server right now.";
  } else if (blocked) {
    hint = "Notifications are blocked — enable them in your browser settings, then try again.";
  } else {
    hint = "Receive supplement reminders on this device, even when the app is closed.";
  }

  const handleToggle = (checked: boolean) => {
    if (checked) {
      void enable();
    } else {
      void disable();
    }
  };

  return (
    <div className="max-w-md space-y-4">
      <div className="flex items-center justify-between gap-3 border-y border-rule py-4">
        <div className="min-w-0 space-y-0.5">
          <p className="text-ink">Supplement reminders</p>
          <p className="text-sm text-ink-muted">{statusLine}</p>
        </div>
        <Switch
          aria-label="Supplement reminders"
          checked={subscribed}
          disabled={toggleDisabled}
          onCheckedChange={handleToggle}
        />
      </div>
      <p className="text-sm text-ink-muted leading-6">{hint}</p>
      {subscribed ? (
        <Button size="sm" variant="outline" disabled={busy} onClick={() => void sendTest()}>
          Send test notification
        </Button>
      ) : null}
    </div>
  );
};

/** Preset segmented control plus a 15-second custom stepper for one rest duration. */
const RestDurationControl = ({
  label,
  value,
  disabled,
  onChange,
}: {
  label: string;
  value: number;
  disabled?: boolean;
  onChange: (seconds: number) => void;
}) => {
  const isPreset = REST_PRESETS.some((preset) => preset.value === value);
  return (
    <div className="space-y-2">
      <div className="flex items-baseline justify-between gap-3">
        <p className="text-sm text-ink">{label}</p>
        <p className="num text-sm font-semibold text-ink">{formatSeconds(value)}</p>
      </div>
      <Segmented
        options={REST_PRESETS}
        value={isPreset ? value : null}
        onChange={(seconds) => {
          if (!disabled) onChange(seconds);
        }}
      />
      <Stepper
        label={`Custom ${label.toLowerCase()} rest`}
        value={value}
        min={15}
        max={600}
        step={15}
        format={formatSeconds}
        onChange={(next) => {
          if (next !== null && !disabled) onChange(next);
        }}
      />
    </div>
  );
};

const LabeledStepper = ({
  label,
  value,
  onChange,
}: {
  label: string;
  value: number;
  onChange: (value: number) => void;
}) => (
  <div className="space-y-1.5">
    <p className="text-xs text-ink-muted">{label}</p>
    <Stepper
      label={`${label} weight`}
      value={value}
      min={0}
      max={50}
      step={0.5}
      onChange={(next) => {
        if (next !== null) onChange(next);
      }}
    />
  </div>
);
