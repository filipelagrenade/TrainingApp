import type { Transition, Variants } from "framer-motion";

export const editorialEase = [0.16, 1, 0.3, 1] as const;

export const fadeRise: Variants = {
  hidden: { opacity: 0, y: 8 },
  visible: {
    opacity: 1,
    y: 0,
    transition: { duration: 0.28, ease: editorialEase },
  },
};

export const fadeIn: Variants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: { duration: 0.2, ease: editorialEase },
  },
};

export const stagger = (childDelay = 0.04): Variants => ({
  hidden: {},
  visible: {
    transition: {
      staggerChildren: childDelay,
      delayChildren: 0.04,
    },
  },
});

export const sheetSpring: Transition = {
  type: "spring",
  stiffness: 320,
  damping: 32,
  mass: 0.9,
};

export const setComplete: Variants = {
  initial: { backgroundColor: "hsla(0, 0%, 0%, 0)" },
  flash: {
    backgroundColor: [
      "hsla(0, 0%, 0%, 0)",
      "hsl(var(--accent-soft))",
      "hsla(0, 0%, 0%, 0)",
    ],
    transition: { duration: 0.9, ease: "easeOut" },
  },
};

export const numberRoll: Variants = {
  hidden: { opacity: 0, y: 6 },
  visible: {
    opacity: 1,
    y: 0,
    transition: { duration: 0.32, ease: editorialEase },
  },
};

export const navUnderline = {
  layout: true,
  transition: { type: "spring", stiffness: 420, damping: 38 } satisfies Transition,
};
