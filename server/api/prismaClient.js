// ✅ Load environment variables FIRST (before any other code)
require("dotenv").config();

// ✅ Validate DATABASE_URL exists and is properly formatted
if (!process.env.DATABASE_URL) {
  console.error('❌ FATAL: DATABASE_URL not set in .env');
  console.error('Expected format: postgresql://user:pass@host/db?sslmode=require');
  process.exit(1);
}

// ✅ Log connection attempt (hide password)
const dbUrl = process.env.DATABASE_URL;
const safeUrl = dbUrl.replace(/:[^@]*@/, ':***@'); // Hide password
console.log('📡 Attempting Neon database connection...');
console.log('   Database URL:', safeUrl);

const { PrismaClient } = require("@prisma/client");

const prisma = new PrismaClient({
  errorFormat: 'pretty',
  log: [
    { emit: 'stdout', level: 'error' },
    { emit: 'stdout', level: 'warn' },
  ],
});

// ✅ Test connection immediately
prisma.$connect()
  .then(() => {
    console.log('✅ Prisma connected to Neon database');
  })
  .catch((error) => {
    console.error('❌ Prisma connection failed');
    console.error('Error:', error.message);
    console.error('');
    console.error('🔍 Diagnostics:');
    
    // Specific error hints
    if (error.message.includes('ECONNREFUSED')) {
      console.error('   → Database unreachable. Check host in DATABASE_URL');
      console.error('   → For Neon, use: ep-blue-firefly-a43533yo.us-east-1.aws.neon.tech (direct)');
      console.error('   → NOT: localhost:5432 (PostgreSQL local)');
    } else if (error.message.includes('ENOTFOUND')) {
      console.error('   → Host not found. Check domain in DATABASE_URL');
    } else if (error.message.includes('password authentication failed')) {
      console.error('   → Wrong username or password');
      console.error('   → Check Neon console: https://console.neon.tech');
      console.error('   → Copy "Quick connect" string and verify it has no extra quotes');
    } else if (error.message.includes('FATAL:')) {
      console.error('   → Database error. Check Neon console status');
    } else if (error.message.includes('ssl')) {
      console.error('   → SSL error. Ensure ?sslmode=require is in DATABASE_URL');
      console.error('   → Current URL:', safeUrl);
    } else if (error.message.includes('channel_binding')) {
      console.error('   → Try removing ?channel_binding=require from DATABASE_URL');
    }
    
    console.error('');
    console.error('💡 Common fixes:');
    console.error('   1. Check .env file has NO quotes: DATABASE_URL=postgresql://...');
    console.error('   2. Use direct host: ep-blue-firefly-a43533yo... (not -pooler for local)');
    console.error('   3. Include: ?sslmode=require at end of URL');
    console.error('');
    
    process.exit(1);
  });

module.exports = prisma;
