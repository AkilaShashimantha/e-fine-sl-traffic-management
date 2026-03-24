const express = require('express');
const router = express.Router();
const { getDriverStatus } = require('../controllers/demeritController');

// GET demerit status for a specific driver
router.get('/:licenseNumber/status', getDriverStatus);

module.exports = router;
