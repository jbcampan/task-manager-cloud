# syntax=docker/dockerfile:1

### Stage 1 — deps: install workspace dependencies ###
FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
COPY apps/frontend/package.json ./apps/frontend/package.json
RUN npm ci --workspace=apps/frontend --include-workspace-root=true

### Stage 2 — builder: compile the Next.js app (also used as the dev image, see docker-compose.yml) ###
FROM node:20-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY --from=deps /app/apps/frontend/node_modules ./apps/frontend/node_modules
COPY . .
RUN npm run build --workspace=apps/frontend

### Stage 3 — runner: minimal production image using the Next.js standalone output ###
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
RUN addgroup --system --gid 1001 nodejs && adduser --system --uid 1001 nextjs

RUN rm -rf \
    /usr/local/lib/node_modules/npm \
    /usr/local/bin/npm \
    /usr/local/bin/npx \
    /usr/local/bin/corepack

# The standalone output only ships the JS actually needed at runtime — public
# assets and static build output must be copied in separately.
COPY --from=builder /app/apps/frontend/public ./apps/frontend/public
COPY --from=builder --chown=nextjs:nodejs /app/apps/frontend/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/apps/frontend/.next/static ./apps/frontend/.next/static

USER nextjs
EXPOSE 3000
ENV PORT=3000
CMD ["node", "apps/frontend/server.js"]