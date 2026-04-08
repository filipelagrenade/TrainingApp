"use client";

import { ChevronLeft } from "lucide-react";
import { useRouter } from "next/navigation";

import { Button } from "@/components/ui/button";

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
    <Button
      className={className}
      type="button"
      variant="ghost"
      onClick={() => {
        if (typeof window !== "undefined" && window.history.length > 1) {
          router.back();
          return;
        }

        router.push(fallbackHref);
      }}
    >
      <ChevronLeft className="h-4 w-4" />
      {label}
    </Button>
  );
};
