"use client";

import Link from "next/link";

import type { Exercise } from "@/lib/types";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";

export const ProgramBuilder = ({
  exercises: _exercises,
  onExerciseCreated: _onExerciseCreated,
}: {
  exercises: Exercise[];
  onExerciseCreated?: (exercise: Exercise) => void;
}) => (
  <Card>
    <CardHeader>
      <CardTitle>Program builder moved</CardTitle>
      <CardDescription>
        The active flow is now the dedicated mobile-first wizard.
      </CardDescription>
    </CardHeader>
    <CardContent>
      <Button asChild>
        <Link href="/programs/new">Open guided wizard</Link>
      </Button>
    </CardContent>
  </Card>
);
