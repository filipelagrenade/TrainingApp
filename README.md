# LiftIQ

> Your AI lifting coach that actually understands progressive overload

LiftIQ is a workout tracking application that combines the logging speed of Strong/Hevy with intelligent AI guidance for progressive overload - the missing middle ground between "dumb trackers" and expensive coaching platforms.

## Features

### Core Features
- **Lightning-Fast Logging** - Log sets in under 3 seconds with pre-filled suggestions
- **Progressive Overload Engine** - Smart weight progression recommendations
- **Plateau Detection** - Automatic identification when exercises stall, with evidence-based intervention suggestions
- **Offline-First** - Full functionality without internet, syncs when connected

### AI Coach
- **Chat Interface** - Ask questions about form, programming, and get personalized advice
- **Contextual Tips** - Smart guidance during workouts
- **Exercise Alternatives** - Get substitutions for injuries or equipment limitations

### Analytics
- **1RM Tracking** - Estimated and tested max tracking with trend visualization
- **Volume Analytics** - Track volume per muscle group over time
- **Workout Consistency** - Calendar view of training frequency

### Social
- **Activity Feed** - See friends' workouts and PRs
- **Challenges** - Weekly/monthly competitive challenges

## Tech Stack

| Component | Technology |
|-----------|------------|
| Mobile App | Flutter + Riverpod + Isar |
| Web Dashboard | Next.js + shadcn/ui + TanStack Query |
| Backend API | Node.js + TypeScript + Express + Prisma |
| Database | PostgreSQL |
| AI | Groq (Llama 3) |
| Auth | Firebase Auth |
| Hosting | Railway |

## Project Structure

```
/TrainingApp
├── backend/          # Node.js API
├── app/              # Flutter mobile app
├── web/              # Next.js web dashboard
└── docs/             # Documentation
    ├── features/     # Feature breakdowns
    └── handover/     # Agent handover docs
```

## Getting Started

### Prerequisites

- Node.js 20.x LTS
- Flutter (latest stable)
- PostgreSQL 15+
- pnpm (for web app)

### Backend Setup

```bash
cd backend
npm install
cp .env.example .env
# Edit .env with your database and Firebase credentials
npx prisma migrate dev
npx prisma db seed
npm run dev
```

### Flutter App Setup

```bash
cd app
flutter pub get
flutter run
```

### Web Dashboard Setup

```bash
cd web
pnpm install
cp .env.example .env.local
# Edit .env.local with your API URL
pnpm dev
```

## Development

See the CLAUDE.md files in each directory for development guidelines:

- [Root CLAUDE.md](./CLAUDE.md) - Project-wide rules and conventions
- [Backend CLAUDE.md](./backend/CLAUDE.md) - Node.js/TypeScript patterns
- [App CLAUDE.md](./app/CLAUDE.md) - Flutter development guidelines
- [Web CLAUDE.md](./web/CLAUDE.md) - Next.js/React patterns

## Testing

### Backend
```bash
cd backend
npm test                 # All tests
npm run test:coverage    # With coverage report
```

### Flutter
```bash
cd app
flutter test             # All tests
flutter test --coverage  # With coverage
```

### Web
```bash
cd web
pnpm test               # Unit tests
pnpm test:e2e           # E2E tests
```

## Contributing

1. Read the relevant CLAUDE.md file for the area you're working on
2. Follow the Feature Completion Protocol for all new features
3. Ensure 90%+ test coverage
4. Create feature documentation and handover documents

## License

Proprietary - All rights reserved

---

*Built with the help of Claude Code*
