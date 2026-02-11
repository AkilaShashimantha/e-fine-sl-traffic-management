const jwt = require('jsonwebtoken');
const Admin = require('../models/adminModel');

// Protect admin routes - verify JWT and ensure user is an admin
const protectAdmin = async (req, res, next) => {
    let token;

    // Check if token exists in authorization header
    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
        try {
            // Extract token from "Bearer <token>"
            token = req.headers.authorization.split(' ')[1];

            // Verify the token
            const decoded = jwt.verify(token, process.env.JWT_SECRET);

            // Find admin user by ID from token (exclude password)
            const admin = await Admin.findById(decoded.id).select('-password');

            if (!admin) {
                return res.status(401).json({ message: 'Not authorized, admin not found' });
            }

            if (!admin.isActive) {
                return res.status(403).json({ message: 'Account is deactivated' });
            }

            // Attach admin to request object
            req.user = admin;
            next();

        } catch (error) {
            console.error(error);
            res.status(401).json({ message: 'Not authorized, invalid token' });
        }
    }

    if (!token) {
        res.status(401).json({ message: 'Not authorized, no token provided' });
    }
};

// Check if user has required role(s)
const requireRole = (...roles) => {
    return (req, res, next) => {
        if (!req.user) {
            return res.status(401).json({ message: 'Not authorized' });
        }

        if (!roles.includes(req.user.role)) {
            return res.status(403).json({
                message: 'Access denied - insufficient permissions',
                requiredRole: roles,
                userRole: req.user.role
            });
        }

        next();
    };
};

module.exports = { protectAdmin, requireRole };
