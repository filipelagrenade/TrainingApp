# Required Features for Progressive Overload AI Assistant

This document outlines the data tracking, user profile, and system features needed to support intelligent progressive overload recommendations based on the training knowledge base.

---

## Core Data Tracking

These are the foundational features the app must have to enable any meaningful AI recommendations.

### Workout Logging

| Feature | Description | Used For |
|---------|-------------|----------|
| **Set/rep/weight logging** | Record each set with weight, reps completed | Double progression logic, linear progression, volume calculations |
| **Exercise categorisation** | Tag exercises as upper/lower, compound/isolation, movement pattern | Different progression increments, exercise substitution suggestions |
| **Session date/time** | When workouts occurred | Weekly volume calculations, frequency analysis, plateau detection |
| **Exercise history per user** | Historical performance on each exercise | Progression tracking, PR detection, plateau identification |

### Effort & Fatigue Tracking

| Feature | Description | Used For |
|---------|-------------|----------|
| **RPE input (per set)** | Rate of Perceived Exertion on 1-10 scale | Fatigue monitoring, autoregulation, deload triggers |
| **RIR input (optional)** | Reps in Reserve as alternative to RPE | Same as RPE, user preference |
| **Target RPE per exercise** | What RPE the user should be hitting | Detecting when actual effort exceeds planned effort |
| **Notes field** | Free text per set or session | Capture qualitative fatigue signals (joint pain, unusual soreness) |

### Program Context

| Feature | Description | Used For |
|---------|-------------|----------|
| **Current program/routine** | What split and exercises the user is following | Context for recommendations, variation suggestions |
| **Program start date** | When current program began | Detecting staleness, recommending periodisation changes |
| **Target rep ranges** | Per exercise (e.g., 8-12 reps) | Double progression logic |
| **Weeks since last deload** | Counter or calculated from history | Proactive deload recommendations |
| **Different week info** | Weeks need to progress each week with varying weight/reps |

---

## User Profile Data

Information about the user that informs how recommendations are personalised.

### Training Background

| Feature | Description | Used For |
|---------|-------------|----------|
| **Training age** | Months/years of consistent resistance training | Training level classification, progression rate expectations |
| **Training level** | Beginner / Intermediate / Advanced (can be auto-calculated) | Volume prescription, periodisation model selection |
| **Primary goal** | Strength / Hypertrophy / Both / General fitness | Rep range recommendations, periodisation approach |
| **Secondary goals** | Optional additional focus areas | Exercise selection nuance |

### Physical Stats

| Feature | Description | Used For |
|---------|-------------|----------|
| **Bodyweight** | Current weight, ideally tracked over time | Strength standards (1× BW bench, etc.), level transitions |
| **Height** | Optional | BMI context if relevant |
| **Age** | User's age | Recovery expectations, progression norms |
| **Sex** | Biological sex | Strength standards, muscle gain expectations |

### Availability & Preferences

| Feature | Description | Used For |
|---------|-------------|----------|
| **Training days per week** | How many days user can train | Split recommendations, frequency optimisation |
| **Session duration** | Typical available time | Volume feasibility per session |
| **Equipment access** | Gym, home gym, specific equipment | Exercise selection, variation recommendations |
| **Exercise preferences/restrictions** | Injuries, dislikes, limitations | Exercise substitution logic |

### Recovery Metrics (Optional but valuable)

| Feature | Description | Used For |
|---------|-------------|----------|
| **Sleep hours** | Average or per-night tracking | Deload triggers, fatigue context |
| **Sleep quality** | Subjective rating | Recovery assessment |
| **Stress level** | Subjective rating | Recovery capacity estimation |
| **Soreness/fatigue rating** | Pre-workout subjective input | Session autoregulation, deload triggers |

---

## Derived Calculations

These are computed from the raw data above. The app should calculate and surface these.

### Volume Metrics

| Calculation | Formula/Logic | Used For |
|-------------|---------------|----------|
| **Weekly sets per muscle group** | Sum sets hitting each muscle over 7 days | Volume landmark compliance (MV/MEV/MAV/MRV) |
| **Training frequency per muscle** | Count of sessions hitting each muscle per week | Frequency recommendations |
| **Per-session volume** | Sets per muscle in single session | Junk volume detection (>10 sets/muscle/session) |

### Progression Metrics

| Calculation | Formula/Logic | Used For |
|-------------|---------------|----------|
| **Progression streak** | Consecutive sessions where top of rep range hit on all sets | Double progression trigger |
| **Sessions since last weight increase** | Per exercise counter | Plateau detection |
| **Plateau flag** | No progress for 3+ consecutive sessions | Intervention recommendations |
| **Estimated 1RM** | Epley/Brzycki formula from recent sets | Periodisation percentages, strength standards |

### Fatigue Indicators

| Calculation | Formula/Logic | Used For |
|-------------|---------------|----------|
| **RPE delta** | Actual RPE minus target RPE, averaged over recent sessions | Fatigue accumulation detection |
| **Performance trend** | Weight × reps trend over last 4-8 sessions per exercise | Detecting decline despite consistent training |
| **Recovery score** | Composite of sleep, stress, soreness inputs | Deload recommendation confidence |

---

## AI Integration Points

Where and when the AI assistant engages with the user.

### Trigger Points

| Trigger | When It Fires | AI Action |
|---------|---------------|-----------|
| **Post-workout analysis** | After user completes and saves a session | Review performance, suggest next session parameters |
| **Progression achieved** | All sets hit top of rep range for 2+ sessions | Recommend weight increase |
| **Plateau detected** | 3+ sessions with no progress | Suggest interventions (deload, variation, form check) |
| **Deload due** | Proactive (4-8 weeks) or reactive (fatigue markers) | Recommend deload protocol |
| **Weekly summary** | End of training week | Volume compliance, fatigue trends, progression rate |
| **Program review** | Monthly or at program milestones | Assess overall progress, suggest program modifications |

### AI Output Types

| Output | Content | Delivery |
|--------|---------|----------|
| **Weight/rep suggestion** | Specific numbers for next session | Pre-workout or post-workout |
| **Deload prescription** | Volume/intensity reduction protocol | When triggered |
| **Plateau intervention** | Exercise swaps, periodisation changes | When plateau detected |
| **Volume adjustment** | Increase or decrease weekly sets | Weekly review |
| **Program recommendation** | New split, periodisation model | Major transitions or user request |
| **Educational context** | Brief explanation with citation | Accompanying recommendations (optional, toggleable) |

---

## Data Model Sketch

A simplified view of how this might be structured:

```
User
├── profile
│   ├── training_age_months
│   ├── training_level (derived or set)
│   ├── primary_goal
│   ├── bodyweight_kg
│   ├── available_days_per_week
│   └── equipment_access[]
│
├── current_program
│   ├── program_name
│   ├── start_date
│   ├── split_type
│   └── exercises[]
│       ├── exercise_id
│       ├── target_sets
│       ├── target_rep_range [min, max]
│       └── target_rpe
│
├── workout_history[]
│   ├── date
│   ├── session_type (e.g., "Upper A")
│   └── exercises[]
│       ├── exercise_id
│       └── sets[]
│           ├── weight_kg
│           ├── reps_completed
│           ├── rpe (optional)
│           └── notes (optional)
│
├── recovery_log[] (optional)
│   ├── date
│   ├── sleep_hours
│   ├── sleep_quality
│   ├── stress_level
│   └── soreness_rating
│
└── derived_metrics (calculated)
    ├── weekly_volume_by_muscle{}
    ├── frequency_by_muscle{}
    ├── progression_streaks_by_exercise{}
    ├── plateau_flags_by_exercise{}
    ├── estimated_1rm_by_exercise{}
    └── weeks_since_deload
```

---

## MVP vs Full Feature Set

### MVP (Minimum for Useful AI)

These are non-negotiable for the AI to provide value:

- [ ] Set/rep/weight logging per exercise
- [ ] Exercise categorisation (at minimum: upper/lower, compound/isolation)
- [ ] Session date tracking
- [ ] Training age input
- [ ] Primary goal selection
- [ ] Target rep range per exercise
- [ ] Weekly volume calculation
- [ ] Progression streak tracking
- [ ] Basic plateau detection (3+ sessions no progress)buui

### Phase 2 (Enhanced Recommendations)

- [ ] RPE/RIR tracking per set
- [ ] Target RPE per exercise
- [ ] Sleep/recovery logging
- [ ] Deload tracking and proactive recommendations
- [ ] Estimated 1RM calculations
- [ ] Training level auto-classification

### Phase 3 (Advanced Features)

- [ ] Program templates with periodisation
- [ ] Exercise variation suggestions with movement pattern matching
- [ ] Muscle-specific volume tracking (not just exercise-level)
- [ ] Fatigue trend analysis over multiple weeks
- [ ] Personalised volume landmark calibration based on user response

---

## Notes for Implementation

1. **Offline-first**: Core logging must work without connectivity. AI recommendations can sync when online.

2. **Progressive disclosure**: Don't overwhelm new users with RPE, recovery tracking, etc. Start with basic logging, introduce advanced features as users engage.

3. **Sensible defaults**: If user doesn't input RPE, assume sets were taken to appropriate effort. If no recovery data, rely on performance trends alone.

4. **Explainability**: When AI makes a recommendation, optionally show the reasoning ("You hit 12 reps on all sets for 2 sessions → time to increase weight").

5. **User override**: Always let users ignore or modify AI suggestions. Track when they do—this is valuable feedback.

---

*Document Version: 1.0 | January 2026*
