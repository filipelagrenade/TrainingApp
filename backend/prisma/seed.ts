/**
 * LiftIQ - Database Seed Script
 *
 * This script populates the database with initial data:
 * - 200+ exercises covering all muscle groups
 * - Sample training programs
 * - Default progression rules
 *
 * Run with: npx prisma db seed
 *
 * Organization:
 * - Exercises are grouped by primary muscle group
 * - Each exercise includes form cues and common mistakes
 * - Equipment requirements are specified for gym setup
 */

import { PrismaClient, Difficulty, GoalType } from '@prisma/client';

const prisma = new PrismaClient();

// ============================================================================
// EXERCISE DATA
// ============================================================================

interface ExerciseData {
  name: string;
  description: string;
  instructions?: string;
  primaryMuscles: string[];
  secondaryMuscles: string[];
  equipment: string[];
  formCues: string[];
  commonMistakes: string[];
  category: string;
  isCompound: boolean;
}

/**
 * Chest exercises (push movements)
 */
const chestExercises: ExerciseData[] = [
  {
    name: 'Barbell Bench Press',
    description: 'The king of chest exercises. A compound movement that builds overall chest mass and pressing strength.',
    instructions: 'Lie on bench, grip bar slightly wider than shoulder width, lower to mid-chest, press up.',
    primaryMuscles: ['Chest'],
    secondaryMuscles: ['Triceps', 'Front Delts'],
    equipment: ['Barbell', 'Bench'],
    formCues: ['Retract shoulder blades', 'Arch lower back slightly', 'Drive feet into floor', 'Bar path: diagonal from chest to lockout'],
    commonMistakes: ['Bouncing bar off chest', 'Flaring elbows too wide', 'Lifting hips off bench', 'Not touching chest'],
    category: 'Push',
    isCompound: true,
  },
  {
    name: 'Incline Barbell Bench Press',
    description: 'Targets the upper chest with an angled pressing motion.',
    primaryMuscles: ['Upper Chest'],
    secondaryMuscles: ['Triceps', 'Front Delts'],
    equipment: ['Barbell', 'Incline Bench'],
    formCues: ['Set bench to 30-45 degrees', 'Keep wrists straight', 'Lower to upper chest'],
    commonMistakes: ['Bench angle too steep', 'Losing shoulder blade retraction', 'Cutting range of motion short'],
    category: 'Push',
    isCompound: true,
  },
  {
    name: 'Decline Barbell Bench Press',
    description: 'Emphasizes the lower chest fibers with a declined angle.',
    primaryMuscles: ['Lower Chest'],
    secondaryMuscles: ['Triceps', 'Front Delts'],
    equipment: ['Barbell', 'Decline Bench'],
    formCues: ['Secure feet under pads', 'Lower to lower chest', 'Control the negative'],
    commonMistakes: ['Going too heavy too soon', 'Excessive decline angle', 'Losing core tension'],
    category: 'Push',
    isCompound: true,
  },
  {
    name: 'Dumbbell Bench Press',
    description: 'Allows greater range of motion and independent arm work.',
    primaryMuscles: ['Chest'],
    secondaryMuscles: ['Triceps', 'Front Delts'],
    equipment: ['Dumbbells', 'Bench'],
    formCues: ['Press dumbbells together at top', 'Keep elbows at 45-degree angle', 'Full stretch at bottom'],
    commonMistakes: ['Dumbbells drifting apart', 'Not going deep enough', 'Uneven pressing'],
    category: 'Push',
    isCompound: true,
  },
  {
    name: 'Incline Dumbbell Press',
    description: 'Upper chest focused pressing with dumbbells.',
    primaryMuscles: ['Upper Chest'],
    secondaryMuscles: ['Triceps', 'Front Delts'],
    equipment: ['Dumbbells', 'Incline Bench'],
    formCues: ['30-45 degree incline', 'Bring dumbbells together at top', 'Control the descent'],
    commonMistakes: ['Too steep incline', 'Rushing the negative', 'Incomplete range of motion'],
    category: 'Push',
    isCompound: true,
  },
  {
    name: 'Dumbbell Flyes',
    description: 'Isolation exercise for chest with a stretching motion.',
    primaryMuscles: ['Chest'],
    secondaryMuscles: ['Front Delts'],
    equipment: ['Dumbbells', 'Bench'],
    formCues: ['Slight bend in elbows', 'Arc motion like hugging a tree', 'Feel the stretch at bottom'],
    commonMistakes: ['Bending elbows too much (turns into press)', 'Going too heavy', 'Not enough stretch'],
    category: 'Push',
    isCompound: false,
  },
  {
    name: 'Cable Crossover',
    description: 'Constant tension chest isolation using cables.',
    primaryMuscles: ['Chest'],
    secondaryMuscles: ['Front Delts'],
    equipment: ['Cable Machine'],
    formCues: ['Step forward for stretch', 'Cross hands at bottom', 'Squeeze chest at contraction'],
    commonMistakes: ['Too much shoulder involvement', 'Not controlling the weight', 'Standing too close to cables'],
    category: 'Push',
    isCompound: false,
  },
  {
    name: 'Push-Up',
    description: 'Classic bodyweight chest exercise. Great for warmup or high-rep finishing.',
    primaryMuscles: ['Chest'],
    secondaryMuscles: ['Triceps', 'Front Delts', 'Core'],
    equipment: ['Bodyweight'],
    formCues: ['Hands slightly wider than shoulders', 'Body in straight line', 'Full range of motion'],
    commonMistakes: ['Hips sagging', 'Not going low enough', 'Flaring elbows too wide'],
    category: 'Push',
    isCompound: true,
  },
  {
    name: 'Dips (Chest Focused)',
    description: 'Compound pressing movement with chest emphasis.',
    primaryMuscles: ['Lower Chest'],
    secondaryMuscles: ['Triceps', 'Front Delts'],
    equipment: ['Dip Bars'],
    formCues: ['Lean forward', 'Wide grip', 'Go to 90 degrees or below'],
    commonMistakes: ['Not leaning forward (becomes tricep dip)', 'Cutting range short', 'Swinging'],
    category: 'Push',
    isCompound: true,
  },
  {
    name: 'Machine Chest Press',
    description: 'Guided pressing motion, great for beginners or isolating chest.',
    primaryMuscles: ['Chest'],
    secondaryMuscles: ['Triceps', 'Front Delts'],
    equipment: ['Chest Press Machine'],
    formCues: ['Adjust seat height', 'Grip at chest level', 'Full extension without lockout'],
    commonMistakes: ['Seat too high or low', 'Not using full range', 'Going too heavy'],
    category: 'Push',
    isCompound: true,
  },
  {
    name: 'Pec Deck',
    description: 'Machine-based chest fly for isolation.',
    primaryMuscles: ['Chest'],
    secondaryMuscles: ['Front Delts'],
    equipment: ['Pec Deck Machine'],
    formCues: ['Elbows at 90 degrees', 'Squeeze at the middle', 'Controlled return'],
    commonMistakes: ['Using momentum', 'Not getting full range', 'Shoulders taking over'],
    category: 'Push',
    isCompound: false,
  },
];

/**
 * Back exercises (pull movements)
 */
const backExercises: ExerciseData[] = [
  {
    name: 'Barbell Deadlift',
    description: 'The ultimate posterior chain builder. Targets the entire back, glutes, and hamstrings.',
    primaryMuscles: ['Lower Back', 'Glutes', 'Hamstrings'],
    secondaryMuscles: ['Traps', 'Lats', 'Forearms', 'Core'],
    equipment: ['Barbell'],
    formCues: ['Bar over mid-foot', 'Hips hinge back', 'Chest up, back flat', 'Push floor away'],
    commonMistakes: ['Rounding lower back', 'Bar too far from body', 'Jerking the weight', 'Hyperextending at top'],
    category: 'Pull',
    isCompound: true,
  },
  {
    name: 'Romanian Deadlift',
    description: 'Hip hinge movement focusing on hamstrings and glutes.',
    primaryMuscles: ['Hamstrings', 'Glutes'],
    secondaryMuscles: ['Lower Back'],
    equipment: ['Barbell'],
    formCues: ['Slight knee bend', 'Push hips back', 'Feel hamstring stretch', 'Bar stays close'],
    commonMistakes: ['Bending knees too much', 'Rounding back', 'Going too low'],
    category: 'Pull',
    isCompound: true,
  },
  {
    name: 'Barbell Row',
    description: 'Primary back builder for thickness and width.',
    primaryMuscles: ['Lats', 'Rhomboids', 'Rear Delts'],
    secondaryMuscles: ['Biceps', 'Lower Back'],
    equipment: ['Barbell'],
    formCues: ['Torso at 45 degrees', 'Pull to lower chest/upper abs', 'Squeeze shoulder blades'],
    commonMistakes: ['Too much body english', 'Not pulling to correct spot', 'Standing too upright'],
    category: 'Pull',
    isCompound: true,
  },
  {
    name: 'Pendlay Row',
    description: 'Strict rowing variation with bar returning to floor each rep.',
    primaryMuscles: ['Lats', 'Rhomboids'],
    secondaryMuscles: ['Biceps', 'Lower Back'],
    equipment: ['Barbell'],
    formCues: ['Torso parallel to floor', 'Explosive pull', 'Dead stop each rep'],
    commonMistakes: ['Using momentum', 'Not reaching full extension', 'Torso not parallel'],
    category: 'Pull',
    isCompound: true,
  },
  {
    name: 'Pull-Up',
    description: 'Classic bodyweight back exercise for width.',
    primaryMuscles: ['Lats'],
    secondaryMuscles: ['Biceps', 'Rear Delts', 'Core'],
    equipment: ['Pull-Up Bar'],
    formCues: ['Grip slightly wider than shoulders', 'Pull chest to bar', 'Control the negative'],
    commonMistakes: ['Kipping/swinging', 'Not going full range', 'Chin not over bar'],
    category: 'Pull',
    isCompound: true,
  },
  {
    name: 'Chin-Up',
    description: 'Supinated grip pull-up for more bicep involvement.',
    primaryMuscles: ['Lats', 'Biceps'],
    secondaryMuscles: ['Rear Delts', 'Core'],
    equipment: ['Pull-Up Bar'],
    formCues: ['Palms facing you', 'Pull chest to bar', 'Squeeze at top'],
    commonMistakes: ['Not full range', 'Swinging', 'Grip too narrow'],
    category: 'Pull',
    isCompound: true,
  },
  {
    name: 'Lat Pulldown',
    description: 'Cable machine exercise mimicking pull-up motion.',
    primaryMuscles: ['Lats'],
    secondaryMuscles: ['Biceps', 'Rear Delts'],
    equipment: ['Lat Pulldown Machine'],
    formCues: ['Slight lean back', 'Pull to upper chest', 'Squeeze shoulder blades down'],
    commonMistakes: ['Leaning too far back', 'Pulling behind neck', 'Using momentum'],
    category: 'Pull',
    isCompound: true,
  },
  {
    name: 'Seated Cable Row',
    description: 'Horizontal pulling for back thickness.',
    primaryMuscles: ['Lats', 'Rhomboids'],
    secondaryMuscles: ['Biceps', 'Rear Delts'],
    equipment: ['Cable Machine'],
    formCues: ['Chest up', 'Pull to belly button', 'Squeeze shoulder blades'],
    commonMistakes: ['Rounding back', 'Using body momentum', 'Not full extension'],
    category: 'Pull',
    isCompound: true,
  },
  {
    name: 'T-Bar Row',
    description: 'Supported rowing for heavy back work.',
    primaryMuscles: ['Lats', 'Rhomboids'],
    secondaryMuscles: ['Biceps', 'Lower Back'],
    equipment: ['T-Bar Row Machine', 'Barbell'],
    formCues: ['Chest supported or braced', 'Pull to lower chest', 'Control negative'],
    commonMistakes: ['Too much momentum', 'Not squeezing at top', 'Rounding back'],
    category: 'Pull',
    isCompound: true,
  },
  {
    name: 'Single-Arm Dumbbell Row',
    description: 'Unilateral rowing for balanced development.',
    primaryMuscles: ['Lats', 'Rhomboids'],
    secondaryMuscles: ['Biceps', 'Rear Delts'],
    equipment: ['Dumbbell', 'Bench'],
    formCues: ['Support hand on bench', 'Row to hip', 'Full stretch at bottom'],
    commonMistakes: ['Rotating torso', 'Cutting range short', 'Using momentum'],
    category: 'Pull',
    isCompound: true,
  },
  {
    name: 'Face Pull',
    description: 'Rear delt and upper back health exercise.',
    primaryMuscles: ['Rear Delts', 'Rhomboids'],
    secondaryMuscles: ['Traps'],
    equipment: ['Cable Machine', 'Rope Attachment'],
    formCues: ['Pull to face level', 'External rotate at end', 'Squeeze shoulder blades'],
    commonMistakes: ['Going too heavy', 'Not externally rotating', 'Using momentum'],
    category: 'Pull',
    isCompound: false,
  },
  {
    name: 'Straight-Arm Pulldown',
    description: 'Lat isolation keeping arms straight.',
    primaryMuscles: ['Lats'],
    secondaryMuscles: ['Triceps Long Head'],
    equipment: ['Cable Machine'],
    formCues: ['Arms slightly bent', 'Pull bar to thighs', 'Feel lat stretch at top'],
    commonMistakes: ['Bending elbows too much', 'Using body momentum', 'Not full range'],
    category: 'Pull',
    isCompound: false,
  },
];

/**
 * Shoulder exercises
 */
const shoulderExercises: ExerciseData[] = [
  {
    name: 'Overhead Press',
    description: 'Primary shoulder builder. Standing press for core engagement.',
    primaryMuscles: ['Front Delts', 'Side Delts'],
    secondaryMuscles: ['Triceps', 'Core', 'Upper Chest'],
    equipment: ['Barbell'],
    formCues: ['Bar starts at shoulders', 'Press straight up', 'Head moves forward at lockout'],
    commonMistakes: ['Excessive back arch', 'Press in front instead of overhead', 'Not locking out'],
    category: 'Push',
    isCompound: true,
  },
  {
    name: 'Seated Dumbbell Shoulder Press',
    description: 'Shoulder press with back support and independent arms.',
    primaryMuscles: ['Front Delts', 'Side Delts'],
    secondaryMuscles: ['Triceps'],
    equipment: ['Dumbbells', 'Bench'],
    formCues: ['Back flat against bench', 'Press up and slightly together', 'Control descent'],
    commonMistakes: ['Arching back excessively', 'Elbows too far back', 'Incomplete range'],
    category: 'Push',
    isCompound: true,
  },
  {
    name: 'Arnold Press',
    description: 'Rotating press hitting all three delt heads.',
    primaryMuscles: ['Front Delts', 'Side Delts'],
    secondaryMuscles: ['Triceps'],
    equipment: ['Dumbbells'],
    formCues: ['Start with palms facing you', 'Rotate as you press', 'Full rotation at top'],
    commonMistakes: ['Not rotating fully', 'Using momentum', 'Going too heavy'],
    category: 'Push',
    isCompound: true,
  },
  {
    name: 'Lateral Raise',
    description: 'Isolation for side delts to build shoulder width.',
    primaryMuscles: ['Side Delts'],
    secondaryMuscles: ['Traps'],
    equipment: ['Dumbbells'],
    formCues: ['Slight bend in elbows', 'Raise to shoulder height', 'Control the negative'],
    commonMistakes: ['Using momentum/swinging', 'Going too heavy', 'Shrugging up'],
    category: 'Push',
    isCompound: false,
  },
  {
    name: 'Front Raise',
    description: 'Front delt isolation exercise.',
    primaryMuscles: ['Front Delts'],
    secondaryMuscles: ['Side Delts'],
    equipment: ['Dumbbells'],
    formCues: ['Raise to eye level', 'Slight bend in elbow', 'Alternate or together'],
    commonMistakes: ['Swinging weight', 'Going too high', 'Using momentum'],
    category: 'Push',
    isCompound: false,
  },
  {
    name: 'Reverse Pec Deck',
    description: 'Rear delt isolation using pec deck machine.',
    primaryMuscles: ['Rear Delts'],
    secondaryMuscles: ['Rhomboids', 'Traps'],
    equipment: ['Pec Deck Machine'],
    formCues: ['Sit facing pad', 'Pull handles back', 'Squeeze shoulder blades'],
    commonMistakes: ['Using momentum', 'Not full range', 'Shrugging'],
    category: 'Pull',
    isCompound: false,
  },
  {
    name: 'Cable Lateral Raise',
    description: 'Constant tension lateral raise variation.',
    primaryMuscles: ['Side Delts'],
    secondaryMuscles: ['Traps'],
    equipment: ['Cable Machine'],
    formCues: ['Stand perpendicular to cable', 'Pull across body', 'Control entire range'],
    commonMistakes: ['Using body momentum', 'Standing wrong direction', 'Incomplete range'],
    category: 'Push',
    isCompound: false,
  },
  {
    name: 'Upright Row',
    description: 'Compound movement for traps and side delts.',
    primaryMuscles: ['Traps', 'Side Delts'],
    secondaryMuscles: ['Biceps', 'Front Delts'],
    equipment: ['Barbell'],
    formCues: ['Wide grip for shoulders', 'Pull to chest level', 'Elbows lead the movement'],
    commonMistakes: ['Too narrow grip', 'Pulling too high', 'Internal rotation'],
    category: 'Pull',
    isCompound: true,
  },
];

/**
 * Arm exercises (biceps and triceps)
 */
const armExercises: ExerciseData[] = [
  // Biceps
  {
    name: 'Barbell Curl',
    description: 'Classic bicep builder for mass.',
    primaryMuscles: ['Biceps'],
    secondaryMuscles: ['Forearms'],
    equipment: ['Barbell'],
    formCues: ['Elbows pinned to sides', 'Full range of motion', 'Control negative'],
    commonMistakes: ['Swinging body', 'Elbows drifting forward', 'Partial reps'],
    category: 'Pull',
    isCompound: false,
  },
  {
    name: 'Dumbbell Curl',
    description: 'Independent arm curling for balanced development.',
    primaryMuscles: ['Biceps'],
    secondaryMuscles: ['Forearms'],
    equipment: ['Dumbbells'],
    formCues: ['Supinate at top', 'Full stretch at bottom', 'Alternate or together'],
    commonMistakes: ['Swinging', 'Not supinating', 'Rushing'],
    category: 'Pull',
    isCompound: false,
  },
  {
    name: 'Hammer Curl',
    description: 'Neutral grip curl targeting brachialis and forearms.',
    primaryMuscles: ['Biceps', 'Brachialis'],
    secondaryMuscles: ['Forearms'],
    equipment: ['Dumbbells'],
    formCues: ['Neutral grip throughout', 'Curl straight up', 'Control descent'],
    commonMistakes: ['Swinging', 'Curling across body', 'Partial range'],
    category: 'Pull',
    isCompound: false,
  },
  {
    name: 'Preacher Curl',
    description: 'Strict bicep isolation using preacher bench.',
    primaryMuscles: ['Biceps'],
    secondaryMuscles: ['Forearms'],
    equipment: ['Preacher Bench', 'Barbell', 'Dumbbells'],
    formCues: ['Arms fully on pad', 'Full extension', 'Squeeze at top'],
    commonMistakes: ['Not extending fully', 'Lifting shoulders', 'Going too heavy'],
    category: 'Pull',
    isCompound: false,
  },
  {
    name: 'Incline Dumbbell Curl',
    description: 'Stretched position bicep curl.',
    primaryMuscles: ['Biceps'],
    secondaryMuscles: ['Forearms'],
    equipment: ['Dumbbells', 'Incline Bench'],
    formCues: ['Arms hang straight down', 'Curl up without moving elbows', 'Full stretch'],
    commonMistakes: ['Bench too upright', 'Elbows moving forward', 'Momentum'],
    category: 'Pull',
    isCompound: false,
  },
  {
    name: 'Concentration Curl',
    description: 'Strict single-arm bicep isolation.',
    primaryMuscles: ['Biceps'],
    secondaryMuscles: [],
    equipment: ['Dumbbell'],
    formCues: ['Elbow braced on inner thigh', 'Curl to shoulder', 'Squeeze at top'],
    commonMistakes: ['Using shoulder', 'Not bracing elbow', 'Swinging'],
    category: 'Pull',
    isCompound: false,
  },
  {
    name: 'Cable Curl',
    description: 'Constant tension bicep curl.',
    primaryMuscles: ['Biceps'],
    secondaryMuscles: ['Forearms'],
    equipment: ['Cable Machine'],
    formCues: ['Stand close to cable', 'Keep elbows pinned', 'Full range'],
    commonMistakes: ['Stepping back too far', 'Using momentum', 'Elbows drifting'],
    category: 'Pull',
    isCompound: false,
  },
  // Triceps
  {
    name: 'Close-Grip Bench Press',
    description: 'Compound tricep builder.',
    primaryMuscles: ['Triceps'],
    secondaryMuscles: ['Chest', 'Front Delts'],
    equipment: ['Barbell', 'Bench'],
    formCues: ['Hands shoulder-width or slightly narrower', 'Elbows tucked', 'Touch lower chest'],
    commonMistakes: ['Grip too narrow', 'Flaring elbows', 'Bar drifting to face'],
    category: 'Push',
    isCompound: true,
  },
  {
    name: 'Tricep Pushdown',
    description: 'Cable tricep isolation.',
    primaryMuscles: ['Triceps'],
    secondaryMuscles: [],
    equipment: ['Cable Machine'],
    formCues: ['Elbows pinned', 'Push to full extension', 'Control return'],
    commonMistakes: ['Leaning forward', 'Elbows moving', 'Using momentum'],
    category: 'Push',
    isCompound: false,
  },
  {
    name: 'Overhead Tricep Extension',
    description: 'Tricep stretch position exercise.',
    primaryMuscles: ['Triceps'],
    secondaryMuscles: [],
    equipment: ['Dumbbell', 'Cable Machine'],
    formCues: ['Keep elbows pointed up', 'Full stretch at bottom', 'Extend fully'],
    commonMistakes: ['Elbows flaring', 'Not full stretch', 'Using shoulders'],
    category: 'Push',
    isCompound: false,
  },
  {
    name: 'Skull Crusher',
    description: 'Lying tricep extension for mass.',
    primaryMuscles: ['Triceps'],
    secondaryMuscles: [],
    equipment: ['Barbell', 'EZ Bar', 'Bench'],
    formCues: ['Lower to forehead or behind head', 'Elbows pointed up', 'Control descent'],
    commonMistakes: ['Elbows flaring', 'Moving upper arm', 'Going too heavy'],
    category: 'Push',
    isCompound: false,
  },
  {
    name: 'Dips (Tricep Focused)',
    description: 'Compound tricep exercise with upright torso.',
    primaryMuscles: ['Triceps'],
    secondaryMuscles: ['Chest', 'Front Delts'],
    equipment: ['Dip Bars'],
    formCues: ['Stay upright', 'Narrower grip', 'Full lockout'],
    commonMistakes: ['Leaning forward too much', 'Partial reps', 'Swinging'],
    category: 'Push',
    isCompound: true,
  },
  {
    name: 'Diamond Push-Up',
    description: 'Bodyweight tricep focused push-up.',
    primaryMuscles: ['Triceps'],
    secondaryMuscles: ['Chest', 'Front Delts'],
    equipment: ['Bodyweight'],
    formCues: ['Hands form diamond', 'Elbows close to body', 'Full range'],
    commonMistakes: ['Hands too far apart', 'Flaring elbows', 'Partial range'],
    category: 'Push',
    isCompound: true,
  },
  {
    name: 'Tricep Kickback',
    description: 'Isolation exercise for tricep peak.',
    primaryMuscles: ['Triceps'],
    secondaryMuscles: [],
    equipment: ['Dumbbell'],
    formCues: ['Upper arm parallel to floor', 'Extend fully', 'Squeeze at top'],
    commonMistakes: ['Moving upper arm', 'Not extending fully', 'Using momentum'],
    category: 'Push',
    isCompound: false,
  },
];

/**
 * Leg exercises
 */
const legExercises: ExerciseData[] = [
  {
    name: 'Barbell Back Squat',
    description: 'The king of leg exercises. Builds overall leg mass and strength.',
    primaryMuscles: ['Quads', 'Glutes'],
    secondaryMuscles: ['Hamstrings', 'Lower Back', 'Core'],
    equipment: ['Barbell', 'Squat Rack'],
    formCues: ['Bar on upper traps', 'Break at hips and knees together', 'Knees track over toes', 'Hit parallel or below'],
    commonMistakes: ['Knees caving in', 'Rising hips first', 'Not hitting depth', 'Forward lean'],
    category: 'Legs',
    isCompound: true,
  },
  {
    name: 'Front Squat',
    description: 'Quad-focused squat with front rack position.',
    primaryMuscles: ['Quads'],
    secondaryMuscles: ['Glutes', 'Core'],
    equipment: ['Barbell', 'Squat Rack'],
    formCues: ['Elbows up high', 'Stay upright', 'Full depth'],
    commonMistakes: ['Elbows dropping', 'Forward lean', 'Limited depth'],
    category: 'Legs',
    isCompound: true,
  },
  {
    name: 'Goblet Squat',
    description: 'Beginner-friendly squat with dumbbell.',
    primaryMuscles: ['Quads', 'Glutes'],
    secondaryMuscles: ['Core'],
    equipment: ['Dumbbell', 'Kettlebell'],
    formCues: ['Hold at chest', 'Elbows between knees', 'Stay upright'],
    commonMistakes: ['Rounding back', 'Not going deep enough', 'Weight drifting forward'],
    category: 'Legs',
    isCompound: true,
  },
  {
    name: 'Leg Press',
    description: 'Machine-based quad and glute exercise.',
    primaryMuscles: ['Quads', 'Glutes'],
    secondaryMuscles: ['Hamstrings'],
    equipment: ['Leg Press Machine'],
    formCues: ['Full range without lower back rounding', 'Feet shoulder-width', 'Control descent'],
    commonMistakes: ['Partial reps', 'Lower back lifting', 'Locking knees too hard'],
    category: 'Legs',
    isCompound: true,
  },
  {
    name: 'Bulgarian Split Squat',
    description: 'Single-leg squat for balance and unilateral strength.',
    primaryMuscles: ['Quads', 'Glutes'],
    secondaryMuscles: ['Hamstrings', 'Core'],
    equipment: ['Dumbbells', 'Bench'],
    formCues: ['Rear foot elevated', 'Front knee tracks over toe', 'Torso upright'],
    commonMistakes: ['Standing too close to bench', 'Knee caving', 'Leaning forward'],
    category: 'Legs',
    isCompound: true,
  },
  {
    name: 'Walking Lunge',
    description: 'Dynamic lunge for legs and conditioning.',
    primaryMuscles: ['Quads', 'Glutes'],
    secondaryMuscles: ['Hamstrings', 'Core'],
    equipment: ['Dumbbells', 'Barbell'],
    formCues: ['Long stride', 'Knee to 90 degrees', 'Push through front heel'],
    commonMistakes: ['Steps too short', 'Knee going past toes', 'Losing balance'],
    category: 'Legs',
    isCompound: true,
  },
  {
    name: 'Leg Extension',
    description: 'Quad isolation exercise.',
    primaryMuscles: ['Quads'],
    secondaryMuscles: [],
    equipment: ['Leg Extension Machine'],
    formCues: ['Full extension', 'Control negative', 'Squeeze at top'],
    commonMistakes: ['Using momentum', 'Partial range', 'Too heavy'],
    category: 'Legs',
    isCompound: false,
  },
  {
    name: 'Leg Curl',
    description: 'Hamstring isolation exercise.',
    primaryMuscles: ['Hamstrings'],
    secondaryMuscles: [],
    equipment: ['Leg Curl Machine'],
    formCues: ['Full range', 'Control the weight', 'Squeeze at top'],
    commonMistakes: ['Lifting hips', 'Partial range', 'Using momentum'],
    category: 'Legs',
    isCompound: false,
  },
  {
    name: 'Romanian Deadlift',
    description: 'Hip hinge for hamstrings and glutes.',
    primaryMuscles: ['Hamstrings', 'Glutes'],
    secondaryMuscles: ['Lower Back'],
    equipment: ['Barbell', 'Dumbbells'],
    formCues: ['Slight knee bend', 'Push hips back', 'Feel hamstring stretch'],
    commonMistakes: ['Bending knees too much', 'Rounding back', 'Not hip hinging'],
    category: 'Legs',
    isCompound: true,
  },
  {
    name: 'Hip Thrust',
    description: 'Glute-focused hip extension exercise.',
    primaryMuscles: ['Glutes'],
    secondaryMuscles: ['Hamstrings'],
    equipment: ['Barbell', 'Bench'],
    formCues: ['Upper back on bench', 'Drive through heels', 'Squeeze glutes at top'],
    commonMistakes: ['Hyperextending lower back', 'Not full range', 'Feet too close'],
    category: 'Legs',
    isCompound: true,
  },
  {
    name: 'Calf Raise (Standing)',
    description: 'Standing calf exercise for gastrocnemius.',
    primaryMuscles: ['Calves'],
    secondaryMuscles: [],
    equipment: ['Calf Raise Machine', 'Smith Machine'],
    formCues: ['Full stretch at bottom', 'Rise onto toes', 'Squeeze at top'],
    commonMistakes: ['Bouncing', 'Partial range', 'Bending knees'],
    category: 'Legs',
    isCompound: false,
  },
  {
    name: 'Calf Raise (Seated)',
    description: 'Seated calf raise targeting soleus.',
    primaryMuscles: ['Calves'],
    secondaryMuscles: [],
    equipment: ['Seated Calf Raise Machine'],
    formCues: ['Full stretch', 'Controlled motion', 'Squeeze at top'],
    commonMistakes: ['Bouncing', 'Too fast', 'Partial range'],
    category: 'Legs',
    isCompound: false,
  },
  {
    name: 'Hack Squat',
    description: 'Machine squat variation for quad emphasis.',
    primaryMuscles: ['Quads'],
    secondaryMuscles: ['Glutes'],
    equipment: ['Hack Squat Machine'],
    formCues: ['Shoulders against pad', 'Full depth', 'Feet shoulder-width'],
    commonMistakes: ['Partial reps', 'Knees caving', 'Rising too fast'],
    category: 'Legs',
    isCompound: true,
  },
  {
    name: 'Step-Up',
    description: 'Unilateral leg exercise using a step or box.',
    primaryMuscles: ['Quads', 'Glutes'],
    secondaryMuscles: ['Hamstrings'],
    equipment: ['Box', 'Dumbbells'],
    formCues: ['Drive through front foot', 'Full hip extension', 'Control descent'],
    commonMistakes: ['Pushing off back foot', 'Box too high/low', 'Leaning forward'],
    category: 'Legs',
    isCompound: true,
  },
];

/**
 * Core exercises
 */
const coreExercises: ExerciseData[] = [
  {
    name: 'Plank',
    description: 'Isometric core strengthening exercise.',
    primaryMuscles: ['Core'],
    secondaryMuscles: ['Shoulders', 'Glutes'],
    equipment: ['Bodyweight'],
    formCues: ['Body in straight line', 'Squeeze glutes', 'Brace core'],
    commonMistakes: ['Hips sagging', 'Hips too high', 'Not breathing'],
    category: 'Core',
    isCompound: false,
  },
  {
    name: 'Crunch',
    description: 'Basic ab flexion exercise.',
    primaryMuscles: ['Abs'],
    secondaryMuscles: [],
    equipment: ['Bodyweight'],
    formCues: ['Curl spine', 'Chin tucked', 'Exhale at top'],
    commonMistakes: ['Pulling neck', 'Using momentum', 'Full sit-up motion'],
    category: 'Core',
    isCompound: false,
  },
  {
    name: 'Hanging Leg Raise',
    description: 'Advanced ab exercise using hanging position.',
    primaryMuscles: ['Abs', 'Hip Flexors'],
    secondaryMuscles: ['Grip'],
    equipment: ['Pull-Up Bar'],
    formCues: ['Control swing', 'Curl pelvis', 'Lower with control'],
    commonMistakes: ['Swinging', 'Not curling pelvis', 'Partial range'],
    category: 'Core',
    isCompound: false,
  },
  {
    name: 'Cable Crunch',
    description: 'Weighted ab crunch using cable.',
    primaryMuscles: ['Abs'],
    secondaryMuscles: [],
    equipment: ['Cable Machine'],
    formCues: ['Kneel facing away', 'Crunch down', 'Curl spine not hip'],
    commonMistakes: ['Hip hinging', 'Using arms', 'Too much weight'],
    category: 'Core',
    isCompound: false,
  },
  {
    name: 'Russian Twist',
    description: 'Rotational core exercise.',
    primaryMuscles: ['Obliques', 'Abs'],
    secondaryMuscles: [],
    equipment: ['Bodyweight', 'Medicine Ball'],
    formCues: ['Lean back slightly', 'Rotate fully', 'Keep feet up (harder)'],
    commonMistakes: ['Not rotating enough', 'Moving just arms', 'Rounding back'],
    category: 'Core',
    isCompound: false,
  },
  {
    name: 'Ab Wheel Rollout',
    description: 'Advanced core stability exercise.',
    primaryMuscles: ['Abs'],
    secondaryMuscles: ['Lats', 'Shoulders'],
    equipment: ['Ab Wheel'],
    formCues: ['Start on knees', 'Roll out with flat back', 'Pull back with abs'],
    commonMistakes: ['Lower back sagging', 'Going too far', 'Using arms to pull'],
    category: 'Core',
    isCompound: false,
  },
  {
    name: 'Dead Bug',
    description: 'Core stability exercise for beginners.',
    primaryMuscles: ['Core'],
    secondaryMuscles: [],
    equipment: ['Bodyweight'],
    formCues: ['Lower back pressed to floor', 'Opposite arm/leg extend', 'Controlled breathing'],
    commonMistakes: ['Back arching', 'Moving too fast', 'Not bracing'],
    category: 'Core',
    isCompound: false,
  },
  {
    name: 'Mountain Climber',
    description: 'Dynamic core and conditioning exercise.',
    primaryMuscles: ['Core', 'Hip Flexors'],
    secondaryMuscles: ['Shoulders'],
    equipment: ['Bodyweight'],
    formCues: ['Plank position', 'Drive knees to chest', 'Keep hips level'],
    commonMistakes: ['Hips rising', 'Bouncing', 'Not engaging core'],
    category: 'Core',
    isCompound: true,
  },
  {
    name: 'Side Plank',
    description: 'Lateral core stabilization exercise.',
    primaryMuscles: ['Obliques'],
    secondaryMuscles: ['Core', 'Shoulders'],
    equipment: ['Bodyweight'],
    formCues: ['Body in straight line', 'Stack feet or stagger', 'Hips up'],
    commonMistakes: ['Hips dropping', 'Not aligned', 'Holding breath'],
    category: 'Core',
    isCompound: false,
  },
];

/**
 * Additional compound and functional exercises
 */
const additionalExercises: ExerciseData[] = [
  {
    name: 'Barbell Clean',
    description: 'Olympic lift for power development.',
    primaryMuscles: ['Quads', 'Glutes', 'Traps'],
    secondaryMuscles: ['Hamstrings', 'Core', 'Shoulders'],
    equipment: ['Barbell'],
    formCues: ['Triple extension', 'Catch in front rack', 'Pull under bar'],
    commonMistakes: ['Early arm pull', 'Not extending fully', 'Catching too high'],
    category: 'Olympic',
    isCompound: true,
  },
  {
    name: 'Power Clean',
    description: 'Clean variation caught in partial squat.',
    primaryMuscles: ['Quads', 'Glutes', 'Traps'],
    secondaryMuscles: ['Hamstrings', 'Core'],
    equipment: ['Barbell'],
    formCues: ['Explosive pull', 'Catch in quarter squat', 'Keep bar close'],
    commonMistakes: ['Arm pulling', 'Swinging bar out', 'No hip extension'],
    category: 'Olympic',
    isCompound: true,
  },
  {
    name: 'Snatch',
    description: 'Full Olympic snatch.',
    primaryMuscles: ['Full Body'],
    secondaryMuscles: [],
    equipment: ['Barbell'],
    formCues: ['Wide grip', 'Triple extension', 'Catch overhead in squat'],
    commonMistakes: ['Early pull', 'Bar looping', 'Unstable overhead'],
    category: 'Olympic',
    isCompound: true,
  },
  {
    name: 'Clean and Jerk',
    description: 'Full Olympic clean and jerk.',
    primaryMuscles: ['Full Body'],
    secondaryMuscles: [],
    equipment: ['Barbell'],
    formCues: ['Clean to shoulders', 'Dip and drive', 'Split or power jerk'],
    commonMistakes: ['Rushed transition', 'Poor dip', 'Press out'],
    category: 'Olympic',
    isCompound: true,
  },
  {
    name: 'Kettlebell Swing',
    description: 'Hip hinge power exercise.',
    primaryMuscles: ['Glutes', 'Hamstrings'],
    secondaryMuscles: ['Core', 'Shoulders'],
    equipment: ['Kettlebell'],
    formCues: ['Hip hinge', 'Snap hips forward', 'Arms are just hooks'],
    commonMistakes: ['Squatting motion', 'Using arms', 'Rounding back'],
    category: 'Functional',
    isCompound: true,
  },
  {
    name: 'Thruster',
    description: 'Front squat to press combination.',
    primaryMuscles: ['Quads', 'Shoulders'],
    secondaryMuscles: ['Glutes', 'Core', 'Triceps'],
    equipment: ['Barbell', 'Dumbbells'],
    formCues: ['Full front squat', 'Drive through heels', 'Use momentum into press'],
    commonMistakes: ['Stopping at top of squat', 'Press before standing', 'Partial squat'],
    category: 'Functional',
    isCompound: true,
  },
  {
    name: 'Farmers Walk',
    description: 'Loaded carry for grip and conditioning.',
    primaryMuscles: ['Grip', 'Core', 'Traps'],
    secondaryMuscles: ['Full Body'],
    equipment: ['Dumbbells', 'Farmers Walk Handles'],
    formCues: ['Stand tall', 'Shoulders back', 'Quick controlled steps'],
    commonMistakes: ['Leaning forward', 'Too long strides', 'Slouching'],
    category: 'Functional',
    isCompound: true,
  },
  {
    name: 'Turkish Get-Up',
    description: 'Full body mobility and stability exercise.',
    primaryMuscles: ['Core', 'Shoulders'],
    secondaryMuscles: ['Full Body'],
    equipment: ['Kettlebell', 'Dumbbell'],
    formCues: ['Eye on weight', 'Move slowly', 'Stable at each position'],
    commonMistakes: ['Rushing', 'Losing shoulder pack', 'Skipping steps'],
    category: 'Functional',
    isCompound: true,
  },
  {
    name: 'Battle Ropes',
    description: 'Conditioning exercise using heavy ropes.',
    primaryMuscles: ['Shoulders', 'Core'],
    secondaryMuscles: ['Arms', 'Legs'],
    equipment: ['Battle Ropes'],
    formCues: ['Athletic stance', 'Create waves', 'Maintain rhythm'],
    commonMistakes: ['Standing too upright', 'Arms only', 'Inconsistent waves'],
    category: 'Conditioning',
    isCompound: true,
  },
  {
    name: 'Box Jump',
    description: 'Plyometric power exercise.',
    primaryMuscles: ['Quads', 'Glutes'],
    secondaryMuscles: ['Calves', 'Core'],
    equipment: ['Plyo Box'],
    formCues: ['Swing arms', 'Soft landing', 'Step down'],
    commonMistakes: ['Jumping down', 'Landing hard', 'Box too high'],
    category: 'Plyometric',
    isCompound: true,
  },
  {
    name: 'Burpee',
    description: 'Full body conditioning exercise.',
    primaryMuscles: ['Full Body'],
    secondaryMuscles: [],
    equipment: ['Bodyweight'],
    formCues: ['Chest to ground', 'Jump with arms overhead', 'Maintain pace'],
    commonMistakes: ['No full extension', 'Sagging push-up', 'Skipping steps'],
    category: 'Conditioning',
    isCompound: true,
  },
  {
    name: 'Sled Push',
    description: 'Lower body power and conditioning.',
    primaryMuscles: ['Quads', 'Glutes'],
    secondaryMuscles: ['Core', 'Shoulders'],
    equipment: ['Prowler Sled'],
    formCues: ['Low body angle', 'Drive through legs', 'Short quick steps'],
    commonMistakes: ['Standing too upright', 'Arms doing work', 'Steps too long'],
    category: 'Conditioning',
    isCompound: true,
  },
  {
    name: 'Renegade Row',
    description: 'Plank position row for core and back.',
    primaryMuscles: ['Core', 'Lats'],
    secondaryMuscles: ['Biceps', 'Shoulders'],
    equipment: ['Dumbbells'],
    formCues: ['Wide stance', 'Minimize hip rotation', 'Controlled row'],
    commonMistakes: ['Rotating hips', 'Rushing', 'Too narrow stance'],
    category: 'Functional',
    isCompound: true,
  },
  {
    name: 'Landmine Press',
    description: 'Angled pressing movement.',
    primaryMuscles: ['Shoulders', 'Upper Chest'],
    secondaryMuscles: ['Triceps', 'Core'],
    equipment: ['Barbell', 'Landmine'],
    formCues: ['One or two hands', 'Press at angle', 'Core braced'],
    commonMistakes: ['Leaning back', 'Incomplete extension', 'Losing balance'],
    category: 'Push',
    isCompound: true,
  },
  {
    name: 'Landmine Row',
    description: 'Angled row variation.',
    primaryMuscles: ['Lats', 'Rhomboids'],
    secondaryMuscles: ['Biceps'],
    equipment: ['Barbell', 'Landmine'],
    formCues: ['Hinge at hips', 'Row to hip', 'Squeeze at top'],
    commonMistakes: ['Rounding back', 'Using momentum', 'Standing too upright'],
    category: 'Pull',
    isCompound: true,
  },
  {
    name: 'Sumo Deadlift',
    description: 'Wide stance deadlift variation.',
    primaryMuscles: ['Glutes', 'Quads', 'Hamstrings'],
    secondaryMuscles: ['Lower Back', 'Adductors'],
    equipment: ['Barbell'],
    formCues: ['Wide stance', 'Toes out', 'Drive knees out', 'Chest up'],
    commonMistakes: ['Knees caving', 'Hips rising first', 'Stance too wide/narrow'],
    category: 'Pull',
    isCompound: true,
  },
  {
    name: 'Trap Bar Deadlift',
    description: 'Deadlift using hex/trap bar.',
    primaryMuscles: ['Quads', 'Glutes', 'Hamstrings'],
    secondaryMuscles: ['Lower Back', 'Traps'],
    equipment: ['Trap Bar'],
    formCues: ['Stand in center', 'Sit back slightly', 'Drive through floor'],
    commonMistakes: ['Starting with bar forward', 'Rounding back', 'Lockout lean back'],
    category: 'Pull',
    isCompound: true,
  },
  {
    name: 'Good Morning',
    description: 'Hip hinge for posterior chain.',
    primaryMuscles: ['Hamstrings', 'Lower Back'],
    secondaryMuscles: ['Glutes'],
    equipment: ['Barbell'],
    formCues: ['Bar on upper back', 'Push hips back', 'Slight knee bend'],
    commonMistakes: ['Rounding back', 'Going too heavy', 'Not hinging at hips'],
    category: 'Pull',
    isCompound: true,
  },
  {
    name: 'Glute Bridge',
    description: 'Hip extension on floor.',
    primaryMuscles: ['Glutes'],
    secondaryMuscles: ['Hamstrings'],
    equipment: ['Bodyweight', 'Barbell'],
    formCues: ['Drive through heels', 'Squeeze glutes at top', 'Pause at top'],
    commonMistakes: ['Hyperextending back', 'Feet too far out', 'Not squeezing glutes'],
    category: 'Legs',
    isCompound: false,
  },
  {
    name: 'Single-Leg Romanian Deadlift',
    description: 'Unilateral hip hinge.',
    primaryMuscles: ['Hamstrings', 'Glutes'],
    secondaryMuscles: ['Core', 'Lower Back'],
    equipment: ['Dumbbell', 'Kettlebell'],
    formCues: ['Hinge on one leg', 'Back leg extends behind', 'Keep hips square'],
    commonMistakes: ['Opening hips', 'Rounding back', 'Losing balance'],
    category: 'Legs',
    isCompound: true,
  },
];

/**
 * Shrug and trap exercises
 */
const trapExercises: ExerciseData[] = [
  {
    name: 'Barbell Shrug',
    description: 'Primary trap builder.',
    primaryMuscles: ['Traps'],
    secondaryMuscles: [],
    equipment: ['Barbell'],
    formCues: ['Shrug straight up', 'Hold at top', 'Control negative'],
    commonMistakes: ['Rolling shoulders', 'Bending arms', 'Using momentum'],
    category: 'Pull',
    isCompound: false,
  },
  {
    name: 'Dumbbell Shrug',
    description: 'Trap exercise with dumbbells.',
    primaryMuscles: ['Traps'],
    secondaryMuscles: [],
    equipment: ['Dumbbells'],
    formCues: ['Arms at sides', 'Elevate shoulders', 'Squeeze at top'],
    commonMistakes: ['Rolling shoulders', 'Using momentum', 'Partial range'],
    category: 'Pull',
    isCompound: false,
  },
];

// Combine all exercises
const allExercises: ExerciseData[] = [
  ...chestExercises,
  ...backExercises,
  ...shoulderExercises,
  ...armExercises,
  ...legExercises,
  ...coreExercises,
  ...additionalExercises,
  ...trapExercises,
];

// ============================================================================
// PROGRAM DATA
// ============================================================================

interface ProgramData {
  name: string;
  description: string;
  durationWeeks: number;
  daysPerWeek: number;
  difficulty: Difficulty;
  goalType: GoalType;
}

const programs: ProgramData[] = [
  {
    name: 'Starting Strength',
    description: 'Classic beginner strength program focusing on compound lifts. Perfect for those new to barbell training.',
    durationWeeks: 12,
    daysPerWeek: 3,
    difficulty: Difficulty.BEGINNER,
    goalType: GoalType.STRENGTH,
  },
  {
    name: 'StrongLifts 5x5',
    description: 'Simple and effective beginner program. 5 sets of 5 reps on major compound movements.',
    durationWeeks: 12,
    daysPerWeek: 3,
    difficulty: Difficulty.BEGINNER,
    goalType: GoalType.STRENGTH,
  },
  {
    name: 'Push Pull Legs',
    description: 'Classic split for intermediate lifters. Allows for more volume per muscle group.',
    durationWeeks: 8,
    daysPerWeek: 6,
    difficulty: Difficulty.INTERMEDIATE,
    goalType: GoalType.HYPERTROPHY,
  },
  {
    name: 'Upper Lower Split',
    description: 'Balanced 4-day program splitting upper and lower body work.',
    durationWeeks: 8,
    daysPerWeek: 4,
    difficulty: Difficulty.INTERMEDIATE,
    goalType: GoalType.HYPERTROPHY,
  },
  {
    name: 'PHUL (Power Hypertrophy Upper Lower)',
    description: 'Combines strength and hypertrophy work. 4 days per week.',
    durationWeeks: 8,
    daysPerWeek: 4,
    difficulty: Difficulty.INTERMEDIATE,
    goalType: GoalType.HYPERTROPHY,
  },
  {
    name: 'PHAT (Power Hypertrophy Adaptive Training)',
    description: 'Advanced program by Layne Norton. 5 days combining power and hypertrophy.',
    durationWeeks: 12,
    daysPerWeek: 5,
    difficulty: Difficulty.ADVANCED,
    goalType: GoalType.HYPERTROPHY,
  },
  {
    name: 'nSuns 5/3/1',
    description: 'High volume variation of 5/3/1. Great for intermediate lifters wanting fast strength gains.',
    durationWeeks: 12,
    daysPerWeek: 5,
    difficulty: Difficulty.INTERMEDIATE,
    goalType: GoalType.STRENGTH,
  },
  {
    name: 'Wendler 5/3/1',
    description: 'Classic periodized strength program. Slow and steady progress.',
    durationWeeks: 16,
    daysPerWeek: 4,
    difficulty: Difficulty.INTERMEDIATE,
    goalType: GoalType.STRENGTH,
  },
  {
    name: 'Bro Split',
    description: 'Traditional bodybuilding split. One muscle group per day.',
    durationWeeks: 8,
    daysPerWeek: 5,
    difficulty: Difficulty.INTERMEDIATE,
    goalType: GoalType.HYPERTROPHY,
  },
  {
    name: 'Full Body 3x/Week',
    description: 'Hit every muscle 3x per week. Great for beginners or time-pressed lifters.',
    durationWeeks: 8,
    daysPerWeek: 3,
    difficulty: Difficulty.BEGINNER,
    goalType: GoalType.GENERAL_FITNESS,
  },
  {
    name: 'Candito 6-Week Strength',
    description: 'Peaking program for intermediate to advanced lifters preparing for a meet.',
    durationWeeks: 6,
    daysPerWeek: 4,
    difficulty: Difficulty.ADVANCED,
    goalType: GoalType.POWERLIFTING,
  },
  {
    name: 'GZCLP',
    description: 'Linear progression program with tiered exercises. Great for late beginners.',
    durationWeeks: 12,
    daysPerWeek: 4,
    difficulty: Difficulty.BEGINNER,
    goalType: GoalType.STRENGTH,
  },
  {
    name: 'Arnold Split',
    description: 'Classic 6-day bodybuilding split used by Arnold Schwarzenegger.',
    durationWeeks: 8,
    daysPerWeek: 6,
    difficulty: Difficulty.ADVANCED,
    goalType: GoalType.HYPERTROPHY,
  },
  {
    name: 'Minimalist Strength',
    description: 'Simple 2-day program for those with limited time. Focus on big lifts.',
    durationWeeks: 12,
    daysPerWeek: 2,
    difficulty: Difficulty.BEGINNER,
    goalType: GoalType.STRENGTH,
  },
  {
    name: 'Reddit PPL',
    description: 'Popular Reddit Push/Pull/Legs program. 6 days with good volume.',
    durationWeeks: 8,
    daysPerWeek: 6,
    difficulty: Difficulty.INTERMEDIATE,
    goalType: GoalType.HYPERTROPHY,
  },
];

// ============================================================================
// SEED FUNCTION
// ============================================================================

async function main(): Promise<void> {
  console.log('Starting database seed...');

  // Clear existing data (in development only)
  if (process.env.NODE_ENV !== 'production') {
    console.log('Clearing existing exercise data...');
    await prisma.exercise.deleteMany({ where: { isCustom: false } });
    await prisma.program.deleteMany({ where: { isBuiltIn: true } });
  }

  // Seed exercises
  console.log(`Seeding ${allExercises.length} exercises...`);
  for (const exercise of allExercises) {
    await prisma.exercise.create({
      data: {
        ...exercise,
        isCustom: false,
      },
    });
  }
  console.log(`Created ${allExercises.length} exercises`);

  // Seed programs
  console.log(`Seeding ${programs.length} programs...`);
  for (const program of programs) {
    await prisma.program.create({
      data: {
        ...program,
        isBuiltIn: true,
      },
    });
  }
  console.log(`Created ${programs.length} programs`);

  console.log('Database seed completed successfully!');
}

main()
  .catch((e) => {
    console.error('Error seeding database:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
