const mongoose = require('mongoose');

const policeSchema = mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Please add a name'],
    },
    badgeNumber: {
      type: String,
      required: [true, 'Please add a badge number'],
      unique: true, // එක් අයෙකුට එක් අංකයයි
    },
    email: {
      type: String,
      required: [true, 'Please add an email'],
      unique: true,
    },
    password: {
      type: String,
      required: [true, 'Please add a password'],
    },
    station: {
      type: String, // උදා: GAL-HQ
      required: true,
    },
    role: {
      type: String,
      enum: ['officer', 'admin'], // නිලධාරියාද නැත්නම් ඇඩ්මින්ද
      default: 'officer',
    },
  },
  {
    timestamps: true, // CreatedAt, UpdatedAt වෙලාවල් ඔටෝ වැටෙනවා
  }
);

module.exports = mongoose.model('Police', policeSchema);