const Driver = require('../models/driverModel');
const Offense = require('../models/offenseModel');
const { HTTP, DEMERIT, LICENSE_STATUS } = require('../config/constants');

/**
 * Calculates the demerit level tag based on current points.
 * @param {number} points - Current demerit points (0–100)
 * @returns {string} GOOD | WARNING | DANGER | SUSPENDED
 */
function calculateLevel(points) {
  if (points <= DEMERIT.SUSPENSION_THRESHOLD) return LICENSE_STATUS.SUSPENDED;
  if (points <= 39) return 'DANGER';
  if (points <= 69) return 'WARNING';
  return 'GOOD';
}

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

  // Update the level tag
  driver.demeritLevel = calculateLevel(driver.demeritPoints);

  // Check for suspension threshold
  if (driver.demeritPoints <= DEMERIT.SUSPENSION_THRESHOLD && driver.licenseStatus !== LICENSE_STATUS.SUSPENDED) {
    driver.licenseStatus = LICENSE_STATUS.SUSPENDED;
    driver.suspendedAt = new Date();
  }

  await driver.save();

  return {
    remainingPoints: driver.demeritPoints,
    status: driver.licenseStatus,
    demeritLevel: driver.demeritLevel,
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
      .select('demeritPoints licenseStatus demeritLevel suspendedAt');

    if (!driver) {
      return res.status(HTTP.NOT_FOUND).json({ message: 'Driver not found' });
    }

    res.json({
      demeritPoints: driver.demeritPoints,
      licenseStatus: driver.licenseStatus,
      demeritLevel: driver.demeritLevel,
      suspendedAt: driver.suspendedAt,
    });
  } catch (err) {
    res.status(HTTP.SERVER_ERROR).json({ message: err.message });
  }
};
