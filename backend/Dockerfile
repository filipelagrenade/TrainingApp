# =============================================================================
# Stage 1: Build Flutter web app
# =============================================================================
FROM ghcr.io/cirruslabs/flutter:stable AS flutter-build

WORKDIR /app

COPY app/ ./app/

WORKDIR /app/app
RUN flutter pub get
RUN flutter build web --release

# =============================================================================
# Stage 2: Build Node.js backend (needs devDependencies for tsc)
# =============================================================================
FROM node:20-slim AS backend-build

WORKDIR /app

COPY backend/package.json backend/package-lock.json ./
RUN npm ci

COPY backend/prisma ./prisma
RUN npx prisma generate

COPY backend/tsconfig.json ./
COPY backend/src ./src
RUN npx tsc

# =============================================================================
# Stage 3: Production runtime
# =============================================================================
FROM node:20-slim

RUN apt-get update -y && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY backend/package.json backend/package-lock.json ./
RUN npm ci --omit=dev

COPY backend/prisma ./prisma
RUN npx prisma generate

# Copy compiled JS from build stage
COPY --from=backend-build /app/dist ./dist

# Copy Flutter web build
COPY --from=flutter-build /app/app/build/web ./public/

EXPOSE 8080

CMD ["node", "dist/index.js"]
