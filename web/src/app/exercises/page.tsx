import { ExerciseLibraryScreen } from "@/components/exercises/exercise-library-screen";

export default function ExercisesPage() {
  return (
    <div className="min-h-screen bg-[radial-gradient(circle_at_top_left,_rgba(253,230,138,0.18),_transparent_35%),radial-gradient(circle_at_top_right,_rgba(134,239,172,0.18),_transparent_35%),linear-gradient(180deg,_#faf7f1_0%,_#f4f1ea_100%)]">
      <main className="max-w-7xl mx-auto px-4 py-6">
        <ExerciseLibraryScreen />
      </main>
    </div>
  );
}
