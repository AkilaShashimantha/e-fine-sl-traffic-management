const express = require('express');
const router = express.Router();
const { generateHash } = require('../controllers/paymentController');

// URL: /api/payment/hash
router.post('/hash', generateHash);

module.exports = router;
