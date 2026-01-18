/**
 * LiftIQ Web Dashboard - Home Page
 *
 * The main dashboard showing:
 * - Workout statistics overview
 * - Recent workout history
 * - Progress charts
 * - Quick actions
 */

import { Metadata } from 'next';
import { DashboardHeader } from '@/components/layout/dashboard-header';
import { DashboardShell } from '@/components/layout/dashboard-shell';
import { DashboardNav } from '@/components/layout/dashboard-nav';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Dumbbell, TrendingUp, Trophy, Clock } from 'lucide-react';

export const metadata: Metadata = {
  title: 'Dashboard',
  description: 'View your workout statistics and progress',
};

export default function DashboardPage(): JSX.Element {
  return (
    <div className="flex min-h-screen flex-col">
      <DashboardHeader />
      <div className="flex-1 flex">
        <DashboardNav />
        <DashboardShell>
          <div className="flex flex-col gap-8">
            {/* Page Header */}
            <div>
              <h1 className="text-3xl font-bold tracking-tight">Dashboard</h1>
              <p className="text-muted-foreground">
                Welcome back! Here&apos;s your training overview.
              </p>
            </div>

            {/* Stats Cards */}
            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
              <StatCard
                title="Total Workouts"
                value="127"
                description="+12 from last month"
                icon={<Dumbbell className="h-4 w-4 text-muted-foreground" />}
              />
              <StatCard
                title="This Week"
                value="4"
                description="2 remaining for goal"
                icon={<Clock className="h-4 w-4 text-muted-foreground" />}
              />
              <StatCard
                title="PRs This Month"
                value="8"
                description="+3 from last month"
                icon={<Trophy className="h-4 w-4 text-muted-foreground" />}
              />
              <StatCard
                title="Estimated 1RM"
                value="+5.2%"
                description="Avg. across main lifts"
                icon={<TrendingUp className="h-4 w-4 text-muted-foreground" />}
              />
            </div>

            {/* Main Content Grid */}
            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
              {/* Recent Workouts */}
              <Card className="col-span-4">
                <CardHeader>
                  <CardTitle>Recent Workouts</CardTitle>
                  <CardDescription>
                    Your last 5 workout sessions
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    <WorkoutItem
                      name="Push Day"
                      date="Today"
                      duration="52 min"
                      exercises={6}
                    />
                    <WorkoutItem
                      name="Pull Day"
                      date="Yesterday"
                      duration="48 min"
                      exercises={5}
                    />
                    <WorkoutItem
                      name="Leg Day"
                      date="2 days ago"
                      duration="55 min"
                      exercises={5}
                    />
                    <WorkoutItem
                      name="Push Day"
                      date="4 days ago"
                      duration="50 min"
                      exercises={6}
                    />
                    <WorkoutItem
                      name="Pull Day"
                      date="5 days ago"
                      duration="45 min"
                      exercises={5}
                    />
                  </div>
                </CardContent>
              </Card>

              {/* Progress Summary */}
              <Card className="col-span-3">
                <CardHeader>
                  <CardTitle>Strength Progress</CardTitle>
                  <CardDescription>
                    Estimated 1RM trends for main lifts
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    <ProgressItem
                      name="Bench Press"
                      current="225 lbs"
                      change="+10 lbs"
                      positive
                    />
                    <ProgressItem
                      name="Squat"
                      current="315 lbs"
                      change="+15 lbs"
                      positive
                    />
                    <ProgressItem
                      name="Deadlift"
                      current="405 lbs"
                      change="+20 lbs"
                      positive
                    />
                    <ProgressItem
                      name="Overhead Press"
                      current="145 lbs"
                      change="+5 lbs"
                      positive
                    />
                  </div>
                </CardContent>
              </Card>
            </div>
          </div>
        </DashboardShell>
      </div>
    </div>
  );
}

interface StatCardProps {
  title: string;
  value: string;
  description: string;
  icon: React.ReactNode;
}

const StatCard = ({ title, value, description, icon }: StatCardProps): JSX.Element => (
  <Card>
    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
      <CardTitle className="text-sm font-medium">{title}</CardTitle>
      {icon}
    </CardHeader>
    <CardContent>
      <div className="text-2xl font-bold">{value}</div>
      <p className="text-xs text-muted-foreground">{description}</p>
    </CardContent>
  </Card>
);

interface WorkoutItemProps {
  name: string;
  date: string;
  duration: string;
  exercises: number;
}

const WorkoutItem = ({ name, date, duration, exercises }: WorkoutItemProps): JSX.Element => (
  <div className="flex items-center">
    <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-muted">
      <Dumbbell className="h-4 w-4" />
    </div>
    <div className="ml-4 space-y-1">
      <p className="text-sm font-medium leading-none">{name}</p>
      <p className="text-sm text-muted-foreground">
        {date} &bull; {duration} &bull; {exercises} exercises
      </p>
    </div>
  </div>
);

interface ProgressItemProps {
  name: string;
  current: string;
  change: string;
  positive: boolean;
}

const ProgressItem = ({ name, current, change, positive }: ProgressItemProps): JSX.Element => (
  <div className="flex items-center justify-between">
    <div>
      <p className="text-sm font-medium">{name}</p>
      <p className="text-sm text-muted-foreground">{current}</p>
    </div>
    <div className={`text-sm font-medium ${positive ? 'text-green-500' : 'text-red-500'}`}>
      {change}
    </div>
  </div>
);
