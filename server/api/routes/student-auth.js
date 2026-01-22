const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const prisma = require('../db');

const router = express.Router();

// 🧩 Student Login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    // ✅ Find the student via the related User model (since email is stored in User)
    const student = await prisma.student.findFirst({
      where: {
        user: {
          email: email, // check the user relation
        },
      },
      include: {
        user: true, // include user details like name, email, password
      },
    });

    if (!student) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // ✅ Validate password (compare with hashed password stored in user)
    const isValidPassword = await bcrypt.compare(password, student.user.password);
    if (!isValidPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // ✅ Generate JWT token
    const token = jwt.sign(
      {
        studentId: student.id,
        email: student.user.email,
        role: student.user.role,
      },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    );

    // ✅ Return student data (exclude password)
    const { password: _, ...userData } = student.user;

    res.json({
      success: true,
      token,
      student: {
        id: student.id,
        userId: student.userId,
        email: userData.email,
        name: userData.name,
        role: userData.role,
      },
    });

  } catch (error) {
    console.error('Student login error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 🧩 Get Current Student Profile
router.get('/profile', async (req, res) => {
  try {
    const token = req.headers.authorization?.replace('Bearer ', '');

    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // ✅ Include user details in the student profile
    const student = await prisma.student.findUnique({
      where: { id: decoded.studentId },
      include: { user: true },
    });

    if (!student) {
      return res.status(404).json({ error: 'Student not found' });
    }

    const { password: _, ...userData } = student.user;

    res.json({
      student: {
        id: student.id,
        email: userData.email,
        name: userData.name,
        role: userData.role,
      },
    });

  } catch (error) {
    console.error('Profile error:', error);
    res.status(401).json({ error: 'Invalid token' });
  }
});

module.exports = router;
