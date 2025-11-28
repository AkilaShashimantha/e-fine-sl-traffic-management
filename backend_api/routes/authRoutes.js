const express = require('express');
const router = express.Router();
const { requestVerification } = require('../controllers/authController');

router.post('/request-verification', requestVerification);

module.exports = router;