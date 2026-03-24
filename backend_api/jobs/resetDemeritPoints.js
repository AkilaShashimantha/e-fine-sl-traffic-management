const cron = require('node-cron');
const Driver = require('../models/driverModel');
const { DEMERIT, LICENSE_STATUS, CRON } = require('../config/constants');

/**
 * Scheduled Job: Monthly Demerit Point Reset
 * Runs at 00:00 on the 1st of every month.
 * Reinstates suspended drivers with a partial point restore (50 points).
 */
cron.schedule(CRON.MONTHLY_RESET, async () => {
  console.log('[CRON] Running monthly demerit point reset...');

  try {
    const result = await Driver.updateMany(
      { licenseStatus: LICENSE_STATUS.SUSPENDED },
      {
        $set: {
          demeritPoints: DEMERIT.MONTHLY_RESTORE,         // partial restore on reinstatement
          licenseStatus: LICENSE_STATUS.ACTIVE,
          demeritLevel:  'WARNING',  // 50 pts = Warning range (40–69)
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
