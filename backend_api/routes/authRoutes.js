const express = require('express');
const router = express.Router();
const { requestVerification, 
  verifyOTP, 
  registerPolice
} = require('../controllers/authController');

router.post('/request-verification', requestVerification);
router.post('/verify-otp', verifyOTP);      
router.post('/register-police', registerPolice);

module.exports = router;