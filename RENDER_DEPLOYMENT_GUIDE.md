# RENDER DEPLOYMENT SETUP GUIDE

## ❌ CRITICAL: Current Architecture Issue

The app has TWO separate services that must run together on Render:

1. **Frontend Service** (Nginx + React SPA)
   - Built from: `server/web/Dockerfile`
   - Serves: React frontend + proxies `/api/*` to backend

2. **Backend Service** (Node.js + Express API)
   - Entry point: `server/api/server.js`
   - Runs: Express server on port 3000
   - Accesses: Neon PostgreSQL database

**PROBLEM**: If only frontend is deployed, the backend is not running, so:
- `/api/auth/login` → Nginx tries to proxy to localhost:3000 → No service → 502 Bad Gateway → HTML error → Frontend receives HTML instead of JSON → JSON parse error

---

## ✅ FIX: Set Up Both Services on Render

### Step 1: Frontend Service (Nginx + React)

**Name**: `attendance-frontend`

1. Connect GitHub repo
2. **Build Command**: (leave empty - Dockerfile will handle it)
3. **Dockerfile Path**: `server/web/Dockerfile`
4. **Environment Variables**: None needed for frontend
5. **Deploy**

### Step 2: Backend Service (Node.js)

**Name**: `attendance-backend`

1. Connect GitHub repo
2. **Build Command**: 
   ```bash
   cd server/api && npm install && npm run build
   ```
3. **Start Command**: 
   ```bash
   cd server/api && npm start
   ```
4. **Environment Variables**: Set these EXACTLY:
   ```
   DATABASE_URL=postgresql://neondb_owner:npg_pf0LmSdbGr6F@ep-blue-firefly-a43533yo-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require
   JWT_SECRET=b0f7c04b9ee54f06a2a0d12e1ac2a387e5cfba67b1b2e4f1aef1c2cc42c8e87d
   NODE_ENV=production
   PORT=3000
   ```
5. **Deploy**

### Step 3: Connect Services in Nginx Config

Update `server/web/nginx.conf` to proxy to backend service:

```nginx
location /api/ {
    proxy_pass http://attendance-backend:3000/api/;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-Host $server_name;
    proxy_set_header Connection "upgrade";
    proxy_set_header Upgrade $http_upgrade;
    
    proxy_connect_timeout 60s;
    proxy_send_timeout 60s;
    proxy_read_timeout 60s;
    proxy_buffering on;
    proxy_buffer_size 128k;
    proxy_buffers 4 256k;
}
```

**Key**: Use service name `attendance-backend` instead of `localhost:3000`
- Render's internal network will resolve this automatically
- Only works if both services are in same project

---

## 📋 What We Fixed

### ✅ 1. Added dotenv Loading
**File**: `server/api/server.js`
```javascript
require("dotenv").config();
```
Now environment variables are loaded from .env or Render dashboard.

### ✅ 2. Fixed All Prisma Imports
**Files**: 10 route files + middleware
Changed: `require('../db')` → `require('../prismaClient')`
Reason: db.js had broken path, prismaClient.js uses correct @prisma/client

### ✅ 3. Added Database Connection Validation
**File**: `server/api/prismaClient.js`
- Tests connection on startup
- Logs clear error messages if DATABASE_URL is missing
- Prevents silent failures

### ✅ 4. Added Health Check Endpoint
**File**: `server/api/server.js`
```bash
curl https://YOUR_BACKEND_URL/api/health
```
Shows environment status and database configuration.

### ✅ 5. Set Correct Ports
- Frontend: Port 80 (Nginx)
- Backend: Port 3000 (Express)
- Nginx proxies `/api/*` to backend:3000

### ✅ 6. Updated Environment Variables
**File**: `server/api/.env` and `.env.production`
- DATABASE_URL: Real Neon connection string
- JWT_SECRET: Real secret
- PORT: 3000 (for backend)
- NODE_ENV: production

---

## 🔍 Testing

### 1. Check Backend Health
```bash
curl https://your-backend-service.onrender.com/api/health
```
Expected response:
```json
{
  "status": "ok",
  "environment": "production",
  "port": 3000,
  "database": "✅ configured"
}
```

### 2. Test Admin Login
```bash
curl -X POST https://your-backend-service.onrender.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"adminpass"}'
```

### 3. Test Student Login  
```bash
curl -X POST https://your-backend-service.onrender.com/api/student-auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"student1@example.com","password":"student0101"}'
```

### 4. Visit Frontend
```
https://your-frontend-service.onrender.com
```
Should load React app.

### 5. Test SPA Routing
```
https://your-frontend-service.onrender.com/admin
```
Should load Admin Login page (no 404).

### 6. Test API Proxy from Frontend
In browser console:
```javascript
fetch('/api/health').then(r => r.json()).then(console.log)
```
Should return health check JSON.

---

## 🚨 Common Issues & Solutions

### Issue: /admin returns 404
**Cause**: Frontend service not deployed or Nginx config not applied
**Fix**: 
1. Deploy frontend service
2. Verify Nginx config has SPA fallback
3. Check Render logs for build errors

### Issue: "Unexpected end of JSON input" on login
**Cause**: Backend service not running or database not configured
**Fix**:
1. Deploy backend service
2. Set DATABASE_URL in Render environment
3. Check backend logs for connection errors
4. Run `curl /api/health` to test

### Issue: Connection refused on /api calls
**Cause**: Nginx trying to proxy to localhost:3000 instead of service name
**Fix**: Update nginx.conf to use `attendance-backend:3000`

### Issue: Database connection fails
**Cause**: DATABASE_URL missing or incorrect
**Fix**:
1. Get connection string from Neon dashboard
2. Set in Render → Settings → Environment Variables
3. Restart backend service
4. Check logs: `Database connection successful`

---

## 📦 Architecture After Deployment

```
User Browser
     ↓
Frontend Service (Nginx port 80)
     ├── Serves: React SPA from /usr/share/nginx/html
     └── Proxies: /api/* → Backend Service (internal network)
              ↓
         Backend Service (Express port 3000)
              ├── Loads: database URL from environment
              ├── Connects: to Neon PostgreSQL
              └── Returns: JSON responses
```

---

## ✅ Deployment Checklist

- [ ] Frontend service deployed with Dockerfile
- [ ] Backend service deployed (separate service)
- [ ] DATABASE_URL set in backend environment
- [ ] JWT_SECRET set in backend environment  
- [ ] NODE_ENV=production in backend
- [ ] PORT=3000 in backend
- [ ] Nginx config uses `attendance-backend:3000` for proxy
- [ ] Both services in same Render project (for internal networking)
- [ ] Backend service restarted after env var changes
- [ ] Verified /api/health returns success
- [ ] Verified /admin loads (no 404)
- [ ] Verified login endpoint returns JSON

---

## Next Steps

1. Delete frontend-only service if it exists
2. Create backend service
3. Set environment variables
4. Update Nginx proxy address
5. Deploy both services
6. Test endpoints
7. Monitor logs for errors

