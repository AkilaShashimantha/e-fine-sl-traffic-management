const mongoose = require('mongoose');

const driverSchema = mongoose.Schema(
  {
    name: { type: String, required: true },
    nic: { type: String, required: true, unique: true },
    licenseNumber: { type: String, required: true, unique: true }, 
    email: { type: String, required: true, unique: true },
    phone: { type: String, required: true },
    password: { type: String, required: true },
    role: { type: String, default: 'driver' }, // 'driver'
    
    // (Demerit Points)
    demeritPoints: { type: Number, default: 0 }, 
    licenseStatus: { type: String, enum: ['Active', 'Suspended'], default: 'Active' },

    isVerified: { type: Boolean, default: false },
    // ...
    licenseExpiryDate: { type: Date }, 
    licenseIssueDate: { type: Date }, // 4a
    dateOfBirth: { type: Date }, // 3
    
    vehicleClasses: [{
        category: String, // A, B, B1
        issueDate: Date,
        expiryDate: Date
    }],
    // ...
  },
  { timestamps: true }
);

module.exports = mongoose.model('Driver', driverSchema);