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

# Build React app
RUN echo "🔨 Building React frontend..." && \
    npm run build && \
    echo "✅ React build complete" && \
    ls -la /app/web/ && \
    ls -la /app/web/build 2>/dev/null || echo "⚠️ Build directory not found"

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
# Ensure package.json is present so `npm start` works
COPY --from=backend-builder /app/api/package*.json ./

# Copy React build to multiple common locations so server can find it
# (covers different Docker layouts and local dev locations)
COPY --from=frontend-builder /app/web/build ./public
COPY --from=frontend-builder /app/web/build ./server/public
COPY --from=frontend-builder /app/web/build ./web/build

# Verify React build was copied
RUN echo "📁 Verifying build files..." && \
    ls -la /app/ && \
    ls -la /app/public 2>/dev/null || echo "⚠️ Public folder not found" && \
    ls -la /app/server/public 2>/dev/null || echo "⚠️ server/public folder not found" && \
    ls -la /app/web/build 2>/dev/null || echo "⚠️ /app/web/build not found"

ENV NODE_ENV=production
EXPOSE 3000

CMD ["npm", "start"]