"use client";

import Link from "next/link";

import type { Exercise } from "@/lib/types";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";

export const TemplateBuilder = ({
  exercises: _exercises,
  onExerciseCreated: _onExerciseCreated,
}: {
  exercises: Exercise[];
  onExerciseCreated?: (exercise: Exercise) => void;
}) => (
  <Card>
    <CardHeader>
      <CardTitle>Template builder moved</CardTitle>
      <CardDescription>
        Add and shape day templates inside the guided program flow.
      </CardDescription>
    </CardHeader>
    <CardContent>
      <Button asChild variant="outline">
        <Link href="/programs/new">Open guided wizard</Link>
      </Button>
    </CardContent>
  </Card>
);
