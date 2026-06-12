import { AppShell } from "@/components/layout/app-shell";
import { ExerciseLibraryScreen } from "@/components/exercises/exercise-library-screen";

export default function ExercisesPage() {
  return (
    <AppShell>
      <ExerciseLibraryScreen />
    </AppShell>
  );
}
