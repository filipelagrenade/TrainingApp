import { ProgramLibraryScreen } from "@/components/programs/program-library-screen";

export default function ProgramsPage() {
  return (
    <div className="min-h-screen bg-[linear-gradient(180deg,_#faf7f1_0%,_#f0ebe3_100%)]">
      <main className="max-w-6xl mx-auto px-4 py-6">
        <ProgramLibraryScreen />
      </main>
    </div>
  );
}
