const express = require("express");
const app = express();

const testRoutes = require("./routes/test.routes");
const usersRoutes = require("./routes/users.routes");

app.use(express.json());
app.use("/api", testRoutes);
app.use("/api/users", usersRoutes);

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
