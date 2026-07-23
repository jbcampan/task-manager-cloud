# ─── Stage 1: Builder ─────────────────────────────────────────────────────────
FROM node:22-slim AS builder
WORKDIR /app

RUN apt-get update && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
COPY apps/backend/package.json ./apps/backend/
RUN npm ci --ignore-scripts

COPY apps/backend/tsconfig*.json apps/backend/nest-cli.json ./apps/backend/
COPY apps/backend/src/ ./apps/backend/src/
COPY apps/backend/prisma/ ./apps/backend/prisma/

WORKDIR /app/apps/backend
RUN npx prisma generate
RUN npm run build

# ─── Stage 2: Runner ──────────────────────────────────────────────────────────
FROM node:22-slim AS runner
WORKDIR /app

RUN apt-get update && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*

RUN rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx /usr/local/bin/corepack

RUN groupadd --system --gid 1001 nodejs \
  && useradd --system --uid 1001 --gid nodejs nestjs

COPY --from=builder --chown=nestjs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nestjs:nodejs /app/apps/backend/dist ./dist
COPY --from=builder --chown=nestjs:nodejs /app/node_modules/.prisma ./node_modules/.prisma
COPY --chown=nestjs:nodejs apps/backend/prisma/ ./prisma/
COPY --chown=nestjs:nodejs --chmod=755 apps/backend/entrypoint.sh ./entrypoint.sh

USER nestjs
EXPOSE 3001

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD node -e "fetch('http://localhost:3001/api/v1/health/live').then(r=>r.ok?process.exit(0):process.exit(1)).catch(()=>process.exit(1))"

ENTRYPOINT ["./entrypoint.sh"]