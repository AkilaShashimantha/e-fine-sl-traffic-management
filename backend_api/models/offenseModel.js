const mongoose = require('mongoose');

const offenseSchema = mongoose.Schema(
  {
    offenseName: {
      type: String,
      required: true,
      unique: true, // Ekama waradda deparak liyawenne na
    },
    amount: {
      type: Number,
      required: true,
    },
    description: {
      type: String,
      required: false,
    },
    sectionOfAct: { // Panatha (Example: 123-A)
      type: String,
      required: false, 
    },
    demeritValue: {
      type: Number,
      required: true,
      default: 10,
      min: 1,
      max: 100,
    }
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('Offense', offenseSchema);
