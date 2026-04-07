# LiftIQ

LiftIQ is a server-first training companion built as a Next.js PWA plus an Express and Prisma API.

## Packages

- `web/`: Next.js App Router PWA with shadcn/ui, TanStack Query, and Jotai
- `backend/`: Express API with Prisma and PostgreSQL
- `archive/`: reference-only copy of the legacy codebase

## Local development

1. Make sure Docker Desktop is running
2. Start PostgreSQL with `docker compose up -d postgres`
3. Copy `backend/.env.example` to `backend/.env`
4. Copy `web/.env.example` to `web/.env.local`
5. Install dependencies inside `backend/` and `web/` if needed
6. Run `npm run db:migrate`
7. Run `npm run db:seed`
8. Start the backend with `npm run dev:backend`
9. Start the web app with `npm run dev:web`

## Production deployment

The repo is prepared for a DigitalOcean Droplet deployment with:

- `docker-compose.prod.yml`
- `deploy/Caddyfile`
- `.env.production.example`

Use the runbook in [docs/handover/digitalocean-deployment.md](docs/handover/digitalocean-deployment.md).

## Product focus

- fast workout logging
- program-centric progression
- cloud-only user-scoped data
- XP, levels, achievements, and social competition
