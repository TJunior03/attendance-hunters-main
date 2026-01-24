# Step-by-Step: Build, Test, Deploy

## 🏗️ LOCAL TESTING (Before Deploying)

### **Prerequisites**
- Node.js 18+ installed
- PostgreSQL database (or Neon account)
- Git repository configured

### **Step 1: Prepare Environment Variables**

Create/Update `server/api/.env`:
```bash
NODE_ENV=production
PORT=3000
DATABASE_URL="postgresql://user:password@host:5432/attendance?channel_binding=require"
JWT_SECRET="your-secret-key-12345"
```

Create/Update `.env.production`:
```bash
NODE_ENV=production
PORT=3000
DATABASE_URL="postgresql://user:password@host:5432/attendance?channel_binding=require"
JWT_SECRET="your-secret-key-12345"
```

### **Step 2: Install Frontend Dependencies**

```bash
cd server/web
npm install
```

**Expected Output**:
```
✓ Installed successfully
✓ Found X packages
```

### **Step 3: Build React Frontend**

```bash
cd server/web
npm run build
```

**Expected Output**:
```
✓ built dist/
✓ build 221 files
✓ built at: index.html
```

**What This Does**: Creates `server/web/build/` folder with optimized React files

### **Step 4: Install Backend Dependencies**

```bash
cd server/api
npm install
```

**Expected Output**:
```
✓ Installed successfully
✓ Found X packages
```

### **Step 5: Generate Prisma Client**

```bash
cd server/api
npx prisma generate
```

**Expected Output**:
```
✓ Generated Prisma Client
✓ @prisma/client library
```

### **Step 6: Test Database Connection**

```bash
cd server/api
npx prisma db push --skip-generate
```

**Expected Output**:
```
✓ Your database is now in sync with your schema
```

**If Error**: 
- Check `DATABASE_URL` is correct
- Verify database exists
- Ensure `channel_binding=require` in connection string

### **Step 7: Start the Server**

```bash
cd server/api
npm start
```

**Expected Output**:
```
✅ Environment loaded
✅ DATABASE_URL is set
✅ PORT: 3000
✅ NODE_ENV: production
🚀 Server running on port 3000
✅ Frontend: http://localhost:3000/
✅ API: http://localhost:3000/api/health
```

### **Step 8: Test in Another Terminal**

Keep the server running in step 7 open. In a new terminal:

#### **Test 1: Frontend Home Page**
```bash
curl http://localhost:3000/
```

**Expected**: HTML response (React app)

#### **Test 2: Frontend Admin Page**
```bash
curl http://localhost:3000/admin
```

**Expected**: HTML response (same React app, client-side routing)

#### **Test 3: API Health Check**
```bash
curl http://localhost:3000/api/health
```

**Expected**: 
```json
{
  "status": "ok",
  "environment": "production",
  "port": 3000,
  "database": "✅ configured"
}
```

#### **Test 4: API Login (Will Fail - Expected)**
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"wrongpassword"}'
```

**Expected**: 
```json
{
  "error": "Invalid credentials"
}
```

Or if admin exists:
```json
{
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {...}
}
```

### **Test 5: Open in Browser**

Visit: `http://localhost:3000`

**Expected**:
- ✅ Login page loads
- ✅ No errors in DevTools Console
- ✅ Network tab shows API calls are JSON (not HTML)

---

## 🐳 DOCKER TESTING (Optional - Advanced)

To test the Docker image locally before deploying:

### **Build Docker Image**

```bash
docker build -f server/web/Dockerfile -t attendance-hunters:latest .
```

**Expected**: 
```
Step 1/XX : FROM node:18-alpine AS frontend-builder
...
Successfully built abc123def456
```

### **Run Docker Container**

```bash
docker run -p 3000:3000 \
  -e DATABASE_URL="postgresql://..." \
  -e JWT_SECRET="your-secret" \
  -e NODE_ENV=production \
  attendance-hunters:latest
```

**Expected**:
```
🚀 Server running on port 3000
✅ Frontend: http://localhost:3000/
✅ API: http://localhost:3000/api/health
```

### **Test Docker Container**

In another terminal:
```bash
curl http://localhost:3000/api/health
```

---

## 🚀 RENDER DEPLOYMENT

### **Step 1: Prepare**

- [ ] Local tests pass (all 5 tests above succeed)
- [ ] Code committed to GitHub
- [ ] Render account set up

### **Step 2: Delete Static Site Service**

1. Go to: https://dashboard.render.com/
2. Find: `attendance-hunters-main-1` (the Static Site)
3. Click Settings → Delete Service
4. Type service name and confirm
5. Wait for deletion to complete

### **Step 3: Update Node Service Settings**

1. Go to: https://dashboard.render.com/
2. Click: `attendance-hunters-main` (Node service)
3. Click: Settings

#### **Update Root Directory** (if needed):
- Clear any existing root directory path
- Set to: `/` (default, empty is ok)

#### **Update Build Command**:
```bash
cd server/api && npm install
```

#### **Update Start Command**:
```bash
npm start
```

#### **Set Dockerfile**:
- Set Dockerfile path to: `server/web/Dockerfile`
- Set Docker Context to: `/`

### **Step 4: Set Environment Variables**

In Render Settings → Environment:

```
NODE_ENV=production
PORT=3000
DATABASE_URL=postgresql://user:password@host:5432/db?channel_binding=require
JWT_SECRET=your-secret-key
```

> **Important**: Use exact same values as local testing

### **Step 5: Deploy**

Option A: **Manual Deploy**
1. Click "Manual Deploy"
2. Wait 3-5 minutes for build

Option B: **Auto Deploy**
1. Push code to GitHub: `git push origin main`
2. Wait for auto-deploy

### **Step 6: Monitor Build**

In Render, click on service and watch "Build & Deploy" logs:

```
✓ Docker build started
✓ Fetching latest code from GitHub
✓ Building...
Step 1/XX: FROM node:18-alpine
...
✓ Build successful
✓ Starting app...
🚀 Server running on port 3000
```

**If Build Fails**: Check logs for:
- `DATABASE_URL not found` → Set in environment vars
- `Cannot find prisma schema` → Verify prisma/ folder exists
- `npm: not found` → Dockerfile issue

### **Step 7: Test Deployed App**

Get your Render URL from dashboard (e.g., `https://attendance-hunters-abc123.onrender.com`)

#### **Test 1: Frontend**
```bash
curl https://attendance-hunters-abc123.onrender.com/
```

#### **Test 2: API Health**
```bash
curl https://attendance-hunters-abc123.onrender.com/api/health
```

**Expected**:
```json
{
  "status": "ok",
  "environment": "production",
  "port": 3000,
  "database": "✅ configured"
}
```

#### **Test 3: In Browser**

Visit: `https://attendance-hunters-abc123.onrender.com`

**Should See**:
- ✅ Login page loads
- ✅ No "Unable to connect to server" error
- ✅ Can click to admin page

#### **Test 4: Login Test**

1. Open DevTools → Network tab
2. Enter credentials and click Login
3. Check that `/api/auth/login` request returns:
   - **Content-Type**: `application/json`
   - **Status**: `200` (success) or `401` (wrong password)
   - **Response**: JSON object, NOT HTML

---

## ✅ VERIFICATION CHECKLIST

### **Before Pushing to Production**

- [ ] `npm start` works locally
- [ ] `/` returns HTML (React app)
- [ ] `/admin` returns HTML (same app, client routes)
- [ ] `/api/health` returns JSON with `"status": "ok"`
- [ ] API calls return JSON, never HTML
- [ ] Database connection works
- [ ] No console errors in DevTools

### **After Deploying to Render**

- [ ] App URL loads (no timeout)
- [ ] Login page visible
- [ ] Login attempt shows network request is JSON
- [ ] `/api/health` responds with JSON
- [ ] Render logs show "Server running on port 3000"
- [ ] No error messages in logs

---

## 🔧 TROUBLESHOOTING

### **Local: "Cannot find module"**
```bash
cd server/api && npm install
cd ../web && npm install
```

### **Local: "DATABASE_URL not set"**
```bash
# Check file exists
cat server/api/.env

# Check it has DATABASE_URL line
# If not, add it:
echo 'DATABASE_URL="postgresql://..."' >> server/api/.env
```

### **Local: "Prisma not initialized"**
```bash
cd server/api
npx prisma generate
npx prisma db push --skip-generate
```

### **Render: Build Fails with "node_modules not found"**
- Set Build Command to: `cd server/api && npm install`
- Don't set it to custom npm script

### **Render: "Port is already in use"**
- Set `PORT=3000` in Render environment variables
- Don't run multiple instances

### **Render: Frontend works but API returns 404**
- Check API routes are mounted in server.js
- Verify `/api/` prefix is in Render start command
- Check Dockerfile copies routes correctly

---

## 📊 Full Deployment Timeline

| Step | Time | Action |
|------|------|--------|
| 1-6 | 10 min | Local setup & testing |
| 7-8 | 5 min | Docker setup (optional) |
| 9 | 1 min | Delete Static Site |
| 10 | 1 min | Update Node service settings |
| 11 | 5 min | Build and deploy |
| 12-14 | 2 min | Test deployed app |
| **Total** | **~25 min** | **Full deployment** |

---

## 🎉 You're Done!

Once all tests pass, your app is:
- ✅ Running on a single Node service
- ✅ Serving React frontend from `/`
- ✅ Handling API requests at `/api/*`
- ✅ Connected to Neon database
- ✅ Using JWT authentication
- ✅ Production-ready!
