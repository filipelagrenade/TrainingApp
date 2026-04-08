import { AppShell } from "@/components/layout/app-shell";
import { ProgramDetailScreen } from "@/components/programs/program-detail-screen";

export default async function ProgramDetailPage({
  params,
}: {
  params: Promise<{ programId: string }>;
}) {
  const { programId } = await params;

  return (
    <AppShell>
      <ProgramDetailScreen programId={programId} />
    </AppShell>
  );
}
