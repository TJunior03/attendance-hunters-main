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
const publicPath = path.join(__dirname, "../public");

if (fs.existsSync(publicPath)) {
  console.log('✅ React build found, serving from:', publicPath);
  
  // Serve static files (JS, CSS, images, etc.)
  app.use(express.static(publicPath));

  // SPA fallback: ALL non-API routes return index.html
  // This allows React Router to handle client-side routing
  app.get('*', (req, res) => {
    // Make sure API routes don't get caught
    if (req.path.startsWith('/api')) {
      return res.status(404).json({ error: 'API route not found' });
    }
    // Return index.html for all other routes (SPA routing)
    res.sendFile(path.join(publicPath, 'index.html'));
  });
} else {
  console.warn('⚠️  React build not found at:', publicPath);
  
  // Fallback for development
  app.get('/', (req, res) => {
    res.json({
      status: 'ok',
      message: 'Attendance API is running',
      endpoints: {
        health: '/api/health',
        auth: '/api/auth/login',
        studentAuth: '/api/student-auth/login'
      }
    });
  });
}

/* ======================
   404 HANDLER (FINAL FALLBACK)
====================== */
app.use((req, res) => {
  res.status(404).json({ error: 'Not Found', path: req.path });
});

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
