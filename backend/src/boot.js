// Plain JS boot wrapper to catch any module-level crashes in index.js
// TypeScript hoists imports above inline code, so we need this plain JS
// entry point to catch errors during module loading.
// Also runs prisma migrate deploy before starting the server.

const { execSync } = require('child_process');

console.log('[boot] Starting LiftIQ server...');
console.log('[boot] Node version:', process.version);
console.log('[boot] CWD:', process.cwd());

// Catch uncaught errors
process.on('uncaughtException', (err) => {
  console.error('[boot] UNCAUGHT EXCEPTION:', err);
  process.exit(1);
});

process.on('unhandledRejection', (reason) => {
  console.error('[boot] UNHANDLED REJECTION:', reason);
  process.exit(1);
});

// Run prisma migrations before starting the server
try {
  console.log('[boot] Running prisma migrate deploy...');
  execSync('npx prisma migrate deploy', { stdio: 'inherit' });
  console.log('[boot] Migrations complete');
} catch (err) {
  console.error('[boot] Migration failed:', err.message);
  // Continue anyway - migrations may already be applied
}

try {
  require('./index.js');
  console.log('[boot] index.js loaded successfully');
} catch (err) {
  console.error('[boot] FATAL: Failed to load index.js:', err);
  process.exit(1);
}
