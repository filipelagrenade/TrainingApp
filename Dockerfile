# =============================================================================
# Stage 1: Build Node.js backend (needs devDependencies for tsc)
# =============================================================================
FROM node:20-slim AS backend-build

WORKDIR /app

# Copy entire backend directory at once
COPY backend/ ./

RUN npm ci

RUN npx prisma generate

RUN npx tsc

# =============================================================================
# Stage 2: Production runtime
# =============================================================================
FROM node:20-slim

RUN apt-get update -y && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy entire backend for package.json + prisma schema
COPY backend/package.json backend/package-lock.json ./
RUN npm ci --omit=dev

COPY backend/prisma ./prisma
RUN npx prisma generate

# Copy compiled JS from build stage
COPY --from=backend-build /app/dist ./dist

# Copy pre-built Flutter web app (built locally before `railway up`)
COPY app/build/web ./public/

# Verify Flutter build was copied
RUN ls -la ./public/index.html

EXPOSE 8080

CMD ["node", "dist/index.js"]
