"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { CalendarDays, Plus, Scale, Trash2, TrendingUp } from "lucide-react";
import { useState } from "react";
import { toast } from "sonner";

import { apiClient } from "@/lib/api-client";
import { AuthCard } from "@/components/auth/auth-card";
import { LineTrendChart } from "@/components/progress/charts/line-trend-chart";
import { BackButton } from "@/components/ui/back-button";
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
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { MetricCard } from "@/components/ui/metric-card";
import { NullableNumberInput } from "@/components/ui/nullable-number-input";
import { ScreenHero } from "@/components/ui/screen-hero";
import { Skeleton } from "@/components/ui/skeleton";

// Body circumference fields (centimetres) the log dialog offers alongside bodyweight.
const MEASUREMENT_FIELDS: Array<{ key: string; label: string }> = [
  { key: "waist", label: "Waist" },
  { key: "chest", label: "Chest" },
  { key: "arms", label: "Arms" },
  { key: "thighs", label: "Thighs" },
  { key: "hips", label: "Hips" },
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

  const unit = meQuery.data.user.preferredUnit;
  const data = metricsQuery.data;
  const trend = data?.weightTrend ?? [];
  const change =
    trend.length >= 2 ? Number((trend[trend.length - 1].value - trend[0].value).toFixed(1)) : null;

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
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Log body metrics</DialogTitle>
          <DialogDescription>Track your bodyweight and optional measurements over time.</DialogDescription>
        </DialogHeader>
        <div className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="bw-weight">Bodyweight ({unit})</Label>
            <NullableNumberInput
              id="bw-weight"
              value={weight}
              onChange={setWeight}
              placeholder={`Weight in ${unit}`}
              min={0}
              step={0.1}
            />
          </div>
          <div className="space-y-2">
            <Label>Measurements (cm)</Label>
            <div className="grid grid-cols-2 gap-2">
              {MEASUREMENT_FIELDS.map((field) => (
                <div key={field.key} className="space-y-1">
                  <Label htmlFor={`bw-${field.key}`} className="text-xs text-ink-muted">
                    {field.label}
                  </Label>
                  <NullableNumberInput
                    id={`bw-${field.key}`}
                    value={measurements[field.key] ?? null}
                    onChange={(value) =>
                      setMeasurements((current) => ({ ...current, [field.key]: value }))
                    }
                    placeholder="cm"
                    min={0}
                    step={0.1}
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
    <div className="app-grid">
      <ScreenHero
        eyebrow="Body"
        title="Body metrics"
        description="Bodyweight and measurement history."
        actions={<BackButton fallbackHref="/progress" label="Back to progress" />}
        stats={
          <>
            <MetricCard
              icon={Scale}
              label="Latest"
              value={data?.latest?.weight != null ? `${data.latest.weight} ${unit}` : "-"}
            />
            <MetricCard
              icon={TrendingUp}
              label="Change"
              value={change === null ? "-" : `${change > 0 ? "+" : ""}${change} ${unit}`}
            />
            <MetricCard icon={CalendarDays} label="Entries" value={String(data?.entries.length ?? 0)} />
          </>
        }
      />

      <Card>
        <CardHeader className="flex-row items-start justify-between gap-3 space-y-0">
          <div>
            <CardTitle>Weight trend</CardTitle>
            <CardDescription>Your logged bodyweight over time.</CardDescription>
          </div>
          {logDialog}
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
            <EmptyHint copy="Log at least two bodyweight entries to see your trend." />
          )}
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>History</CardTitle>
          <CardDescription>Every entry, most recent first.</CardDescription>
        </CardHeader>
        <CardContent className="space-y-3">
          {data?.entries.length ? (
            data.entries.map((entry) => (
              <div
                key={entry.id}
                className="flex items-start justify-between gap-3 rounded-md border border-rule bg-surface p-4"
              >
                <div className="min-w-0">
                  <div className="flex flex-wrap items-baseline gap-2">
                    <p className="font-semibold text-ink">
                      {entry.weight != null ? `${entry.weight} ${unit}` : "—"}
                    </p>
                    <p className="text-sm text-ink-muted">{new Date(entry.recordedAt).toLocaleDateString()}</p>
                  </div>
                  {entry.measurements && Object.keys(entry.measurements).length ? (
                    <p className="mt-1 text-sm text-ink-muted">
                      {Object.entries(entry.measurements)
                        .map(([key, value]) => `${key} ${value}cm`)
                        .join(" · ")}
                    </p>
                  ) : null}
                  {entry.note ? <p className="mt-1 text-sm text-ink-muted">{entry.note}</p> : null}
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
            <EmptyHint copy="No entries yet. Log your first bodyweight to get started." />
          )}
        </CardContent>
      </Card>
    </div>
  );
};

const EmptyHint = ({ copy }: { copy: string }) => (
  <div className="rounded-md border border-dashed border-rule p-4 text-sm text-ink-muted">{copy}</div>
);
