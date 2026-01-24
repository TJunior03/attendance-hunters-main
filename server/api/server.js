const express = require("express");
const cors = require("cors");
const path = require("path");
const fs = require("fs");

// ✅ VALIDATE DATABASE_URL at startup
if (!process.env.DATABASE_URL) {
  console.error('❌ FATAL: DATABASE_URL environment variable is not set');
  console.error('Set DATABASE_URL in .env or Render environment variables');
  process.exit(1);
}

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
   API ROUTES
====================== */
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
   SERVE FRONTEND (OPTIONAL)
====================== */
const webBuildPath = path.join(__dirname, "../web/build");

if (fs.existsSync(webBuildPath)) {
  app.use(express.static(webBuildPath));

  app.get("/", (req, res) => {
    res.sendFile(path.join(webBuildPath, "index.html"));
  });

  app.get("*", (req, res, next) => {
    if (req.path.startsWith("/api")) return next();
    res.sendFile(path.join(webBuildPath, "index.html"));
  });
} else {
  app.get("/", (req, res) => {
    res.send("<h1>Attendance API</h1><p>API is running.</p>");
  });
}

/* ======================
   404 HANDLER
====================== */
app.use((req, res) => {
  res.status(404).json({ error: "Not Found" });
});

/* ======================
   START SERVER
====================== */
const PORT = process.env.PORT || 3000;

app.listen(PORT, "0.0.0.0", () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
