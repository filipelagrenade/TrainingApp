"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Plus, Scale, Trash2 } from "lucide-react";
import { useState } from "react";
import { toast } from "sonner";

import { apiClient } from "@/lib/api-client";
import { AuthCard } from "@/components/auth/auth-card";
import { LineTrendChart } from "@/components/progress/charts/line-trend-chart";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { EmptyState } from "@/components/ui/empty-state";
import { ErrorState } from "@/components/ui/error-state";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { PageHeader } from "@/components/ui/page-header";
import { Skeleton } from "@/components/ui/skeleton";
import { Stat } from "@/components/ui/stat";
import { Stepper } from "@/components/ui/stepper";

// Body circumference fields (centimetres) the log dialog offers alongside bodyweight.
// `seed` is where the stepper starts the first time a field is used; afterwards it
// seeds from the most recent logged value for that field.
const MEASUREMENT_FIELDS: Array<{ key: string; label: string; seed: number }> = [
  { key: "waist", label: "Waist", seed: 80 },
  { key: "chest", label: "Chest", seed: 100 },
  { key: "arms", label: "Arms", seed: 35 },
  { key: "thighs", label: "Thighs", seed: 55 },
  { key: "hips", label: "Hips", seed: 95 },
];

const shortDate = (iso: string) =>
  new Date(iso).toLocaleDateString(undefined, { month: "short", day: "numeric" });

export const BodyMetricsScreen = () => {
  const queryClient = useQueryClient();
  const [dialogOpen, setDialogOpen] = useState(false);
  const [weight, setWeight] = useState<number | null>(null);
  const [measurements, setMeasurements] = useState<Record<string, number | null>>({});
  const [note, setNote] = useState("");

  const meQuery = useQuery({ queryKey: ["me"], queryFn: apiClient.getMe, retry: false });
  const metricsQuery = useQuery({
    queryKey: ["body-metrics"],
    queryFn: apiClient.getBodyMetrics,
    enabled: meQuery.isSuccess,
  });

  const resetForm = () => {
    setWeight(null);
    setMeasurements({});
    setNote("");
  };

  const createMutation = useMutation({
    mutationFn: apiClient.createBodyMetric,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["body-metrics"] });
      toast.success("Entry logged");
      resetForm();
      setDialogOpen(false);
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const deleteMutation = useMutation({
    mutationFn: apiClient.deleteBodyMetric,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["body-metrics"] });
      toast.success("Entry removed");
    },
    onError: (error: Error) => toast.error(error.message),
  });

  if (meQuery.isLoading) {
    return (
      <div className="space-y-6">
        <Skeleton className="h-20" />
        <Skeleton className="h-72" />
      </div>
    );
  }

  if (meQuery.isError || !meQuery.data) {
    return (
      <div className="grid min-h-[calc(100vh-8rem)] place-items-center">
        <AuthCard onSuccess={() => meQuery.refetch()} />
      </div>
    );
  }

  const unit = meQuery.data.user.preferredUnit;
  const data = metricsQuery.data;
  const trend = data?.weightTrend ?? [];
  const change =
    trend.length >= 2 ? Number((trend[trend.length - 1].value - trend[0].value).toFixed(1)) : null;

  // Steppers seed from the most recent logged value so the next entry starts close.
  const weightSeed = data?.latest?.weight ?? (unit === "kg" ? 75 : 165);
  const seedForMeasurement = (key: string, fallback: number) => {
    for (const entry of data?.entries ?? []) {
      const value = entry.measurements?.[key];
      if (typeof value === "number") {
        return value;
      }
    }
    return fallback;
  };

  const handleSubmit = () => {
    const cleanedMeasurements = Object.fromEntries(
      Object.entries(measurements).filter(([, value]) => typeof value === "number"),
    ) as Record<string, number>;

    if (weight === null && !Object.keys(cleanedMeasurements).length) {
      toast.error("Add a bodyweight or at least one measurement.");
      return;
    }

    createMutation.mutate({
      weight: weight ?? undefined,
      measurements: Object.keys(cleanedMeasurements).length ? cleanedMeasurements : undefined,
      note: note.trim() ? note.trim() : undefined,
    });
  };

  const logDialog = (
    <Dialog
      open={dialogOpen}
      onOpenChange={(open) => {
        setDialogOpen(open);
        if (!open) resetForm();
      }}
    >
      <DialogTrigger asChild>
        <Button size="sm">
          <Plus className="h-4 w-4" />
          Log entry
        </Button>
      </DialogTrigger>
      <DialogContent onOpenAutoFocus={(event) => event.preventDefault()}>
        <DialogHeader>
          <DialogTitle>Log body metrics</DialogTitle>
          <DialogDescription>Track your bodyweight and optional measurements over time.</DialogDescription>
        </DialogHeader>
        <div className="space-y-4">
          <div className="space-y-2">
            <Label>Bodyweight ({unit})</Label>
            <Stepper
              label={`Bodyweight in ${unit}`}
              value={weight}
              onChange={setWeight}
              min={0}
              step={0.5}
              seed={weightSeed}
              allowClear
              format={(value) => `${value} ${unit}`}
            />
          </div>
          <div className="space-y-2">
            <Label>Measurements (cm)</Label>
            <div className="grid grid-cols-2 gap-2">
              {MEASUREMENT_FIELDS.map((field) => (
                <div key={field.key} className="space-y-1">
                  <Label className="text-xs text-ink-muted">{field.label}</Label>
                  <Stepper
                    label={`${field.label} in cm`}
                    value={measurements[field.key] ?? null}
                    onChange={(value) =>
                      setMeasurements((current) => ({ ...current, [field.key]: value }))
                    }
                    min={0}
                    step={0.5}
                    seed={seedForMeasurement(field.key, field.seed)}
                    allowClear
                  />
                </div>
              ))}
            </div>
          </div>
          <div className="space-y-2">
            <Label htmlFor="bw-note">Note</Label>
            <Input
              id="bw-note"
              value={note}
              onChange={(event) => setNote(event.target.value)}
              placeholder="Optional"
              maxLength={500}
            />
          </div>
        </div>
        <DialogFooter>
          <Button onClick={handleSubmit} disabled={createMutation.isPending}>
            {createMutation.isPending ? "Saving…" : "Save entry"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );

  return (
    <div className="space-y-6">
      <PageHeader
        eyebrow="Body"
        title="Body metrics"
        description="Bodyweight and measurement history."
        backHref="/progress"
        actions={logDialog}
      />

      {metricsQuery.isLoading ? (
        <Skeleton className="h-20" />
      ) : (
        <div className="grid grid-cols-3 gap-4 border-y border-rule py-4">
          <Stat
            label="Latest"
            value={data?.latest?.weight != null ? `${data.latest.weight} ${unit}` : "—"}
          />
          <Stat
            label="Change"
            value={change === null ? "—" : `${change > 0 ? "+" : ""}${change} ${unit}`}
          />
          <Stat label="Entries" value={String(data?.entries.length ?? 0)} />
        </div>
      )}

      {metricsQuery.isError ? (
        <ErrorState
          title="Couldn't load body metrics"
          description={metricsQuery.error instanceof Error ? metricsQuery.error.message : undefined}
          onRetry={() => void metricsQuery.refetch()}
        />
      ) : (
        <>
          <Card>
            <CardHeader>
              <CardTitle>Weight trend</CardTitle>
              <CardDescription>Your logged bodyweight over time.</CardDescription>
            </CardHeader>
            <CardContent>
              {metricsQuery.isLoading ? (
                <Skeleton className="h-48" />
              ) : trend.length >= 2 ? (
                <LineTrendChart
                  data={trend.map((point) => ({ label: shortDate(point.recordedAt), value: point.value }))}
                  valueFormatter={(value) => `${value} ${unit}`}
                />
              ) : (
                <EmptyState
                  icon={Scale}
                  title="Not enough data yet"
                  description="Log at least two bodyweight entries to see your trend."
                />
              )}
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>History</CardTitle>
              <CardDescription>Every entry, most recent first.</CardDescription>
            </CardHeader>
            <CardContent className="space-y-3">
              {metricsQuery.isLoading ? (
                Array.from({ length: 3 }).map((_, index) => <Skeleton key={index} className="h-16" />)
              ) : data?.entries.length ? (
                data.entries.map((entry) => (
                  <div
                    key={entry.id}
                    className="surface-panel flex items-start justify-between gap-3 p-4"
                  >
                    <div className="min-w-0">
                      <div className="flex flex-wrap items-baseline gap-2">
                        <p className="num font-semibold text-ink">
                          {entry.weight != null ? `${entry.weight} ${unit}` : "—"}
                        </p>
                        <p className="eyebrow">{new Date(entry.recordedAt).toLocaleDateString()}</p>
                      </div>
                      {entry.measurements && Object.keys(entry.measurements).length ? (
                        <p className="num mt-1 text-sm text-ink-muted">
                          {Object.entries(entry.measurements)
                            .map(([key, value]) => `${key} ${value}cm`)
                            .join(" · ")}
                        </p>
                      ) : null}
                      {entry.note ? <p className="mt-1 text-sm italic text-ink-soft">{entry.note}</p> : null}
                    </div>
                    <Button
                      size="icon"
                      variant="ghost"
                      aria-label="Delete entry"
                      disabled={deleteMutation.isPending}
                      onClick={() => deleteMutation.mutate(entry.id)}
                    >
                      <Trash2 className="h-4 w-4" />
                    </Button>
                  </div>
                ))
              ) : (
                <EmptyState
                  icon={Scale}
                  title="No entries yet"
                  description="Log your first bodyweight to get started."
                  action={
                    <Button size="sm" onClick={() => setDialogOpen(true)}>
                      <Plus className="h-4 w-4" />
                      Log entry
                    </Button>
                  }
                />
              )}
            </CardContent>
          </Card>
        </>
      )}
    </div>
  );
};
