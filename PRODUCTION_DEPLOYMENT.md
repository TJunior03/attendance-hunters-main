# Production Deployment Guide - Attendance Hunters

## ✅ FINAL ARCHITECTURE DECISION

**Single Node.js Service** - Express serves both React frontend + API backend from one container

**Why**: 
- ✅ API requests always reach the backend (same origin)
- ✅ No proxy complexity
- ✅ Works perfectly on Render
- ✅ Simple, reliable, production-grade

---

## 🔧 What Changed

### 1. **Dockerfile** (`server/web/Dockerfile`)
- **3-stage build** for efficiency:
  - **Stage 1**: Build React frontend to `/app/web/build`
  - **Stage 2**: Install backend dependencies + generate Prisma client
  - **Stage 3**: Combine both - Express serves React from `./public` + handles API routes

### 2. **server.js** (`server/api/server.js`)
- **API routes first** - ensures `/api/*` requests go to Express handlers
- **React static serving** - serves built frontend from `./public` folder
- **SPA fallback** - non-API routes return `index.html` for React Router
- **Better error handling** - clear messages for missing routes

### 3. **Environment Variables**
- `NODE_ENV=production`
- `PORT=3000`
- `DATABASE_URL=` (Neon PostgreSQL connection string)
- `JWT_SECRET=` (for token signing)

---

## 📋 Render.com Deployment Steps

### **Step 1: DELETE the Static Site Service**

1. Go to **Render Dashboard**
2. Find and click `attendance-hunters-main-1` (the Static Site)
3. Click **Settings** → **Delete Service**
4. Type service name to confirm
5. **Service is deleted**

> **Why**: Static Site cannot handle API requests properly. We're consolidating into one service.

### **Step 2: Update the Node Service**

1. Go to **Render Dashboard**
2. Click `attendance-hunters-main` (the Node service)
3. Click **Settings**

#### Update Build Command:
```bash
cd server/api && npm install && npm run build
```

#### Update Start Command:
```bash
npm start
```

> **Note**: If `npm run build` doesn't exist, just use:
> ```bash
> cd server/api && npm install
> ```

#### Update Environment Variables:
Go to **Environment** tab and ensure these are set:
```
NODE_ENV=production
PORT=3000
DATABASE_URL=postgresql://[YOUR_NEON_URL_HERE]
JWT_SECRET=your-secret-key-here
```

### **Step 3: Update Dockerfile Path (if needed)**

1. In Service Settings → **Dockerfile** section
2. Set path to: `server/web/Dockerfile`
3. Set **Docker Context**: `/` (root of repository)

### **Step 4: Deploy**

1. Click **Manual Deploy** or push to GitHub to trigger auto-deploy
2. Wait for build to complete (3-5 minutes)

---

## 🧪 Verify Deployment

Once deployed, test these endpoints:

### **Test Frontend**
```bash
# Should return React app (HTML)
curl https://your-app.onrender.com/

# Should return React app (HTML) 
curl https://your-app.onrender.com/admin
```

### **Test API**
```bash
# Should return JSON health status
curl https://your-app.onrender.com/api/health

# Should return JSON (login response)
curl -X POST https://your-app.onrender.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"password"}'
```

### **Verify No HTML in API Responses**
- Open DevTools → Network tab
- Click login button
- API requests should return `application/json`
- NOT `text/html`

---

## 🔍 Troubleshooting

### **Build Fails: "Cannot find prisma schema"**
- Make sure `.env` has valid `DATABASE_URL`
- Verify `server/api/prisma/schema.prisma` exists
- Run locally: `cd server/api && npx prisma generate`

### **Frontend Returns 404**
- **Check**: React build exists in `./public` folder
- **Check**: `server.js` has static file serving middleware
- **Verify**: Build command ran successfully

### **API Returns HTML Instead of JSON**
- **Cause**: Request hit the SPA fallback route
- **Check**: API route path is correct (e.g., `/api/auth/login` not `/auth/login`)
- **Check**: API routes are mounted correctly in `server.js`

### **Database Connection Failed**
- **Check**: `DATABASE_URL` environment variable is set in Render
- **Verify**: URL has `channel_binding=require` for Neon
- **Test locally**: `npx prisma db push --accept-data-loss`

### **Port Already in Use**
- **Check**: `PORT` environment variable is set to `3000`
- **Verify**: No other services running on that port

---

## 📦 Local Development Testing

Before deploying, test the full stack locally:

### **1. Install Dependencies**
```bash
cd server/api
npm install

cd ../web
npm install
```

### **2. Build React**
```bash
cd server/web
npm run build
```

### **3. Start Backend**
```bash
cd server/api
npm start
```

### **4. Test URLs**
```bash
# React app
curl http://localhost:3000/

# React admin page
curl http://localhost:3000/admin

# API health
curl http://localhost:3000/api/health

# API login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"password"}'
```

**Expected Results**:
- ✅ `/` returns HTML (React app)
- ✅ `/admin` returns HTML (React app)
- ✅ `/api/health` returns JSON
- ✅ `/api/auth/login` returns JSON (with token or error)

---

## 📝 Key Files Modified

| File | Change | Purpose |
|------|--------|---------|
| `server/web/Dockerfile` | 3-stage build | Build React + Backend in one container |
| `server/api/server.js` | Express middleware order | Serve React from `./public`, then API routes |
| `server/api/.env` | DATABASE_URL, PORT | Production credentials |
| `.env.production` | DATABASE_URL, PORT | Backup production config |

---

## ✨ Architecture Summary

```
┌─────────────────────────────────────────────┐
│   Render: Single Node.js/Express Service    │
├─────────────────────────────────────────────┤
│                                             │
│  Request → Express Server (Port 3000)       │
│            ↓                                │
│  ┌────────────────────────────────────┐    │
│  │ Is it /api/* ?                     │    │
│  │ → Route to Express API handlers    │    │
│  │ → Connect to Neon Database         │    │
│  │ → Return JSON response             │    │
│  └────────────────────────────────────┘    │
│            ↓                                │
│  ┌────────────────────────────────────┐    │
│  │ Is it a static file (JS/CSS)?      │    │
│  │ → Serve from ./public              │    │
│  └────────────────────────────────────┘    │
│            ↓                                │
│  ┌────────────────────────────────────┐    │
│  │ Is it a React route (/admin, etc)? │    │
│  │ → Return index.html                │    │
│  │ → React Router handles client-side │    │
│  └────────────────────────────────────┘    │
│                                             │
└─────────────────────────────────────────────┘
```

---

## ✅ Pre-Deployment Checklist

- [ ] React builds successfully: `npm run build` in `server/web`
- [ ] Backend installs: `npm install` in `server/api`
- [ ] No Prisma errors: `npx prisma db push` succeeds
- [ ] Local test passes: All 4 curl tests above return correct responses
- [ ] `.env` has real `DATABASE_URL` (Neon connection string)
- [ ] `PORT` is set to `3000`
- [ ] `NODE_ENV=production`
- [ ] Static Site service deleted from Render
- [ ] Node service has correct start/build commands

---

## 🚀 After Deployment

1. **Monitor Logs**: Check Render logs for any startup errors
2. **Test Endpoints**: Run the 4 verification curl commands
3. **Check Frontend**: Visit `https://your-app.onrender.com/` and login
4. **Verify API**: Open DevTools → Network tab, check response types

---

**That's it! Your app is now running on a single, reliable Node.js service.** 🎉
