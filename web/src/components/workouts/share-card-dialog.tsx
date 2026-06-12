"use client";

import { Download, Share2 } from "lucide-react";
import { useCallback, useEffect, useRef, useState } from "react";
import { toast } from "sonner";

import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Segmented, type SegmentedOption } from "@/components/ui/segmented";
import { Skeleton } from "@/components/ui/skeleton";
import {
  renderShareCard,
  shareCardBlob,
  shareCardSlug,
  type ShareCardData,
  type ShareCardTheme,
} from "@/lib/share-card";

const THEME_OPTIONS: ReadonlyArray<SegmentedOption<ShareCardTheme>> = [
  { value: "dark", label: "Dark" },
  { value: "light", label: "Light" },
  { value: "transparent", label: "Transparent" },
];

/**
 * Story-ready share card preview with theme picker. "Share" uses the Web
 * Share API with file payloads when available and falls back to a PNG
 * download (which "Save image" always does).
 */
export const ShareCardDialog = ({
  open,
  onOpenChange,
  data,
}: {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  /** Memoize in the parent so the preview doesn't re-render needlessly. */
  data: ShareCardData;
}) => {
  const [theme, setTheme] = useState<ShareCardTheme>("dark");
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);
  const [exporting, setExporting] = useState(false);
  const canvasRef = useRef<HTMLCanvasElement | null>(null);

  useEffect(() => {
    if (!open) {
      return;
    }
    let cancelled = false;
    setPreviewUrl(null);
    void (async () => {
      // Web fonts must be resolved before the canvas measures/draws text.
      await document.fonts.ready;
      if (cancelled) {
        return;
      }
      try {
        const canvas = renderShareCard(data, theme);
        canvasRef.current = canvas;
        setPreviewUrl(canvas.toDataURL("image/png"));
      } catch (error) {
        toast.error(
          error instanceof Error ? error.message : "Could not render the share card",
        );
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [open, theme, data]);

  const exportFile = useCallback(async () => {
    const canvas = canvasRef.current ?? renderShareCard(data, theme);
    const blob = await shareCardBlob(canvas);
    return new File([blob], `liftiq-${shareCardSlug(data.heading)}.png`, {
      type: "image/png",
    });
  }, [data, theme]);

  const downloadFile = (file: File) => {
    const url = URL.createObjectURL(file);
    const anchor = document.createElement("a");
    anchor.href = url;
    anchor.download = file.name;
    anchor.click();
    URL.revokeObjectURL(url);
  };

  const handleSave = async () => {
    setExporting(true);
    try {
      downloadFile(await exportFile());
    } catch {
      toast.error("Could not save the image");
    } finally {
      setExporting(false);
    }
  };

  const handleShare = async () => {
    setExporting(true);
    try {
      const file = await exportFile();
      if (typeof navigator.share === "function" && navigator.canShare?.({ files: [file] })) {
        await navigator.share({ files: [file], title: data.heading });
      } else {
        downloadFile(file);
      }
    } catch (error) {
      // The user dismissing the OS share sheet is not an error.
      if (!(error instanceof DOMException && error.name === "AbortError")) {
        toast.error("Could not share the image");
      }
    } finally {
      setExporting(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent onOpenAutoFocus={(event) => event.preventDefault()}>
        <DialogHeader>
          <DialogTitle>Share</DialogTitle>
          <DialogDescription>
            A story-sized image of {data.heading} you can post or save.
          </DialogDescription>
        </DialogHeader>
        <div className="space-y-4">
          <div className="mx-auto h-[480px] w-[270px] overflow-hidden rounded-md border border-rule bg-surface-sunken">
            {previewUrl ? (
              // Data URLs are local renders; next/image adds nothing here.
              // eslint-disable-next-line @next/next/no-img-element
              <img
                src={previewUrl}
                alt={`Share card preview for ${data.heading}`}
                className="h-full w-full"
              />
            ) : (
              <Skeleton className="h-full w-full rounded-none" />
            )}
          </div>
          <Segmented size="sm" options={THEME_OPTIONS} value={theme} onChange={setTheme} />
        </div>
        <DialogFooter className="gap-2">
          <Button
            type="button"
            variant="outline"
            disabled={exporting || !previewUrl}
            onClick={() => void handleSave()}
          >
            <Download className="h-4 w-4" />
            Save image
          </Button>
          <Button
            type="button"
            variant="accent"
            disabled={exporting || !previewUrl}
            onClick={() => void handleShare()}
          >
            <Share2 className="h-4 w-4" />
            Share
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
};
