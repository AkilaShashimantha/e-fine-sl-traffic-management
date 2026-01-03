# E-Fine SL Driver Mobile Application

## How to Run

1. Ensure Flutter is installed: [Install Guide](https://docs.flutter.dev/get-started/install)
2. Connect a device or use an emulator.
3. Navigate to `mobile_app` directory:

   ```bash
   cd mobile_app
   flutter pub get
   flutter run
   ```

4. **Note:** Check `lib/services/fine_service.dart` and `auth_service.dart` to ensure the `baseUrl` matches your local backend IP (e.g., `http://192.168.x.x:5000/api`).

## Recent Updates & Features Implemented

### 🔔 Real-time Notification System (New!)

- **Professional Notification Drawer:** A sleek side-drawer accessed via the bell icon or by clicking the 'Pending Fine Alert'.
- **Smart Read/Unread Logic:**
  - Unread fines are highlighted with a **Red 'NEW' Badge**.
  - Opening the drawer views the fines.
  - Closing the drawer automatically marks them as 'Read' and updates the notification badge count.
  - Read status is persisted locally, so it remembers what you've seen even after restarting the app.
- **Top/Floating Snackbar:** A non-intrusive, premium-style alert appears at the top of the screen when a new fine is detected in real-time.
- **Silent Initialization:** The app intelligently checks for fines on startup without annoying popups, only alerting for *new* fines during the session.

### 🚗 Dynamic Driver Dashboard

- **Real-time Demerit Point Meter:** Visualizes current driver points and status (Excellent/Warning/Risk).
- **Pending Fine Alert:** A conditional red warning box that appears on the home screen only when there are unpaid fines.
- **Dynamic Greetings:** Welcomes the driver based on the time of day.

### 📷 Smart License Scanning (OCR)

- Integrated Google ML Kit for scanning driving licenses.
- Automatically captures Issue Date, Expiry Date, and Vehicle Classes.
- Validates scanned data against the registered user's license number.

### 🔐 Secure Authentication & Profile

- Role-based login (Driver/Police).
- Secure storage of tokens and driver license numbers.
- Detailed Profile Screen displaying personal info and vehicle classes.

### 🌍 Localization

- Full English & Sinhala support (`easy_localization`).
- One-tap language toggle in the AppBar.

### 💳 Online Fine Payment (Integrated!)

- **PayHere Integration:** Securely pay fines directly through the app using the Sandbox environment.
- **Secure Hash:** Backend-generated hash ensures transaction security.
- **Instant Status Update:** Fines are marked as 'Paid' immediately upon successful transaction.

### 📜 Payment History & Details

- **Detailed History:** Dedicated screen showing all paid fines.
- **Enhanced Data:** Displays Issued Date/Time, Paid Date/Time, and Location.
- **Ref ID Feature:** View and Copy the full Payment Reference ID (Transaction ID) with a single tap.

### 👮 New Fine Issuance (Police)

- **Date & Time Picker:** Police officers can now see the auto-filled current date/time and are prevented from accidental edits (Read-Only).

### 🔔 Notification Enhancements

- **Officer ID:** Drivers can now see the Badge ID of the officer who issued the fine directly in the notification card.
- **Formatted Timestamps:** Clear display of "Issued Date & Time".

## Upcoming Features (Roadmap)

- **📷 Vehicle Number OCR:** Scanning vehicle number plates for Police officers.
- **🎨 UI/UX Polish:** Responsive design improvements for History cards and smoother animations.
- **📨 SMS Alerts:** Integration for SMS notifications.

## Folder Structure

```
📦 lib/
 ├── screens/
 │    ├── driver/             # Driver specific screens (Home, Profile)
 │    ├── police/             # Police specific screens
 │    └── auth/               # Login & Registration
 ├── services/                # API Logic (AuthService, FineService)
 ├── widgets/                 # Reusable UI components
 └── assets/                  # Icons & Translations (en.json, si.json)
```
