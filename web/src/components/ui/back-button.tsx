"use client";

import { ArrowLeft } from "lucide-react";
import { useRouter } from "next/navigation";

import { cn } from "@/lib/utils";

export const BackButton = ({
  fallbackHref = "/",
  label = "Back",
  className,
}: {
  fallbackHref?: string;
  label?: string;
  className?: string;
}) => {
  const router = useRouter();

  return (
    <button
      type="button"
      className={cn(
        "inline-flex items-center gap-1.5 text-sm text-ink-muted transition-colors hover:text-ink focus-visible:outline-none focus-visible:text-ink",
        className,
      )}
      onClick={() => {
        if (typeof window !== "undefined" && window.history.length > 1) {
          router.back();
          return;
        }
        router.push(fallbackHref);
      }}
    >
      <ArrowLeft className="h-3.5 w-3.5" />
      <span>{label}</span>
    </button>
  );
};
