"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { ArrowLeft, ArrowRight, Copy, GripVertical, Plus, Sparkles, Wand2 } from "lucide-react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect, useMemo, useState } from "react";
import { toast } from "sonner";

import { apiClient } from "@/lib/api-client";
import {
  createBlankDayDraft,
  generatedProgramToDraftDays,
  programToDraftDays,
  templateToDayDraft,
} from "@/lib/programs";
import type {
  CreateProgramInput,
  DraftExercise,
  DraftTemplateDay,
  Exercise,
  ProgramGoal,
} from "@/lib/types";
import { DayEditorSheet } from "@/components/programs/day-editor-sheet";
import { TemplateLibrarySheet } from "@/components/programs/template-library-sheet";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { NullableNumberInput } from "@/components/ui/nullable-number-input";
import { Progress } from "@/components/ui/progress";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";

const goalOptions: ProgramGoal[] = [
  "Hypertrophy",
  "Strength",
  "General Fitness",
  "Powerlifting",
];

const moveItem = <T,>(items: T[], from: number, to: number) => {
  const next = [...items];
  const [item] = next.splice(from, 1);
  next.splice(to, 0, item);
  return next;
};

const sanitizeDraftExercise = (exercise: DraftExercise): DraftExercise => ({
  exerciseId: exercise.exerciseId,
  exerciseName: exercise.exerciseName,
  sets: exercise.sets,
  repMin: exercise.repMin,
  repMax: exercise.repMax,
  restSeconds: exercise.restSeconds ?? 90,
  startWeight: exercise.startWeight ?? null,
  increment: exercise.increment ?? 2.5,
  deloadFactor: exercise.deloadFactor ?? 0.9,
  targetRpe: exercise.targetRpe ?? null,
  loadTypeOverride: exercise.loadTypeOverride ?? null,
  machineOverride: exercise.machineOverride?.trim() || undefined,
  attachmentOverride: exercise.attachmentOverride?.trim() || undefined,
  unilateral: exercise.unilateral ?? false,
  notes: exercise.notes?.trim() || undefined,
});

const sanitizeDay = (day: DraftTemplateDay): DraftTemplateDay => ({
  dayLabel: day.dayLabel.trim(),
  title: day.title.trim(),
  description: day.description?.trim() || undefined,
  estimatedMinutes: day.estimatedMinutes ?? 55,
  exercises: day.exercises
    .filter((exercise) => Boolean(exercise.exerciseId))
    .map(sanitizeDraftExercise),
});

const renumberDays = (drafts: DraftTemplateDay[]) =>
  drafts.map((day, index) => ({
    ...day,
    dayLabel: `Day ${index + 1}`,
  }));

export const ProgramWizard = ({ programId }: { programId?: string }) => {
  const queryClient = useQueryClient();
  const router = useRouter();
  const isEditMode = Boolean(programId);
  const [step, setStep] = useState(0);
  const [name, setName] = useState("");
  const [goal, setGoal] = useState<ProgramGoal>("Hypertrophy");
  const [description, setDescription] = useState("");
  const [durationWeeks, setDurationWeeks] = useState(8);
  const [daysPerWeek, setDaysPerWeek] = useState(4);
  const [difficulty, setDifficulty] = useState<"Beginner" | "Intermediate" | "Advanced">(
    "Intermediate",
  );
  const [generationPrompt, setGenerationPrompt] = useState("");
  const [days, setDays] = useState<DraftTemplateDay[]>([]);
  const [editingDayIndex, setEditingDayIndex] = useState<number | null>(null);
  const [templateSheetOpen, setTemplateSheetOpen] = useState(false);
  const [hydratedProgramId, setHydratedProgramId] = useState<string | null>(null);

  const exercisesQuery = useQuery({ queryKey: ["exercises"], queryFn: apiClient.getExercises });
  const templatesQuery = useQuery({ queryKey: ["templates"], queryFn: apiClient.getTemplates });
  const programQuery = useQuery({
    queryKey: ["program", programId],
    queryFn: () => apiClient.getProgram(programId!),
    enabled: isEditMode,
  });

  const defaultExercise = useMemo(() => exercisesQuery.data?.[0], [exercisesQuery.data]);

  useEffect(() => {
    if (!programQuery.data || !programId || hydratedProgramId === programId) {
      return;
    }

    setName(programQuery.data.name);
    setGoal(programQuery.data.goal as ProgramGoal);
    setDescription(programQuery.data.description ?? "");
    setDurationWeeks(programQuery.data.weeks.length || 8);
    setDaysPerWeek(programQuery.data.weeks[0]?.workouts.length || 4);
    setDays(programToDraftDays(programQuery.data));
    setHydratedProgramId(programId);
  }, [hydratedProgramId, programId, programQuery.data]);

  const generateMutation = useMutation({
    mutationFn: (prompt: string) => apiClient.generateProgramDraft({ prompt }),
    onSuccess: (draft) => {
      setName(draft.name);
      setGoal(draft.goal);
      setDescription(draft.description);
      setDurationWeeks(draft.durationWeeks);
      setDaysPerWeek(draft.daysPerWeek);
      setDifficulty(draft.difficulty);
      setDays(generatedProgramToDraftDays(draft));
      setStep(1);
      toast.success("Program draft generated");
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const saveProgramMutation = useMutation({
    mutationFn: async () => {
      const sanitizedDays = days.map(sanitizeDay);
      const payload: CreateProgramInput = {
        name: name.trim(),
        goal,
        description: description.trim() || undefined,
        durationWeeks,
        daysPerWeek,
        days: sanitizedDays,
      };

      if (programId) {
        await apiClient.updateProgram(programId, payload);
        return { failedTemplateCount: 0, programId, updated: true };
      }

      const program = await apiClient.createProgram(payload);
      await apiClient.activateProgram(program.id);
      return { failedTemplateCount: 0, programId: program.id, updated: false };
    },
    onSuccess: async ({ failedTemplateCount, updated }) => {
      await queryClient.invalidateQueries({ queryKey: ["programs"] });
      await queryClient.invalidateQueries({ queryKey: ["active-program"] });
      await queryClient.invalidateQueries({ queryKey: ["templates"] });
      if (updated) {
        await queryClient.invalidateQueries({ queryKey: ["program", programId] });
        toast.success("Program updated");
        router.push("/programs");
        return;
      }

      toast.success("Program created and activated");
      router.push("/");
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const steps = [
    { title: "Details", description: "Set the block structure and optional AI draft." },
    { title: "Days", description: "Build, duplicate, and reorder your sessions." },
    { title: "Review", description: "Check the weekly flow before creating." },
  ];

  const canContinueFromDetails =
    name.trim().length >= 3 && durationWeeks >= 4 && daysPerWeek >= 2;
  const canContinueFromDays =
    days.length === daysPerWeek &&
    days.every(
      (day) => day.exercises.length > 0 && day.exercises.every((exercise) => Boolean(exercise.exerciseId)),
    );

  if (isEditMode && programQuery.isLoading && hydratedProgramId !== programId) {
    return (
      <Card>
        <CardContent className="pt-6">
          <p className="text-sm text-muted-foreground">Loading program...</p>
        </CardContent>
      </Card>
    );
  }

  return (
    <div className="space-y-6">
      <Card className="border-border/70 bg-card/95">
        <CardHeader className="space-y-4">
          <div className="flex items-center justify-between gap-3">
            <div>
              <CardTitle className="text-2xl">{isEditMode ? "Edit program" : "Create program"}</CardTitle>
              <CardDescription>
                Build this the way you’d actually use it on your phone at the gym.
              </CardDescription>
            </div>
            <Button asChild variant="ghost">
              <Link href={isEditMode ? "/programs" : "/"}>
                <ArrowLeft className="h-4 w-4" />
                Back
              </Link>
            </Button>
          </div>
          <Progress value={((step + 1) / steps.length) * 100} />
          <div className="grid grid-cols-3 gap-2">
            {steps.map((item, index) => (
              <div
                key={item.title}
                className={`rounded-2xl border p-3 text-left ${
                  index === step ? "border-primary/40 bg-primary/5" : "border-border/70 bg-background/70"
                }`}
              >
                <p className="text-sm font-semibold">{item.title}</p>
                <p className="mt-1 text-xs text-muted-foreground">{item.description}</p>
              </div>
            ))}
          </div>
        </CardHeader>
      </Card>

      {step === 0 ? (
        <Card>
          <CardHeader>
            <CardTitle>Program details</CardTitle>
            <CardDescription>
              Start manually or generate a first draft, then shape the days yourself.
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-6">
            <div className="grid gap-4 sm:grid-cols-2">
              <div className="space-y-2">
                <Label htmlFor="program-name">Program name</Label>
                <Input id="program-name" value={name} onChange={(event) => setName(event.target.value)} />
              </div>
              <div className="space-y-2">
                <Label>Goal</Label>
                <Select value={goal} onValueChange={(value) => setGoal(value as ProgramGoal)}>
                  <SelectTrigger>
                    <SelectValue placeholder="Select goal" />
                  </SelectTrigger>
                  <SelectContent>
                    {goalOptions.map((option) => (
                      <SelectItem key={option} value={option}>
                        {option}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </div>
            <div className="space-y-2">
              <Label htmlFor="program-description">Description</Label>
              <Textarea
                id="program-description"
                value={description}
                onChange={(event) => setDescription(event.target.value)}
              />
            </div>
            <div className="grid gap-4 sm:grid-cols-3">
              <div className="space-y-2">
                <Label htmlFor="duration-weeks">Duration (weeks)</Label>
                <NullableNumberInput
                  id="duration-weeks"
                  min={4}
                  max={16}
                  value={durationWeeks}
                  onChange={(value) => setDurationWeeks(value ?? 8)}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="days-per-week">Days per week</Label>
                <NullableNumberInput
                  id="days-per-week"
                  min={2}
                  max={6}
                  value={daysPerWeek}
                  onChange={(value) => setDaysPerWeek(value ?? 4)}
                />
              </div>
              <div className="space-y-2">
                <Label>Difficulty</Label>
                <Select
                  value={difficulty}
                  onValueChange={(value) =>
                    setDifficulty(value as "Beginner" | "Intermediate" | "Advanced")
                  }
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Select difficulty" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="Beginner">Beginner</SelectItem>
                    <SelectItem value="Intermediate">Intermediate</SelectItem>
                    <SelectItem value="Advanced">Advanced</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>

            <div className="rounded-2xl border border-border/70 bg-background/70 p-4">
              <div className="flex items-center gap-2">
                <Sparkles className="h-4 w-4 text-primary" />
                <p className="font-semibold">Optional AI draft</p>
              </div>
              <p className="mt-2 text-sm text-muted-foreground">
                Use this to get a starting structure. The generated result still lands in the manual editor.
              </p>
              <Textarea
                className="mt-4"
                placeholder="e.g. 4-day upper lower hypertrophy with more machine work"
                value={generationPrompt}
                onChange={(event) => setGenerationPrompt(event.target.value)}
              />
              <Button
                className="mt-4 w-full sm:w-auto"
                disabled={generationPrompt.trim().length < 4 || generateMutation.isPending}
                onClick={() => generateMutation.mutate(generationPrompt)}
                variant="outline"
              >
                <Wand2 className="h-4 w-4" />
                {generateMutation.isPending ? "Generating..." : "Generate draft"}
              </Button>
            </div>
          </CardContent>
        </Card>
      ) : null}

      {step === 1 ? (
        <Card>
          <CardHeader>
            <CardTitle>Program days</CardTitle>
            <CardDescription>
              Duplicate days, reorder them, or pull from your template library.
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex flex-wrap gap-3">
              <Button
                disabled={days.length >= daysPerWeek}
                onClick={() =>
                  setDays((current) => [
                    ...current,
                    createBlankDayDraft(defaultExercise, current.length + 1),
                  ])
                }
                variant="outline"
              >
                <Plus className="h-4 w-4" />
                Blank day
              </Button>
              <Button disabled={days.length >= daysPerWeek} onClick={() => setTemplateSheetOpen(true)} variant="outline">
                <Plus className="h-4 w-4" />
                From template
              </Button>
            </div>

            <div className="space-y-3">
              {days.map((day, index) => (
                <div key={`${day.title}-${index}`} className="rounded-2xl border border-border/70 bg-card p-4 shadow-sm">
                  <div className="flex items-start gap-3">
                    <div className="mt-1 rounded-full bg-secondary p-2 text-secondary-foreground">
                      <GripVertical className="h-4 w-4" />
                    </div>
                    <div className="min-w-0 flex-1">
                      <div className="flex items-center justify-between gap-3">
                        <div>
                          <p className="text-sm text-muted-foreground">{day.dayLabel}</p>
                          <p className="font-semibold text-foreground">{day.title}</p>
                        </div>
                        <Badge variant="secondary">{day.exercises.length} exercises</Badge>
                      </div>
                      <p className="mt-2 text-sm text-muted-foreground">
                        {day.description || "Reusable workout day"}
                      </p>
                      <div className="mt-4 flex flex-wrap gap-2">
                        <Button size="sm" variant="outline" onClick={() => setEditingDayIndex(index)}>
                          Edit
                        </Button>
                        <Button
                          size="sm"
                          variant="outline"
                          onClick={() =>
                            setDays((current) =>
                              renumberDays([
                                ...current.slice(0, index + 1),
                                {
                                  ...day,
                                  title: `${day.title} Copy`,
                                },
                                ...current.slice(index + 1),
                              ]),
                            )
                          }
                        >
                          <Copy className="h-4 w-4" />
                          Duplicate
                        </Button>
                        <Button
                          size="sm"
                          variant="ghost"
                          disabled={index === 0}
                          onClick={() =>
                            setDays((current) => renumberDays(moveItem(current, index, index - 1)))
                          }
                        >
                          Move up
                        </Button>
                        <Button
                          size="sm"
                          variant="ghost"
                          disabled={index === days.length - 1}
                          onClick={() =>
                            setDays((current) => renumberDays(moveItem(current, index, index + 1)))
                          }
                        >
                          Move down
                        </Button>
                        <Button
                          size="sm"
                          variant="ghost"
                          onClick={() => setDays((current) => renumberDays(current.filter((_, dayIndex) => dayIndex !== index)))}
                        >
                          Remove
                        </Button>
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
            {days.length === 0 ? (
              <div className="rounded-2xl border border-dashed border-border/80 p-6 text-center text-sm text-muted-foreground">
                Add your first day manually or pull one from your template library.
              </div>
            ) : null}
          </CardContent>
        </Card>
      ) : null}

      {step === 2 ? (
        <Card>
          <CardHeader>
            <CardTitle>Review</CardTitle>
            <CardDescription>
              {isEditMode
                ? "Review the weekly structure before saving your changes."
                : "This creates the program and auto-saves each day to your template library."}
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="grid gap-3 sm:grid-cols-3">
              <SummaryPill label="Duration" value={`${durationWeeks} weeks`} />
              <SummaryPill label="Days/week" value={`${daysPerWeek}`} />
              <SummaryPill label="Difficulty" value={difficulty} />
            </div>
            <div className="rounded-2xl border border-border/70 bg-background/70 p-4">
              <p className="font-semibold text-foreground">{name}</p>
              <p className="mt-1 text-sm text-muted-foreground">{description}</p>
            </div>
            <div className="space-y-3">
              {days.map((day, index) => (
                <div key={`${day.title}-${index}`} className="rounded-2xl border border-border/70 bg-card p-4">
                  <div className="flex items-center justify-between gap-3">
                    <div>
                      <p className="text-sm text-muted-foreground">{day.dayLabel}</p>
                      <p className="font-semibold">{day.title}</p>
                    </div>
                    <Badge variant="secondary">{day.exercises.length} exercises</Badge>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      ) : null}

      <div className="sticky bottom-4 z-10 flex items-center justify-between gap-3 rounded-2xl border border-border/70 bg-card/95 p-4 shadow-lg backdrop-blur">
        <Button disabled={step === 0} onClick={() => setStep((current) => current - 1)} variant="outline">
          Previous
        </Button>
        {step < 2 ? (
          <Button
            disabled={(step === 0 && !canContinueFromDetails) || (step === 1 && !canContinueFromDays)}
            onClick={() => {
              if (step === 0 && days.length === 0) {
                setDays(
                  Array.from({ length: daysPerWeek }, (_, index) =>
                    createBlankDayDraft(defaultExercise, index + 1),
                  ),
                );
              }
              setStep((current) => current + 1);
            }}
          >
            Next
            <ArrowRight className="h-4 w-4" />
          </Button>
        ) : (
          <Button
            disabled={saveProgramMutation.isPending || !canContinueFromDays}
            onClick={() => saveProgramMutation.mutate()}
          >
            {saveProgramMutation.isPending
              ? isEditMode
                ? "Saving..."
                : "Creating..."
              : isEditMode
                ? "Save changes"
                : "Create and activate"}
          </Button>
        )}
      </div>

      <DayEditorSheet
        day={editingDayIndex === null ? null : days[editingDayIndex]}
        exercises={exercisesQuery.data ?? []}
        onOpenChange={(open) => {
          if (!open) {
            setEditingDayIndex(null);
          }
        }}
        onSave={(nextDay) =>
          setDays((current) =>
            current.map((day, index) =>
              index === editingDayIndex ? { ...nextDay, dayLabel: `Day ${index + 1}` } : day,
            ),
          )
        }
        open={editingDayIndex !== null}
      />

      <TemplateLibrarySheet
        onOpenChange={setTemplateSheetOpen}
        onSelect={(template) =>
          setDays((current) => [...current, templateToDayDraft(template, current.length + 1)])
        }
        open={templateSheetOpen}
        templates={templatesQuery.data ?? []}
      />
    </div>
  );
};

const SummaryPill = ({ label, value }: { label: string; value: string }) => (
  <div className="rounded-2xl border border-border/70 bg-card p-4">
    <p className="text-sm text-muted-foreground">{label}</p>
    <p className="mt-1 font-semibold text-foreground">{value}</p>
  </div>
);
