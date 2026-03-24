const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const connectDB = require('./config/db');

dotenv.config();

connectDB();

const app = express();
const { APP } = require('./config/constants');

// Enable CORS
app.use(cors());

app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));
// ----------------------------------------------------

// Routes
app.use('/api/auth', require('./routes/authRoutes'));
app.use('/api/stations', require('./routes/stationRoutes'));
app.use('/api/fines', require('./routes/fineRoutes'));
app.use('/api/payment', require('./routes/paymentRoutes')); // New Payment Route
app.use('/api/admin', require('./routes/adminRoutes')); // Admin Routes
app.use('/api/drivers', require('./routes/driverRoutes')); // Driver Demerit Routes
app.get('/', (req, res) => {
  res.send('API is running successfully!');
});

const PORT = process.env.PORT || APP.PORT;

app.listen(PORT, () => {
  console.log(`Server running in ${APP.ENV} mode on port ${PORT}`);
});

// Start cron jobs
require('./jobs/resetDemeritPoints');