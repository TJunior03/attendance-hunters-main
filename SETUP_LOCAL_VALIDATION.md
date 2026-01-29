# ✅ STEP-BY-STEP LOCAL SETUP — No Assumptions

## What This Does
- ✅ Test Neon database connection locally
- ✅ Validate Prisma client setup
- ✅ Start Express server with API + SPA
- ✅ Run React frontend dev server
- ✅ End-to-end verification

---

## Prerequisites
- Node.js 18+ installed
- `npm` or `yarn`
- Neon account with active database (https://neon.tech)
- Git repository cloned locally

---

## 🚀 QUICK START (Copy & Paste)

### Terminal 1: Validate Database + Start Backend

```bash
# Navigate to backend
cd server/api

# Install dependencies (if not already done)
npm ci

# Test Neon connection BEFORE starting server
echo "Testing Neon connection..."
node prismaClient.js

# Expected output:
# 📡 Attempting Neon database connection...
# ✅ Prisma connected to Neon database
```

**If that FAILS, STOP here and fix (see Troubleshooting below)**

```bash
# If connection successful, start Express server
npm start

# Expected output:
# ✅ Environment loaded
# ✅ DATABASE_URL is set
# ✅ PORT: 3000
# ✅ NODE_ENV: development
# ✅ Prisma connected to Neon database
# ✅ Static file serving enabled from: <path>
# 🚀 Server running on port 3000
# ✅ Frontend: http://localhost:3000/
# ✅ API: http://localhost:3000/api/health
```

**Keep this terminal open!**

---

### Terminal 2: Test API Endpoints

```bash
# Test 1: Health check
curl http://localhost:3000/api/health

# Expected response (JSON):
# {
#   "status": "ok",
#   "environment": "development",
#   "port": 3000,
#   "database": "✅ configured"
# }

# Test 2: Root (should return HTML, not JSON)
curl http://localhost:3000/

# Expected: HTML content starting with <!DOCTYPE html>
```

**If these fail, check server logs in Terminal 1**

---

### Terminal 3: Start React Frontend Dev Server

```bash
# Navigate to frontend
cd server/web

# Install dependencies
npm ci

# Start React dev server
npm start

# Expected output:
# Compiled successfully!
# On Your Network:  http://192.168.x.x:3000
#                   http://localhost:3000
# 
# Local:            http://localhost:3000
#                   http://localhost:3000
```

**React will open automatically or you can visit http://localhost:3000**

---

## 🧪 FULL VALIDATION (Do All These)

### 1️⃣ Browser Test: Load App
```
URL: http://localhost:3000
Expected: React login page loads (not JSON, not blank)
```

### 2️⃣ Browser Test: Navigate to Protected Route
```
URL: http://localhost:3000/admin (or /login)
Expected: Page loads (assumes React Router has this route)
```

### 3️⃣ Browser Test: Refresh Page
```
On page: /admin
Action: Press F5 or Cmd+R
Expected: Page STILL loads (not "Cannot GET /admin")
Why: Tests that SPA fallback works (Express serves index.html)
```

### 4️⃣ Browser Dev Tools: Check Network
```
Open: DevTools → Network tab
Actions:
  - Refresh page (F5)
  - Look for requests to:
    - index.html → should be 200 (HTML)
    - /static/js/main.*.js → should be 200 (JS)
    - /static/css/*.css → should be 200 (CSS)
    - /api/health → should be 200 (JSON)
Expected: NO 404s for main resources
```

### 5️⃣ Browser Dev Tools: Check Console
```
Open: DevTools → Console tab
Expected: No red error messages
If errors appear: Screenshot them and check troubleshooting
```

### 6️⃣ Terminal 2: Test API Routes

```bash
# Auth endpoint (adjust to your actual routes)
curl http://localhost:3000/api/auth/status

# Users endpoint
curl http://localhost:3000/api/users

# Expected: JSON response (not HTML, not 404)
```

### 7️⃣ Terminal 2: Test Database Query

```bash
# If you have a test endpoint, use it:
curl http://localhost:3000/api/test

# Expected: JSON with actual data from Neon
```

---

## 🆘 TROUBLESHOOTING

### Error: "Cannot find module 'dotenv'"
```bash
# In server/api directory:
npm ci
# Then try again
```

### Error: "DATABASE_URL not set"
```bash
# Check .env file exists and has DATABASE_URL=
cat server/api/.env | head -5

# If not there, create it from .env.local.example
cp .env.local.example server/api/.env
# Then EDIT .env and fill in real Neon credentials
```

### Error: "ECONNREFUSED" or "Cannot connect to database"
```bash
# 1. Verify .env has NO QUOTES around DATABASE_URL
cat server/api/.env | grep DATABASE_URL
# Should show: DATABASE_URL=postgresql://...
# NOT:         DATABASE_URL="postgresql://..."

# 2. Verify DATABASE_URL uses DIRECT connection (no -pooler)
# Direct:  ep-blue-firefly-a43533yo.us-east-1.aws.neon.tech
# Wrong:   ep-blue-firefly-a43533yo-pooler.us-east-1.aws.neon.tech

# 3. Verify DATABASE_URL has ?sslmode=require at end
echo $DATABASE_URL
# Should end with: ?sslmode=require

# 4. Test Neon credentials in Neon console
# Go to: https://console.neon.tech
# Click your project → Endpoints → Copy connection string
# Paste into .env
```

### Error: "role 'neondb_owner' does not exist"
```bash
# Username is wrong. Get correct one from:
# https://console.neon.tech → Project → SQL Editor
# Default user is usually 'postgres' or 'neondb_owner'
# Check the Neon console and copy exact string
```

### Error: "SSL connection requested but openssl.cnf"
```bash
# Remove ?channel_binding=require from DATABASE_URL if present
# Keep only: ?sslmode=require

# From:
# DATABASE_URL=...?sslmode=require&channel_binding=require
# To:
# DATABASE_URL=...?sslmode=require
```

### React page shows BLANK (white screen)
```bash
# 1. Check browser console (DevTools) for JS errors
# 2. Check Network tab for 404s on JS files
# 3. If /static/js/main.js is 404:
#    - Stop React server (Ctrl+C in Terminal 3)
#    - Delete node_modules: rm -rf server/web/node_modules
#    - Reinstall: npm ci
#    - Start again: npm start

# 4. If still blank, check server.js logs:
#    - Look for: "✅ Static file serving enabled from:"
#    - If not present, React build not found
#    - Run: cd server/web && npm run build
```

### React page shows "Cannot GET /admin" (JSON error)
```bash
# This means Express is NOT serving the React app
# Check:

# 1. Backend terminal: Is server running?
#    Should show: 🚀 Server running on port 3000

# 2. Check logs for: "✅ Static file serving enabled from:"
#    If missing: React build not found

# 3. Build React:
cd server/web
npm run build
ls -la build/index.html
# Should show: build/index.html exists

# 4. Restart Express:
cd server/api
npm start
# Should now show: ✅ Static file serving enabled from: ...
```

### API endpoint returns 404 (Not Found JSON)
```bash
# Check:
# 1. Endpoint is registered in server.js
#    Example: app.use("/api/users", usersRoutes);

# 2. Route file exists and exports router
#    Example: server/api/routes/users.js ends with: module.exports = router;

# 3. Check exact endpoint path matches
#    If registered as app.use("/api/users", ...) and route is app.get("/")
#    Then full path is /api/users/
```

---

## 📋 Verification Checklist

- [ ] Terminal 1: `node prismaClient.js` returns "✅ Prisma connected"
- [ ] Terminal 1: `npm start` logs "🚀 Server running on port 3000"
- [ ] Terminal 2: `curl http://localhost:3000/api/health` returns JSON
- [ ] Terminal 3: React dev server starts without errors
- [ ] Browser: Load http://localhost:3000 → React page visible
- [ ] Browser: F5 refresh on /admin → page still loads (not error)
- [ ] DevTools Network: No 404 errors for main resources
- [ ] DevTools Console: No red error messages
- [ ] Terminal 2: `curl http://localhost:3000/api/users` (or similar) returns JSON

---

## ✅ Ready for Deployment

When all above pass:
1. Push changes to GitHub
2. Go to Render Dashboard
3. Trigger manual deploy
4. Check Render logs for same success messages
5. Use same DATABASE_URL (production version with -pooler)

---

## 🚀 Production vs Local Differences

| Aspect | Local | Production (Render) |
|--------|-------|-----|
| Database Host | `ep-...-a43533yo` | `ep-...-a43533yo-pooler` |
| Connection Pool | Direct | Pooled |
| React Server | Separate (port 5173) | Served by Express |
| Static Files | From `server/web/build` | In Docker `/app/public` |
| Logs | Console | Render dashboard |
| .env | `server/api/.env` | Render dashboard env vars |

---

## 💡 Pro Tips

1. **Always test locally first** — This guide ensures everything works before Render
2. **Check logs first** — Most issues are in the logs (Terminal 1)
3. **Database is separate** — Connection issues are almost always .env formatting
4. **Keep API and SPA separate** — API routes first, SPA fallback last
5. **Use pooler for Render** — Connection pooling needed for production

Good luck! 🎉
