const express = require("express");
const cors = require("cors");
const path = require("path");
const fs = require("fs");

// ✅ LOAD ENVIRONMENT VARIABLES FIRST
require("dotenv").config();

// ✅ VALIDATE DATABASE_URL at startup
if (!process.env.DATABASE_URL) {
  console.error('❌ FATAL: DATABASE_URL environment variable is not set');
  console.error('Set DATABASE_URL in .env or Render environment variables');
  process.exit(1);
}

console.log('✅ Environment loaded');
console.log('✅ DATABASE_URL is set');
console.log('✅ PORT:', process.env.PORT || 3000);
console.log('✅ NODE_ENV:', process.env.NODE_ENV);

const testRoutes = require("./routes/test.routes");
const authRoutes = require("./routes/auth");
const studentAuthRoutes = require("./routes/student-auth");
const usersRoutes = require("./routes/users.routes");
const classesRoutes = require("./routes/classes");
const studentsRoutes = require("./routes/students");
const attendanceRoutes = require("./routes/attendance");
const qrRoutes = require("./routes/qr");
const departmentsRoutes = require("./routes/departments");
const reportsRoutes = require("./routes/reports");

const app = express();

/* ======================
   MIDDLEWARE
====================== */
app.use(cors({
  origin: "*",
  methods: ["GET", "POST", "PUT", "DELETE", "PATCH"],
  credentials: true,
  allowedHeaders: ["Content-Type", "Authorization"]
}));

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ limit: '10mb', extended: true }));

/* ======================
   API ROUTES (MUST COME FIRST)
====================== */
// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    environment: process.env.NODE_ENV || 'unknown',
    port: process.env.PORT || 3000,
    database: process.env.DATABASE_URL ? '✅ configured' : '❌ missing'
  });
});

app.use("/api/auth", authRoutes);
app.use("/api/student-auth", studentAuthRoutes);
app.use("/api", testRoutes);
app.use("/api/users", usersRoutes);
app.use("/api/classes", classesRoutes);
app.use("/api/students", studentsRoutes);
app.use("/api/attendance", attendanceRoutes);
app.use("/api/qr", qrRoutes);
app.use("/api/departments", departmentsRoutes);
app.use("/api/reports", reportsRoutes);

/* ======================
   SERVE REACT FRONTEND (SPA)
====================== */
// Try both possible paths: ../public (Docker) and ../web/build (local dev)
const publicPath = path.join(__dirname, "../public");
const webBuildPath = path.join(__dirname, "../web/build");

let reactBuildPath = null;
if (fs.existsSync(publicPath)) {
  reactBuildPath = publicPath;
  console.log('✅ React build found at (Docker path):', publicPath);
  console.log('📁 Contents:', fs.readdirSync(publicPath));
} else if (fs.existsSync(webBuildPath)) {
  reactBuildPath = webBuildPath;
  console.log('✅ React build found at (local dev path):', webBuildPath);
  console.log('📁 Contents:', fs.readdirSync(webBuildPath));
} else {
  console.error('❌ React build NOT found at either location:');
  console.error('   - Docker: ' + publicPath);
  console.error('   - Local:  ' + webBuildPath);
  console.error('📁 Current __dirname:', __dirname);
  console.error('📁 Parent directory contents:', fs.readdirSync(path.join(__dirname, '..')));
}

if (reactBuildPath) {
  // Serve static files (JS, CSS, images, etc.)
  app.use(express.static(reactBuildPath));
  console.log('✅ Static file serving enabled from:', reactBuildPath);
  
  // 🔴 CRITICAL: SPA FALLBACK MUST BE LAST ROUTE
  // This catches all non-API routes and serves index.html
  // React Router then handles the routing on the client side
  app.get('*', (req, res) => {
    const indexPath = path.join(reactBuildPath, 'index.html');
    console.log(`📄 SPA Fallback: Serving ${req.path} → ${indexPath}`);
    res.sendFile(indexPath);
  });
} else {
  console.error('⚠️  React build not found - Frontend will NOT be available!');
  console.error('');
  console.error('🔧 TROUBLESHOOTING:');
  console.error('   1. Check if React build succeeded in Docker build logs');
  console.error('   2. Verify "COPY --from=frontend-builder /app/web/build ./public" in Dockerfile');
  console.error('   3. Ensure "npm run build" in server/web works locally');
  console.error('');
  
  // Fallback for development (API only)
  app.get('/', (req, res) => {
    res.json({
      status: 'ok',
      message: 'Attendance API is running (React frontend not available)',
      endpoints: {
        health: '/api/health',
        auth: '/api/auth/login',
        studentAuth: '/api/student-auth/login'
      }
    });
  });
}

/* ======================
   ERROR HANDLER
====================== */
app.use((err, req, res, next) => {
  console.error('❌ Error:', err);
  res.status(500).json({ 
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'production' ? 'An error occurred' : err.message
  });
});

/* ======================
   START SERVER
====================== */
const PORT = process.env.PORT || 3000;

app.listen(PORT, "0.0.0.0", () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`✅ Frontend: http://localhost:${PORT}/`);
  console.log(`✅ API: http://localhost:${PORT}/api/health`);
});
