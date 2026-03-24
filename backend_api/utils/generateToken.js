const jwt = require('jsonwebtoken');
const { AUTH } = require('../config/constants');

const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET || 'secret123', {
    expiresIn: AUTH.JWT_EXPIRY,
  });
};

module.exports = generateToken;