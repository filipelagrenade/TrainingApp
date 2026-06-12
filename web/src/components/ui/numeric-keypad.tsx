"use client";

import { useEffect } from "react";
import type { PointerEvent, ReactNode } from "react";

import { AnimatePresence, motion } from "framer-motion";
import { ArrowRight, Calculator, Delete } from "lucide-react";

import type { KeypadAction, KeypadFieldConfig } from "@/components/ui/keypad-context";
import { cn } from "@/lib/utils";

type NumericKeypadProps = {
  config: KeypadFieldConfig | null;
  draft: string;
  allowDecimal: boolean;
  onKey: (action: KeypadAction) => void;
  onIncrement: (direction: 1 | -1) => void;
  onNext: () => void;
  onDone: () => void;
  onQuickPick: (value: number | null) => void;
};

const RPE_VALUES = [6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5, 10];

const preventFocusSteal = (event: PointerEvent<HTMLButtonElement>) => {
  event.preventDefault();
};

type KeyProps = {
  children: ReactNode;
  onPress: () => void;
  className?: string;
  disabled?: boolean;
  ariaLabel?: string;
};

const Key = ({ ariaLabel, children, className, disabled, onPress }: KeyProps) => (
  <button
    type="button"
    aria-label={ariaLabel}
    disabled={disabled}
    onPointerDown={preventFocusSteal}
    onClick={onPress}
    className={cn(
      "num flex h-[var(--keypad-key-h)] items-center justify-center rounded-md",
      "bg-surface-sunken text-xl text-ink active:bg-surface",
      "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-accent",
      "disabled:opacity-30",
      className,
    )}
  >
    {children}
  </button>
);

export const NumericKeypad = ({
  allowDecimal,
  config,
  draft,
  onDone,
  onIncrement,
  onKey,
  onNext,
  onQuickPick,
}: NumericKeypadProps) => {
  const open = config !== null;

  useEffect(() => {
    if (!open) {
      return;
    }
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === "Escape") {
        onDone();
      }
    };
    window.addEventListener("keydown", onKeyDown);
    return () => window.removeEventListener("keydown", onKeyDown);
  }, [onDone, open]);

  const step = config?.increment ?? 1;
  const currentValue = config?.value ?? null;
  const preview = draft !== "" ? draft : currentValue !== null ? String(currentValue) : "—";
  const isRpe = config?.kind === "rpe";

  return (
    <AnimatePresence>
      {config && (
        <motion.div
          data-keypad=""
          initial={{ y: "100%" }}
          animate={{ y: 0 }}
          exit={{ y: "100%" }}
          transition={{ type: "spring", stiffness: 420, damping: 38 }}
          className={cn(
            "fixed inset-x-0 bottom-0 z-[60]",
            "border-t border-rule bg-surface-raised",
            "pb-[env(safe-area-inset-bottom)]",
          )}
        >
          <div className="mx-auto max-w-md px-3 pb-3 pt-2">
            <div className="flex items-center gap-3 pb-2">
              <div className="min-w-0 flex-1">
                <p className="eyebrow truncate">{config.label}</p>
                <p className={cn("num text-2xl text-ink", draft === "" && "text-ink-muted")}>
                  {preview}
                </p>
              </div>
              <button
                type="button"
                onPointerDown={preventFocusSteal}
                onClick={onDone}
                className={cn(
                  "rounded-md px-4 py-2 text-sm font-semibold text-accent",
                  "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-accent",
                )}
              >
                Done
              </button>
            </div>

            <div className="grid grid-cols-4 gap-1.5">
              {isRpe ? (
                <div className="col-span-3 grid grid-cols-3 gap-1.5">
                  {RPE_VALUES.map((rpe) => (
                    <Key key={rpe} onPress={() => onQuickPick(rpe)}>
                      {rpe}
                    </Key>
                  ))}
                  <Key className="col-span-3 text-base" onPress={() => onQuickPick(null)}>
                    Clear
                  </Key>
                </div>
              ) : (
                <div className="col-span-3 grid grid-cols-3 gap-1.5">
                  {["1", "2", "3", "4", "5", "6", "7", "8", "9"].map((digit) => (
                    <Key key={digit} onPress={() => onKey({ type: "digit", digit })}>
                      {digit}
                    </Key>
                  ))}
                  <Key
                    ariaLabel="Decimal point"
                    disabled={!allowDecimal}
                    onPress={() => onKey({ type: "decimal" })}
                  >
                    .
                  </Key>
                  <Key onPress={() => onKey({ type: "digit", digit: "0" })}>0</Key>
                  <Key ariaLabel="Backspace" onPress={() => onKey({ type: "backspace" })}>
                    <Delete className="h-5 w-5" />
                  </Key>
                </div>
              )}

              <div className="flex flex-col gap-1.5">
                <Key
                  ariaLabel={`Increase by ${step}`}
                  className="text-base"
                  onPress={() => onIncrement(1)}
                >
                  +{step}
                </Key>
                <Key
                  ariaLabel={`Decrease by ${step}`}
                  className="text-base"
                  onPress={() => onIncrement(-1)}
                >
                  −{step}
                </Key>
                {config.onPlateCalc && (
                  <Key ariaLabel="Plate calculator" onPress={config.onPlateCalc}>
                    <Calculator className="h-5 w-5" />
                  </Key>
                )}
                <Key
                  ariaLabel="Next field"
                  className="h-auto flex-1 gap-1 bg-accent text-base font-semibold text-accent-foreground active:bg-accent/90"
                  onPress={onNext}
                >
                  Next
                  <ArrowRight className="h-4 w-4" />
                </Key>
              </div>
            </div>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
};
