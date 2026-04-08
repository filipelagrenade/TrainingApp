import { AppShell } from "@/components/layout/app-shell";
import { TemplateLibraryScreen } from "@/components/templates/template-library-screen";

export default function TemplatesPage() {
  return (
    <AppShell>
      <main className="max-w-6xl mx-auto px-4 py-6">
        <TemplateLibraryScreen />
      </main>
    </AppShell>
  );
}
