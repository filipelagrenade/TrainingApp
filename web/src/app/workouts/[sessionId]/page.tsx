import { WorkoutEditor } from "@/components/workouts/workout-editor";

export default async function WorkoutPage({
  params,
}: {
  params: Promise<{ sessionId: string }>;
}) {
  const resolvedParams = await params;

  return (
    <div className="min-h-screen bg-[linear-gradient(180deg,_#faf7f1_0%,_#f0ebe3_100%)]">
      <main className="mx-auto max-w-3xl px-4 py-4 sm:px-5 sm:py-5">
        <WorkoutEditor sessionId={resolvedParams.sessionId} />
      </main>
    </div>
  );
}
