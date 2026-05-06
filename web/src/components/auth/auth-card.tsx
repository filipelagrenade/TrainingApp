"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { useState } from "react";
import { useForm } from "react-hook-form";
import { toast } from "sonner";
import { z } from "zod";

import { apiClient } from "@/lib/api-client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { cn } from "@/lib/utils";

const registerSchema = z.object({
  displayName: z.string().min(2).max(40),
  email: z.string().email(),
  password: z.string().min(8),
});

const loginSchema = registerSchema.omit({ displayName: true });

type AuthCardProps = {
  onSuccess: () => void;
};

type Mode = "login" | "register";

export const AuthCard = ({ onSuccess }: AuthCardProps) => {
  const queryClient = useQueryClient();
  const [mode, setMode] = useState<Mode>("login");

  const loginForm = useForm<z.infer<typeof loginSchema>>({
    resolver: zodResolver(loginSchema),
    defaultValues: { email: "", password: "" },
  });
  const registerForm = useForm<z.infer<typeof registerSchema>>({
    resolver: zodResolver(registerSchema),
    defaultValues: { displayName: "", email: "", password: "" },
  });

  const loginMutation = useMutation({
    mutationFn: apiClient.login,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["me"] });
      toast.success("Signed in");
      onSuccess();
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const registerMutation = useMutation({
    mutationFn: apiClient.register,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["me"] });
      toast.success("Account created");
      onSuccess();
    },
    onError: (error: Error) => toast.error(error.message),
  });

  return (
    <div className="w-full max-w-md mx-auto space-y-10">
      <header className="space-y-3 text-center">
        <p className="eyebrow">A training journal</p>
        <h1 className="font-display text-5xl font-extrabold tracking-editorial text-ink leading-none">
          LiftIQ
        </h1>
        <p className="text-sm text-ink-muted leading-6 max-w-xs mx-auto">
          Lift with intention. Let the numbers speak.
        </p>
      </header>

      <div className="flex justify-center gap-6 border-b border-rule">
        {(["login", "register"] as Mode[]).map((m) => (
          <button
            key={m}
            type="button"
            onClick={() => setMode(m)}
            className={cn(
              "relative pb-3 text-sm transition-colors",
              mode === m ? "text-ink" : "text-ink-muted hover:text-ink",
            )}
          >
            {m === "login" ? "Sign in" : "Create account"}
            {mode === m ? (
              <span className="absolute -bottom-px left-0 right-0 h-px bg-ink" />
            ) : null}
          </button>
        ))}
      </div>

      {mode === "login" ? (
        <form
          className="space-y-5"
          onSubmit={loginForm.handleSubmit((values) => loginMutation.mutate(values))}
        >
          <Field id="login-email" label="Email">
            <Input id="login-email" type="email" {...loginForm.register("email")} />
          </Field>
          <Field id="login-password" label="Password">
            <Input id="login-password" type="password" {...loginForm.register("password")} />
          </Field>
          <Button className="w-full" type="submit" disabled={loginMutation.isPending}>
            {loginMutation.isPending ? "Signing in…" : "Sign in"}
          </Button>
        </form>
      ) : (
        <form
          className="space-y-5"
          onSubmit={registerForm.handleSubmit((values) => registerMutation.mutate(values))}
        >
          <Field id="register-name" label="Display name">
            <Input id="register-name" {...registerForm.register("displayName")} />
          </Field>
          <Field id="register-email" label="Email">
            <Input id="register-email" type="email" {...registerForm.register("email")} />
          </Field>
          <Field id="register-password" label="Password">
            <Input id="register-password" type="password" {...registerForm.register("password")} />
          </Field>
          <Button className="w-full" type="submit" disabled={registerMutation.isPending}>
            {registerMutation.isPending ? "Creating account…" : "Create account"}
          </Button>
        </form>
      )}
    </div>
  );
};

const Field = ({
  id,
  label,
  children,
}: {
  id: string;
  label: string;
  children: React.ReactNode;
}) => (
  <div className="space-y-2">
    <Label htmlFor={id}>{label}</Label>
    {children}
  </div>
);
