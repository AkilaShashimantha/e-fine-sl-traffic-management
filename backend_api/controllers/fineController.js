const Offense = require('../models/offenseModel');
const IssuedFine = require('../models/issuedFineModel');

// @desc    Get all fine types / offenses
// @route   GET /api/fines/offenses
const getOffenses = async (req, res) => {
  try {
    const offenses = await Offense.find({}).sort({ offenseName: 1 });
    res.status(200).json(offenses);
  } catch (error) {
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};

// @desc    Add a new offense (For Admin Testing)
// @route   POST /api/fines/add
const addOffense = async (req, res) => {
  const { offenseName, amount, description } = req.body;
  try {
    const offense = await Offense.create({ offenseName, amount, description });
    res.status(201).json(offense);
  } catch (error) {
    res.status(500).json({ message: 'Failed to add offense', error: error.message });
  }
};

// @desc    Issue a new fine (Save to Database)
// @route   POST /api/fines/issue
const issueFine = async (req, res) => {
  const { licenseNumber, vehicleNumber, offenseId, offenseName, amount, place, policeOfficerId, date } = req.body;

  if (!licenseNumber || !vehicleNumber || !offenseId || !place || !policeOfficerId) {
    return res.status(400).json({ message: 'All fields are required' });
  }

  try {
    const fine = await IssuedFine.create({
      licenseNumber,
      vehicleNumber,
      offenseId,
      offenseName,
      amount,
      place,
      policeOfficerId,
      date: date || Date.now() // Use provided date or default to now
    });

    res.status(201).json(fine);
  } catch (error) {
    console.error("Error issuing fine:", error);
    res.status(500).json({ message: 'Failed to issue fine', error: error.message });
  }
};

// @desc    Get Fine History (Filter by Officer ID)
// @route   GET /api/fines/history
const getFineHistory = async (req, res) => {
  try {
    const { policeOfficerId } = req.query;

    const query = policeOfficerId ? { policeOfficerId: policeOfficerId } : {};

    const history = await IssuedFine.find(query).sort({ createdAt: -1 });

    res.status(200).json(history);
  } catch (error) {
    res.status(500).json({ message: 'Failed to get history', error: error.message });
  }
};

// @desc    Get Pending Fines for a Driver
// @route   GET /api/fines/pending
const getDriverPendingFines = async (req, res) => {
  try {
    const { licenseNumber } = req.query;

    if (!licenseNumber) {
      return res.status(400).json({ message: 'License number is required' });
    }

    const fines = await IssuedFine.find({
      licenseNumber: licenseNumber,
      status: { $in: ['Unpaid', 'Pending'] }
    }).sort({ createdAt: -1 });

    res.status(200).json(fines);
  } catch (error) {
    res.status(500).json({ message: 'Failed to fetch pending fines', error: error.message });
  }
};

// @desc    Mark fine as Paid (After PayHere Success)
// @route   POST /api/fines/:id/pay
const payFine = async (req, res) => {
  try {
    const { id } = req.params;
    const { paymentId } = req.body;

    const fine = await IssuedFine.findById(id);

    if (!fine) {
      return res.status(404).json({ message: 'Fine not found' });
    }

    if (fine.status === 'Paid') {
      return res.status(400).json({ message: 'Fine is already paid' });
    }

    fine.status = 'Paid';
    fine.paymentId = paymentId;
    fine.paidAt = Date.now();

    await fine.save();

    res.status(200).json({ message: 'Fine paid successfully', fine });
  } catch (error) {
    res.status(500).json({ message: 'Failed to update payment', error: error.message });
  }
};

// @desc    Get Paid Fine History for a Driver
// @route   GET /api/fines/driver-history
const getDriverPaidHistory = async (req, res) => {
  try {
    const { licenseNumber } = req.query;

    if (!licenseNumber) {
      return res.status(400).json({ message: 'License number is required' });
    }

    const fines = await IssuedFine.find({
      licenseNumber: licenseNumber,
      status: 'Paid'
    }).sort({ paidAt: -1 });

    res.status(200).json(fines);
  } catch (error) {
    res.status(500).json({ message: 'Failed to fetch history', error: error.message });
  }
};

module.exports = {
  getOffenses,
  addOffense,
  issueFine,
  getFineHistory,
  getDriverPendingFines,
  payFine,
  getDriverPaidHistory
};
