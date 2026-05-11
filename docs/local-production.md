# Running LiftIQ from your local PC (Cloudflare Tunnel)

Replace the DigitalOcean droplet with your local machine using a Cloudflare Tunnel to serve traffic.

## Prerequisites

- Docker Desktop installed on your PC
- SSH access to the current droplet (for DB migration)
- Cloudflare account with `lagrenade.dev` managed there

## Step 1: Create the Cloudflare Tunnel

1. Go to [Cloudflare Zero Trust Dashboard](https://one.dash.cloudflare.com/) → Networks → Tunnels
2. Click **Create a tunnel** → choose **Cloudflared** connector
3. Name it `liftiq-local`
4. Copy the **tunnel token**
5. In the **Public Hostname** tab, add two routes:
   - `liftiq.lagrenade.dev` → `http://web:3000` (type: HTTP)
   - `liftiq.lagrenade.dev/api/*` → `http://backend:4000` (type: HTTP)

## Step 2: Configure environment

```bash
cp .env.local-prod.example .env.local-prod
```

Edit `.env.local-prod` and fill in:
- `CLOUDFLARE_TUNNEL_TOKEN` — the token from Step 1
- `POSTGRES_PASSWORD` — pick a secure password
- Update the `DATABASE_URL` password to match

## Step 3: Migrate the database from the droplet

Start Postgres first:

```bash
docker compose --env-file .env.local-prod -f docker-compose.prod.yml up -d postgres
```

Dump from the droplet and restore locally:

```bash
./scripts/migrate-from-droplet.sh <droplet-ip>
```

## Step 4: Start everything

```bash
docker compose \
  --env-file .env.local-prod \
  -f docker-compose.prod.yml \
  -f docker-compose.tunnel.yml \
  up -d
```

This runs: Postgres, Backend, Web, and Cloudflare Tunnel. Caddy is not needed — Cloudflare handles TLS at the edge.

## Verify

- Check containers: `docker compose -f docker-compose.prod.yml -f docker-compose.tunnel.yml ps`
- Check tunnel status in the [Zero Trust dashboard](https://one.dash.cloudflare.com/)
- Visit `https://liftiq.lagrenade.dev`

## Shutting down the droplet

Once you've confirmed everything works locally:

1. Keep the droplet around for a day or two as a fallback
2. Take a snapshot if you want a safety net
3. Destroy the droplet
