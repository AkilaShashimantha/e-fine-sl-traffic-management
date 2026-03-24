const Driver = require('../models/driverModel');
const Offense = require('../models/offenseModel');

/**
 * Deducts demerit points after a fine is issued.
 * @param {string} licenseNumber - License Number of the driver
 * @param {string} offenseId - MongoDB ObjectId of the offense
 */
exports.applyDemeritPoints = async (licenseNumber, offenseId) => {
  const [offense, driver] = await Promise.all([
    Offense.findById(offenseId),
    Driver.findOne({ licenseNumber }),
  ]);

  if (!offense) throw new Error(`Offense not found: ${offenseId}`);
  if (!driver) throw new Error(`Driver not found with license: ${licenseNumber}`);

  // Deduct points — floor at 0
  driver.demeritPoints = Math.max(0, driver.demeritPoints - offense.demeritValue);

  // Check for suspension threshold
  if (driver.demeritPoints <= 0 && driver.licenseStatus !== 'SUSPENDED') {
    driver.licenseStatus = 'SUSPENDED';
    driver.suspendedAt = new Date();
  }

  await driver.save();

  return {
    remainingPoints: driver.demeritPoints,
    status: driver.licenseStatus,
    deducted: offense.demeritValue,
  };
};

/**
 * GET /api/drivers/:licenseNumber/status
 * Returns the demerit status of a driver.
 */
exports.getDriverStatus = async (req, res) => {
  try {
    const driver = await Driver.findOne({ licenseNumber: req.params.licenseNumber })
      .select('demeritPoints licenseStatus suspendedAt');

    if (!driver) {
      return res.status(404).json({ message: 'Driver not found' });
    }

    res.json({
      demeritPoints: driver.demeritPoints,
      licenseStatus: driver.licenseStatus,
      suspendedAt: driver.suspendedAt,
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
