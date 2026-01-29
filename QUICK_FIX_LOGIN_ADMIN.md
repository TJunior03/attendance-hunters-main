# ⚡ QUICK FIX - 5 MINUTES

## 🎯 The Problem
- `/login` and `/admin` return "Cannot GET" error
- But `/api/health` works
- **Cause**: React frontend isn't being served

## ✅ The Fix (Do These 3 Things)

### **Step 1: Check React Builds (2 minutes)**

```bash
cd server/web
npm run build
```

**Should output**:
```
✓ build 221 files
✓ compiled successfully
```

**If it fails**: Fix the error shown, then continue.

### **Step 2: Verify Render Settings (2 minutes)**

1. Go to Render Dashboard
2. Click `attendance-hunters-main`
3. Click **Settings**
4. Check **Docker** section:
   - Dockerfile: `server/web/Dockerfile` ✓
   - Docker context: `/` ✓
5. Click **Save** if changed

### **Step 3: Redeploy (1 minute)**

**Option A - Auto deploy**:
```bash
git add -A
git commit -m "Fix: React frontend serving"
git push origin main
```

**Option B - Manual deploy**:
- Render Dashboard → Click **Manual Deploy**
- Wait 5 minutes

## ✅ Verify It Works

When build completes, test:

```bash
# Should return JSON
curl https://your-app.onrender.com/api/health

# Should return HTML (not error)
curl https://your-app.onrender.com/admin
curl https://your-app.onrender.com/login
```

**Success** ✅ when:
- `/api/health` returns JSON
- `/login` returns HTML
- `/admin` returns HTML

---

## 🆘 Still Not Working?

Go to: [FIX_CANNOT_GET_LOGIN_ADMIN.md](FIX_CANNOT_GET_LOGIN_ADMIN.md) for detailed troubleshooting.
