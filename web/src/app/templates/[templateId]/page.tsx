import { AppShell } from "@/components/layout/app-shell";
import { TemplateDetailScreen } from "@/components/templates/template-detail-screen";

export default async function TemplateDetailPage({
  params,
}: {
  params: Promise<{ templateId: string }>;
}) {
  const { templateId } = await params;

  return (
    <AppShell>
      <TemplateDetailScreen templateId={templateId} />
    </AppShell>
  );
}
