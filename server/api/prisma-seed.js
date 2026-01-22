require("dotenv").config(); // ⭐ ADD THIS AT THE TOP

const bcrypt = require("bcrypt");
const prisma = require("./db");

async function main() {
  console.log("🌱 Seeding database...");

  // Generate hashed password (for "123456")
  const hashedPassword = await bcrypt.hash("123456", 10);

  // --- Create Admin ---
  const adminUser = await prisma.user.create({
    data: {
      email: "admin@example.com",
      password: hashedPassword,
      name: "System Admin",
      role: "admin",
      status: "active",
      admin: {
        create: {
          adminLevel: "system",
        },
      },
    },
  });

  console.log("✅ Admin created:", adminUser.email);

  // --- Create Staff ---
  const staffUser = await prisma.user.create({
    data: {
      email: "staff@example.com",
      password: hashedPassword,
      name: "John Staff",
      role: "staff",
      status: "active",
      staff: {
        create: {
          employeeId: "EMP001",
          department: "Engineering",
          position: "Lecturer",
        },
      },
    },
  });

  console.log("✅ Staff created:", staffUser.email);

  // --- Create Students ---
  const studentEmails = [
    "student1@example.com",
    "student2@example.com",
    "student3@example.com",
    "student4@example.com",
    "student5@example.com",
  ];

  for (let i = 0; i < studentEmails.length; i++) {
    const studentUser = await prisma.user.create({
      data: {
        email: studentEmails[i],
        password: hashedPassword,
        name: `Student ${i + 1}`,
        role: "student",
        status: "active",
        student: {
          create: {
            studentId: `STU00${i + 1}`,
            class: "A",
            section: "CS",
            year: "2025",
          },
        },
      },
    });

    console.log(`✅ Student created: ${studentUser.email}`);
  }

  console.log("🌿 All data seeded successfully!");
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
