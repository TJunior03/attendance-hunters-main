# Build stage
FROM node:18-alpine AS builder

WORKDIR /app

# Copy all files
COPY . .

# Build frontend
WORKDIR /app/server/web
RUN npm install
RUN npm run build

# Production stage
FROM node:18-alpine

# Install nginx
RUN apk add --no-cache nginx curl

WORKDIR /app

# Copy built frontend
COPY --from=builder /app/server/web/build /usr/share/nginx/html

# Copy backend
COPY server/api /app/backend

# Copy nginx configuration
COPY server/web/nginx.conf /etc/nginx/conf.d/default.conf

# Install backend dependencies
WORKDIR /app/backend
RUN npm install

# Create startup script that runs both Nginx and Node
RUN echo '#!/bin/sh\n\
cd /app/backend\n\
\n\
# Start Express backend on port 3000\n\
npm start &\n\
BACKEND_PID=$!\n\
\n\
# Wait for backend to start\n\
sleep 2\n\
\n\
# Start Nginx on port 80\n\
cd /\n\
nginx -g "daemon off;"\n\
' > /entrypoint.sh && chmod +x /entrypoint.sh

# Expose ports
EXPOSE 80 3000

# Start both services
CMD ["/entrypoint.sh"]