const express = require("express");
const router = express.Router();
const prisma = require("../prismaClient"); // ✅ FIXED PATH

router.get("/test-db", async (req, res) => {
  try {
    const admins = await prisma.admin.findMany();
    res.json(admins);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "DB error" });
  }
});

module.exports = router;
