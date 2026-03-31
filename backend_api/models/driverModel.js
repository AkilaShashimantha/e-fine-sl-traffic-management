const mongoose = require('mongoose');
const { ROLES, DEMERIT, LICENSE_STATUS } = require('../config/constants');

const driverSchema = mongoose.Schema(
  {
    name: { type: String, required: true },
    nic: { type: String, required: true, unique: true },
    licenseNumber: { type: String, required: true, unique: true }, 
    email: { type: String, required: true, unique: true },
    phone: { type: String, required: true },
    password: { type: String, required: true },
    role: { type: String, default: ROLES.DRIVER }, // 'driver'
    
    // (Demerit Points)
    demeritPoints: { type: Number, default: DEMERIT.DEFAULT_POINTS }, 
    licenseStatus: { type: String, enum: [LICENSE_STATUS.ACTIVE, LICENSE_STATUS.SUSPENDED], default: LICENSE_STATUS.ACTIVE },
    demeritLevel: { type: String, enum: ['GOOD', 'WARNING', 'DANGER', LICENSE_STATUS.SUSPENDED], default: 'GOOD' },
    suspendedAt: { type: Date, default: null },

    isVerified: { type: Boolean, default: false },
    kycVerified: { type: Boolean, default: false }, // KYC face-match verification status
    profileImage: { type: String }, // Base64 profile photo extracted from KYC selfie
    licenseFrontImage: { type: String }, // Base64 license front side
    licenseBackImage: { type: String }, // Base64 license back side
    // ...
    licenseExpiryDate: { type: String }, 
    licenseIssueDate: { type: String }, // 4a
    dateOfBirth: { type: String }, // 3
    
    address: { type: String },
    city: { type: String },
    postalCode: { type: String },
    

    vehicleClasses: [{
        category: String, // A, B, B1
        issueDate: String,
        expiryDate: String
    }],
    // ...
  },
  { timestamps: true }
);

module.exports = mongoose.model('Driver', driverSchema);