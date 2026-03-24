const Station = require('../models/stationModel');
const { HTTP } = require('../config/constants');

// @desc    Get all police stations
// @route   GET /api/stations
const getStations = async (req, res) => {
  try {
    
    const stations = await Station.find().select('name stationCode');
    res.status(HTTP.OK).json(stations);
  } catch (error) {
    res.status(HTTP.SERVER_ERROR).json({ message: 'Server Error', error: error.message });
  }
};

module.exports = { getStations };