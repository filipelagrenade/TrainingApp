import { ProgramWizard } from "@/components/programs/program-wizard";

export default function NewProgramPage() {
  return (
    <div className="min-h-screen bg-[linear-gradient(180deg,_#faf7f1_0%,_#f0ebe3_100%)]">
      <main className="max-w-4xl mx-auto px-4 py-6">
        <ProgramWizard />
      </main>
    </div>
  );
}
