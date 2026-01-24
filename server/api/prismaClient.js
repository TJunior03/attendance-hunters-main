// ✅ Load environment variables if not already loaded
if (!process.env.DATABASE_URL) {
  require("dotenv").config();
}

const { PrismaClient } = require("@prisma/client");

const prisma = new PrismaClient({
  errorFormat: 'pretty',
  log: [
    { emit: 'stdout', level: 'error' },
    { emit: 'stdout', level: 'warn' },
  ],
});

// Test database connection on startup
prisma.$connect()
  .then(() => {
    console.log('✅ Database connection successful');
  })
  .catch((error) => {
    console.error('❌ Database connection failed:');
    console.error('Error:', error.message);
    console.error('DATABASE_URL:', process.env.DATABASE_URL ? '✓ Set' : '✗ Not set');
    process.exit(1);
  });

module.exports = prisma;
