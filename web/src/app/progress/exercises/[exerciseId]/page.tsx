import { AppShell } from "@/components/layout/app-shell";
import { ExerciseProgressScreen } from "@/components/progress/exercise-progress-screen";

export default async function ExerciseProgressPage({
  params,
}: {
  params: Promise<{ exerciseId: string }>;
}) {
  const resolvedParams = await params;

  return (
    <AppShell>
      <ExerciseProgressScreen exerciseId={resolvedParams.exerciseId} />
    </AppShell>
  );
}
