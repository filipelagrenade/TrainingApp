import { atom } from "jotai";

export const dashboardViewAtom = atom<"overview" | "programs" | "social">("overview");
export const createProgramOpenAtom = atom(false);
