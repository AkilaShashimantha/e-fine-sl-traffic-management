![e-Fine SL Logo](mobile_app/assets/icons/app_icon/app_logo.png)

# e-Fine SL Traffic Management System

This repository contains the complete source code for the e-Fine SL Traffic Management System, including the **Node.js** backend API and **Flutter** mobile application.

## Project Structure

- `backend_api/` — Node.js Express REST API for traffic management, fines, payment processing, and user authentication.
- `mobile_app/` — Flutter mobile application (Driver & Police modules).

## Current Status (Integrated)

### ✅ Mobile App (Flutter)

- **Role-Based Access:** Distinct features for Drivers and Traffic Police.
- **Online Payments:** Full integration with **PayHere** Sandbox for paying fines.
- **Real-time Notifications:** Alerts for new fines with Officer ID and timestamps.
- **Payment History:** Detailed history screen with Reference ID copy feature.
- **License Scanning:** Google ML Kit OCR for Driver License scanning.
- **Localization:** English & Sinhala support.

### ✅ Backend API (Node.js/Express)

- **Secure Authentication:** JWT-based auth with OTP verification.
- **Payment Security:** Secure MD5 hash generation for PayHere.
- **Fine Management:** Endpoints for issuing, fetching, and paying fines.
- **Database:** MongoDB (Mongoose) schema for Users, Fines, and Offenses.

## How to Run

- See individual README files in `backend_api/` and `mobile_app/` for setup instructions.

## Next Steps / Roadmap

- **📷 Vehicle Number OCR:** Implement OCR scanning for vehicle number plates (Police side).
- **📉 Demerit System:** Auto-calculation of demerit points.
- **📨 SMS Alerts:** Integration with SMS gateway for offline notifications.
- **🎨 UI Enhancements:** Continued UI/UX improvements.

---
