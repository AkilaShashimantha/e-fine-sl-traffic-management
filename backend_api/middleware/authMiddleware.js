const jwt = require('jsonwebtoken');
const Driver = require('../models/driverModel');
const Police = require('../models/policeModel');
const { AUTH, HTTP } = require('../config/constants');

const protect = async (req, res, next) => {
  let token;

  //check is there token in header
  if (req.headers.authorization && req.headers.authorization.startsWith(AUTH.TOKEN_PREFIX)) {
    try {
      // "Bearer <token>" 
      // break and take 
      token = req.headers.authorization.split(' ')[1];
      
      console.log(`[AUTH/PROTECT] Validating token for URL: ${req.originalUrl}`);

      // 2.  Verify the token
      const decoded = jwt.verify(token, process.env.JWT_SECRET);

    
     // find the user by id in token 
   
      //first check if user is drver or not
      let user = await Driver.findById(decoded.id).select('-password');
      
      // if not driver then check if police
      if (!user) {
        user = await Police.findById(decoded.id).select('-password');
      }

      console.log(`[AUTH/PROTECT] Token resolved to user type: ${!user ? 'NONE' : (user.badgeNumber ? 'Police' : 'Driver')}`);

      req.user = user;
      next(); 

    } catch (error) {
      console.error('[AUTH/PROTECT] Token verification failed:', {
        message: error.message,
        url: req.originalUrl
      });
      res.status(HTTP.UNAUTHORIZED).json({ message: 'Not authorized, token failed' });
    }
  }

  if (!token) {
    console.warn(`[AUTH/PROTECT] No token provided for URL: ${req.originalUrl}`);
    res.status(HTTP.UNAUTHORIZED).json({ message: 'Not authorized, no token' });
  }
};

module.exports = { protect };