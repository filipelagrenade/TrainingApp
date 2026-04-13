import { AppShell } from "@/components/layout/app-shell";
import { ProgramWizard } from "@/components/programs/program-wizard";

export default function NewProgramPage() {
  return (
    <AppShell>
      <div className="mx-auto max-w-4xl">
        <ProgramWizard />
      </div>
    </AppShell>
  );
}
