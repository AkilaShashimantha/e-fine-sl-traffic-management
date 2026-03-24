const cron = require('node-cron');
const Driver = require('../models/driverModel');

/**
 * Scheduled Job: Monthly Demerit Point Reset
 * Runs at 00:00 on the 1st of every month.
 * Reinstates suspended drivers with a partial point restore (50 points).
 */
cron.schedule('0 0 1 * *', async () => {
  console.log('[CRON] Running monthly demerit point reset...');

  try {
    const result = await Driver.updateMany(
      { licenseStatus: 'SUSPENDED' },
      {
        $set: {
          demeritPoints: 50,         // partial restore on reinstatement
          licenseStatus: 'ACTIVE',
          suspendedAt:   null,
        },
      }
    );

    console.log(`[CRON] Reset complete. ${result.modifiedCount} driver(s) reinstated.`);

  } catch (err) {
    console.error('[CRON] Demerit reset failed:', err.message);
  }
});

console.log('[CRON] Monthly demerit reset job registered.');
