# GHCR Pull-Based Deploy

This replaces on-server Docker builds with GitHub Container Registry image pulls.

## Published images

- `ghcr.io/filipelagrenade/trainingapp-backend`
- `ghcr.io/filipelagrenade/trainingapp-web`

Both images are published automatically from GitHub Actions on every push to `main`.

## One-time GitHub setup

1. Open the repository on GitHub
2. Go to `Settings -> Actions -> General`
3. Ensure Actions has permission to read and write packages
4. Push to `main` once after the workflow file lands, or manually run the workflow

## One-time droplet setup

1. Create a GitHub personal access token with:
   - `read:packages`

2. Log in to GHCR on the Droplet:

```bash
echo YOUR_GITHUB_PAT | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin
```

3. Add image names to `.env.production`:

```env
BACKEND_IMAGE=ghcr.io/filipelagrenade/trainingapp-backend:latest
WEB_IMAGE=ghcr.io/filipelagrenade/trainingapp-web:latest
```

## Deploy from registry

Run:

```bash
bash scripts/deploy-ghcr.sh
```

If you need initial seed data:

```bash
bash scripts/seed-ghcr.sh
```

## Update flow

After pushing to `main` and waiting for the workflow to publish new images:

```bash
cd /root/liftiq
git fetch origin
git reset --hard origin/main
bash scripts/deploy-ghcr.sh
```

No local Docker build is needed on the Droplet.
