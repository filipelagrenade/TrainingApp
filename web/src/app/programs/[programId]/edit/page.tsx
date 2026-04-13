import { AppShell } from "@/components/layout/app-shell";
import { ProgramWizard } from "@/components/programs/program-wizard";

export default async function EditProgramPage({
  params,
}: {
  params: Promise<{ programId: string }>;
}) {
  const resolvedParams = await params;

  return (
    <AppShell>
      <div className="mx-auto max-w-4xl">
        <ProgramWizard programId={resolvedParams.programId} />
      </div>
    </AppShell>
  );
}
