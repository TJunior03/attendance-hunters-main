const express = require("express");
const app = express();

const testRoutes = require("./routes/test.routes");
const usersRoutes = require("./routes/users.routes");

const path = require('path');
const fs = require('fs');

app.use(express.json());

// Serve React build if available
const webBuildPath = path.join(__dirname, '../web/build');
if (fs.existsSync(webBuildPath)) {
  app.use(express.static(webBuildPath));

  // Serve index.html for root and client-side routes
  app.get('/', (req, res) => {
    res.sendFile(path.join(webBuildPath, 'index.html'));
  });

  app.get('*', (req, res, next) => {
    // Let API routes be handled by Express; otherwise serve index.html
    if (req.path.startsWith('/api')) return next();
    res.sendFile(path.join(webBuildPath, 'index.html'));
  });
} else {
  // Fallback landing page when no build exists
  app.get('/', (req, res) => {
    res.send('<h1>Attendance API</h1><p>Use <a href="/api">/api</a> for endpoints.</p>');
  });
}

app.use("/api", testRoutes);
app.use("/api/users", usersRoutes);

// JSON 404 handler for unmatched API routes
app.use((req, res) => {
  res.status(404).json({ error: "Not Found" });
});
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
