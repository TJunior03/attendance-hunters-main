const express = require("express");
const cors = require("cors");
const path = require("path");
const fs = require("fs");

const testRoutes = require("./routes/test.routes");
const usersRoutes = require("./routes/users.routes");

const app = express();

/* ======================
   MIDDLEWARE
====================== */
app.use(cors({
  origin: "*", // allow frontend from anywhere (safe for now)
  methods: ["GET", "POST", "PUT", "DELETE"],
  credentials: true
}));

app.use(express.json());

/* ======================
   API ROUTES
====================== */
app.use("/api", testRoutes);
app.use("/api/users", usersRoutes);

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

app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
