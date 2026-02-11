const mongoose = require('mongoose');

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
            enum: ['super_admin', 'admin_officer', 'finance_officer'],
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
