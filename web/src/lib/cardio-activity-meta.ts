import {
  Activity,
  Bike,
  Dumbbell,
  Footprints,
  MountainSnow,
  PersonStanding,
  Waves,
} from "lucide-react";
import type { LucideIcon } from "lucide-react";

import type { CardioActivity } from "@/lib/types";

/** Icon + human label for every cardio activity in the backend enum. */
export const CARDIO_ACTIVITY_META: Record<CardioActivity, { label: string; icon: LucideIcon }> = {
  TREADMILL: { label: "Treadmill", icon: Footprints },
  BIKE: { label: "Bike", icon: Bike },
  ROWER: { label: "Rower", icon: Waves },
  STAIR: { label: "Stairs", icon: MountainSnow },
  ELLIPTICAL: { label: "Elliptical", icon: Dumbbell },
  OUTDOOR_RUN: { label: "Run", icon: PersonStanding },
  OUTDOOR_WALK: { label: "Walk", icon: Footprints },
  OUTDOOR_CYCLE: { label: "Outdoor ride", icon: Bike },
  OTHER: { label: "Other", icon: Activity },
};
