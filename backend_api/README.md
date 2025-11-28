
# Backend API

- Node.js Express backend for E-Fine SL project.
- MongoDB database connection using Mongoose.
- Police registration OTP verification workflow implemented.
- Email sending via Gmail (nodemailer) for verification codes to OIC.
- API endpoint `/api/auth/request-verification`:
	- Accepts badge number and station code.
	- Validates police station.
	- Generates and stores OTP for officer registration.
	- Sends styled HTML email to station's official email with OTP and officer details.
- Environment variables required:
	- `MONGO_URI` (MongoDB connection string)
	- `EMAIL_USER` (Gmail address for nodemailer)
	- `EMAIL_PASS` (Gmail app password)
- Express server setup with JSON body parsing and basic root endpoint.
- Modular structure: controllers, models, routes, middleware, utils.

## Quick Start

1. Install dependencies:
	 ```bash
	 npm install
	 ```
2. Create a `.env` file in `backend_api/` with required variables.
3. Start the server:
	 ```bash
	 node server.js
	 ```

## Main Files Updated
- `controllers/authController.js`: OTP request and email logic
- `utils/sendEmail.js`: Nodemailer email utility
- `config/db.js`: MongoDB connection
- `server.js`: Express app setup and route registration

## API Endpoints
- `POST /api/auth/request-verification`: Request OTP for police registration

## Notes
- Ensure Gmail account allows app password for nodemailer.
- MongoDB must be running and accessible via provided URI.
