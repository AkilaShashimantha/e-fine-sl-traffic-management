const mongoose = require('mongoose');
const { ROLES } = require('../config/constants');

const adminSchema = mongoose.Schema(
    {
        name: {
            type: String,
            required: true
        },
        email: {
            type: String,
            required: true,
            unique: true
        },
        password: {
            type: String,
            required: true
        },
        role: {
            type: String,
            enum: [ROLES.SUPER_ADMIN, ROLES.ADMIN_OFFICER, ROLES.FINANCE_OFFICER],
            required: true
        },
        phone: {
            type: String
        },
        profileImage: {
            type: String
        },
        isActive: {
            type: Boolean,
            default: true
        },
        lastLogin: {
            type: Date
        },
        // 2FA Fields
        twoFactorSecret: {
            type: String
        },
        isTwoFactorEnabled: {
            type: Boolean,
            default: false
        },
        isTwoFactorVerified: {
            type: Boolean,
            default: false
        }
    },
    {
        timestamps: true
    }
);

module.exports = mongoose.model('Admin', adminSchema);
