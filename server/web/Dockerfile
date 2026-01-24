# ============================================
# Stage 1: Build React Frontend
# ============================================
FROM node:18-alpine AS frontend-builder

WORKDIR /app/web

COPY server/web/package*.json ./
RUN npm install

COPY server/web/src ./src
COPY server/web/public ./public
COPY server/web/tsconfig.json ./
COPY server/web/tailwind.config.js ./
COPY server/web/index.html ./

RUN npm run build

# ============================================
# Stage 2: Build Backend
# ============================================
FROM node:18-alpine AS backend-builder

WORKDIR /app/api

COPY server/api/package*.json ./
RUN npm install

COPY server/api/prisma ./prisma
RUN npx prisma generate

COPY server/api/routes ./routes
COPY server/api/src ./src
COPY server/api/utils ./utils
COPY server/api/*.js ./

# ============================================
# Stage 3: Production Image
# ============================================
FROM node:18-alpine

WORKDIR /app

# Copy backend node_modules and source
COPY --from=backend-builder /app/api/node_modules ./node_modules
COPY --from=backend-builder /app/api/prisma ./prisma
COPY --from=backend-builder /app/api/routes ./routes
COPY --from=backend-builder /app/api/src ./src
COPY --from=backend-builder /app/api/utils ./utils
COPY --from=backend-builder /app/api/*.js ./

# Copy React build to public folder (Express will serve it)
COPY --from=frontend-builder /app/web/build ./public

ENV NODE_ENV=production
EXPOSE 3000

CMD ["npm", "start"]