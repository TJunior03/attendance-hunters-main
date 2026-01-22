const express = require("express");
const router = express.Router();
const prisma = require("../prismaClient");

router.get("/", async (req, res) => {
  const users = await prisma.user.findMany({
    select: {
      id: true,
      name: true,
      email: true,
      role: true
    }
  });
  res.json(users);
});

module.exports = router;
