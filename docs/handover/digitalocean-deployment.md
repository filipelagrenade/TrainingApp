# DigitalOcean Droplet Deployment

This repo is set up to run on a single DigitalOcean Droplet with:

- `Caddy` as the public reverse proxy and HTTPS terminator
- `web` as the Next.js PWA
- `backend` as the Express API
- `Managed PostgreSQL` hosted separately on DigitalOcean

## Recommended infrastructure

- 1 Droplet: Ubuntu 24.04 LTS, Docker Engine installed
- 1 managed PostgreSQL cluster
- 1 DNS record pointing your app domain at the Droplet IP

## Files added for production

- `docker-compose.prod.yml`
- `.env.production.example`
- `deploy/Caddyfile`

## 1. Prepare the Droplet

SSH into the server and install Docker plus Compose if you have not already:

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER
```

Log out and back in once after adding the user to the Docker group.

## 2. Upload the app

Clone or copy the repo to the Droplet:

```bash
git clone <your-repo-url> liftiq
cd liftiq
```

## 3. Configure production env

Create the production env file:

```bash
cp .env.production.example .env.production
```

Set:

- `DOMAIN`: your live domain
- `LETSENCRYPT_EMAIL`: certificate email
- `APP_URL`: `https://<your-domain>`
- `NEXT_PUBLIC_API_URL`: `/api/v1`
- `DATABASE_URL`: your DigitalOcean managed PostgreSQL connection string with SSL enabled
- `SESSION_COOKIE_NAME`
- `SESSION_TTL_DAYS`

## 4. Run database migrations

Apply production migrations before starting the main app:

```bash
docker compose --env-file .env.production -f docker-compose.prod.yml run --rm migrate
```

If you want the initial seed data:

```bash
docker compose --env-file .env.production -f docker-compose.prod.yml run --rm backend npm run prisma:seed
```

## 5. Start the stack

```bash
docker compose --env-file .env.production -f docker-compose.prod.yml up -d --build
```

### Cloudflare Origin Certificate option

If your DNS is proxied through Cloudflare and you already have a Cloudflare Origin Certificate plus private key, use the Cloudflare-specific override instead of Let's Encrypt.

1. Create the cert directory on the Droplet:

```bash
mkdir -p deploy/certs
```

2. Save the Cloudflare origin certificate to `deploy/certs/origin.crt`

3. Save the Cloudflare private key to `deploy/certs/origin.key`

4. Lock down the key permissions:

```bash
chmod 600 deploy/certs/origin.key
```

5. In the Cloudflare dashboard, set SSL/TLS mode to `Full (strict)`.

6. Start the stack with the Cloudflare override:

```bash
docker compose --env-file .env.production -f docker-compose.prod.yml -f docker-compose.cloudflare.yml up -d --build
```

If you use the Cloudflare override, `LETSENCRYPT_EMAIL` is no longer used by Caddy.

## 6. Verify

Check containers:

```bash
docker compose --env-file .env.production -f docker-compose.prod.yml ps
```

Check backend health through Docker:

```bash
docker compose --env-file .env.production -f docker-compose.prod.yml exec backend wget -qO- http://127.0.0.1:4000/api/v1/health
```

Then open:

- `https://<your-domain>`
- `https://<your-domain>/api/v1/health`

## Deployment workflow

For updates:

```bash
git pull
docker compose --env-file .env.production -f docker-compose.prod.yml run --rm migrate
docker compose --env-file .env.production -f docker-compose.prod.yml up -d --build
```

If you are using the Cloudflare origin certificate override, use:

```bash
git pull
docker compose --env-file .env.production -f docker-compose.prod.yml run --rm migrate
docker compose --env-file .env.production -f docker-compose.prod.yml -f docker-compose.cloudflare.yml up -d --build
```

## Notes

- The app is deployed on one origin. Caddy proxies `/api/*` to the backend and everything else to the web app.
- `NEXT_PUBLIC_API_URL=/api/v1` keeps the browser on the same origin and avoids CORS complexity.
- `backend` healthchecks gate the reverse proxy and web startup so traffic does not route before the API is up.
- Managed PostgreSQL should stay outside the Droplet. Do not run production Postgres inside this compose stack.
