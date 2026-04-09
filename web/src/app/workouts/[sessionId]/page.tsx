import { AppShell } from "@/components/layout/app-shell";
import { WorkoutEditor } from "@/components/workouts/workout-editor";

export default async function WorkoutPage({
  params,
}: {
  params: Promise<{ sessionId: string }>;
}) {
  const resolvedParams = await params;

  return (
    <AppShell showNav={false}>
      <div className="mx-auto max-w-3xl">
        <WorkoutEditor sessionId={resolvedParams.sessionId} />
      </div>
    </AppShell>
  );
}
