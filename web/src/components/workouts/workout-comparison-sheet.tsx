"use client";

import { useQuery } from "@tanstack/react-query";
import { Minus, TrendingDown, TrendingUp } from "lucide-react";

import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
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

const DeltaBadge = ({ value }: { value: number | null }) => {
  if (value === null) return <span className="text-xs text-ink-muted">-</span>;

  const positive = value > 0;
  const neutral = value === 0;

  return (
    <Badge
      variant="outline"
      className={cn(
        "gap-1 font-mono text-xs",
        positive && "border-green-500/30 text-green-600",
        !positive && !neutral && "border-red-500/30 text-red-500",
      )}
    >
      {positive ? (
        <TrendingUp className="h-3 w-3" />
      ) : neutral ? (
        <Minus className="h-3 w-3" />
      ) : (
        <TrendingDown className="h-3 w-3" />
      )}
      {positive ? "+" : ""}
      {value}%
    </Badge>
  );
};

export const WorkoutComparisonSheet = ({
  sessionId,
  open,
  onOpenChange,
}: {
  sessionId: string | null;
  open: boolean;
  onOpenChange: (open: boolean) => void;
}) => {
  const comparisonQuery = useQuery({
    queryKey: ["workout-comparison", sessionId],
    queryFn: () => apiClient.getWorkoutComparison(sessionId!),
    enabled: open && !!sessionId,
    retry: false,
  });

  const comparison = comparisonQuery.data;

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent side="bottom" className="max-h-[85vh] overflow-y-auto">
        <SheetHeader>
          <SheetTitle>Workout comparison</SheetTitle>
          <SheetDescription>
            {comparison
              ? `You vs ${comparison.mateSession.displayName} — % improvement from your own previous sessions`
              : "Loading comparison..."}
          </SheetDescription>
        </SheetHeader>

        <div className="space-y-3 px-6 pb-6 pt-4">
          {comparisonQuery.isLoading ? (
            <div className="space-y-3">
              {Array.from({ length: 4 }).map((_, i) => (
                <Skeleton key={i} className="h-20" />
              ))}
            </div>
          ) : comparisonQuery.isError ? (
            <div className="rounded-md border border-dashed border-rule p-6 text-center text-sm text-ink-muted">
              {comparisonQuery.error instanceof Error
                ? comparisonQuery.error.message
                : "Comparison not available yet. Your mate may not have finished their workout."}
            </div>
          ) : comparison ? (
            comparison.exercises.map((exercise) => (
              <Card key={exercise.exerciseName}>
                <CardHeader className="pb-2">
                  <CardTitle className="text-sm">{exercise.exerciseName}</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <p className="text-[10px] uppercase tracking-[0.08em] text-ink-muted">You</p>
                      <div className="mt-1 flex flex-wrap gap-1.5">
                        <div className="space-y-1">
                          <p className="text-[10px] text-ink-muted">Volume</p>
                          <DeltaBadge value={exercise.myVolumeChange} />
                        </div>
                        <div className="space-y-1">
                          <p className="text-[10px] text-ink-muted">e1RM</p>
                          <DeltaBadge value={exercise.myE1rmChange} />
                        </div>
                      </div>
                    </div>
                    <div>
                      <p className="text-[10px] uppercase tracking-[0.08em] text-ink-muted">
                        {comparison.mateSession.displayName}
                      </p>
                      <div className="mt-1 flex flex-wrap gap-1.5">
                        <div className="space-y-1">
                          <p className="text-[10px] text-ink-muted">Volume</p>
                          <DeltaBadge value={exercise.mateVolumeChange} />
                        </div>
                        <div className="space-y-1">
                          <p className="text-[10px] text-ink-muted">e1RM</p>
                          <DeltaBadge value={exercise.mateE1rmChange} />
                        </div>
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))
          ) : null}
        </div>
      </SheetContent>
    </Sheet>
  );
};
