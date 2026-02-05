// Raw JS boot wrapper - catches module load errors that TypeScript can't
console.log('[BOOT] Starting boot.js...');
console.log('[BOOT] CWD:', process.cwd());
console.log('[BOOT] NODE_ENV:', process.env.NODE_ENV);
console.log('[BOOT] PORT:', process.env.PORT);

const fs = require('fs');
const path = require('path');

// Check if dist/index.js exists
const indexPath = path.join(__dirname, 'index.js');
console.log('[BOOT] Looking for:', indexPath);
console.log('[BOOT] Exists:', fs.existsSync(indexPath));

try {
  require('./index.js');
} catch (err) {
  console.error('[BOOT] FATAL: Failed to load index.js');
  console.error(err);
  process.exit(1);
}
