import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';
import '../../config/app_constants.dart';
import '../kyc_screen.dart'; // KYC face verification

class DriverSignupScreen extends StatefulWidget {
  const DriverSignupScreen({super.key});

  @override
  State<DriverSignupScreen> createState() => _DriverSignupScreenState();
}

class _DriverSignupScreenState extends State<DriverSignupScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading    = false;
  bool _kycVerified  = false; // Set to true after KYC passes
  String _issueDate = '';
  String _expiryDate = '';
  List<Map<String, String>> _vehicleClasses = [];
  String? _profileImageBase64;
  String? _licenseFrontBase64;
  String? _licenseBackBase64;

  final _nameController = TextEditingController();
  final _nicController = TextEditingController();
  final _licenseController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController(); 
  
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  // Password Visibility 
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // --- VALIDATION FUNCTIONS 

  // 1. Email Validation
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // 2. NIC Validation (Sri Lanka: 9 digits+V/X or 12 digits)
  bool _isValidNIC(String nic) {
    return RegExp(r'^([0-9]{9}[vVxX]|[0-9]{12})$').hasMatch(nic);
  }

  // 3. Phone Validation (Sri Lanka: 10 digits starting with 0)
  bool _isValidPhone(String phone) {
    return RegExp(r'^0[0-9]{9}$').hasMatch(phone);
  }

  // 4. Strong Password Validation
  // (Min 8 chars, Letters, Numbers, Special Character)
  bool _isPasswordStrong(String password) {
    if (password.length < 8) return false; 
    if (!password.contains(RegExp(r'[A-Za-z]'))) return false; 
    if (!password.contains(RegExp(r'[0-9]'))) return false; 
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false; 
    return true;
  }

 
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.errorRed),
    );
  }

  // ── Field validation (shared between KYC gate and final submit) ────────────
  bool _validateFields() {
    if (_nameController.text.isEmpty ||
        _nicController.text.isEmpty ||
        _licenseController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _addressLine1Controller.text.isEmpty ||
        _cityController.text.isEmpty ||
        _postalCodeController.text.isEmpty) {
      _showError("Please fill all fields.");
      return false;
    }
    if (!_isValidNIC(_nicController.text)) {
      _showError("Invalid NIC Number (Format: 123456789V or 199012345678)");
      return false;
    }
    if (!_isValidEmail(_emailController.text)) {
      _showError("Please enter a valid Email Address.");
      return false;
    }
    if (!_isValidPhone(_phoneController.text)) {
      _showError("Invalid Phone Number (Must be 10 digits, e.g., 0712345678)");
      return false;
    }
    if (!_isPasswordStrong(_passwordController.text)) {
      _showError("Password must include 8+ chars, numbers, letters & symbols (@#\$).");
      return false;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError("Passwords do not match!");
      return false;
    }
    return true;
  }

  // ── Phase 1: open KYC screen (called when KYC not yet done) ─────────────────
  void _openKyc() {
    if (!_validateFields()) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KycScreen(
          registeredNIC: _nicController.text,
          registeredLicenseNumber: _licenseController.text,
          onVerified: (issue, expiry, classes, profileImageBase64, frontBase64, backBase64) {
            // Called when KYC succeeds — mark verified, save dates/classes, and auto-submit
            setState(() {
              _kycVerified = true;
              _issueDate = issue;
              _expiryDate = expiry;
              _vehicleClasses = classes;
              _profileImageBase64 = profileImageBase64;
              _licenseFrontBase64 = frontBase64;
              _licenseBackBase64 = backBase64;
            });
            _registerDriver();
          },
        ),
      ),
    );
  }

  // ── Phase 2: final registration submit (called after KYC passes) ─────────────
  Future<void> _registerDriver() async {
    if (!_validateFields()) return;

    setState(() => _isLoading = true);
    try {
      await _authService.registerDriver({
        'name':          _nameController.text,
        'nic':           _nicController.text,
        'licenseNumber': _licenseController.text,
        'email':         _emailController.text,
        'phone':         _phoneController.text,
        'password':      _passwordController.text,
        'kycVerified':   _kycVerified,   // ← KYC flag saved to DB
        'isVerified':    _kycVerified,   // ← Mark as fully verified
        'licenseIssueDate': _issueDate,
        'licenseExpiryDate': _expiryDate,
        'vehicleClasses':   _vehicleClasses,
        'profileImage':     _profileImageBase64,
        'licenseFrontImage': _licenseFrontBase64,
        'licenseBackImage':  _licenseBackBase64,
        'addressLine1':     _addressLine1Controller.text.trim(),
        'addressLine2':     _addressLine2Controller.text.trim(),
        'city':             _cityController.text.trim(),
        'postalCode':       _postalCodeController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:         Text("Registration Successful! Please Login."),
            backgroundColor: AppColors.successGreen,
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver Registration"),
        backgroundColor: AppColors.primaryGreenDark, 
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.directions_car, size: 60, color: AppColors.primaryGreen),
            const SizedBox(height: 10),
            const Text(
              "Create Driver Account",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),

            // Full Name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Full Name", prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),

            // NIC
            TextField(
              controller: _nicController,
              decoration: const InputDecoration(labelText: "NIC Number", prefixIcon: Icon(Icons.credit_card), border: OutlineInputBorder(), helperText: "Ex: 901234567V or 199012345678"),
            ),
            const SizedBox(height: 15),

            // License Number
            TextField(
              controller: _licenseController,
              decoration: const InputDecoration(labelText: "Driving License Number", prefixIcon: Icon(Icons.card_membership), border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),

            // Email
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: "Email Address", prefixIcon: Icon(Icons.email), border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),

            // Phone
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Mobile Number", prefixIcon: Icon(Icons.phone), border: OutlineInputBorder(), helperText: "Ex: 0771234567"),
            ),
            const SizedBox(height: 15),

            // Password
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: const Icon(Icons.lock),
                border: const OutlineInputBorder(),
                helperText: "8+ chars, numbers, symbols (@#\$)",
                suffixIcon: IconButton(
                  icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              decoration: InputDecoration(
                labelText: "Confirm Password",
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Residential Address Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Residential Address", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _addressLine1Controller,
              decoration: const InputDecoration(labelText: "Address Line 1", prefixIcon: Icon(Icons.home), border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _addressLine2Controller,
              decoration: const InputDecoration(labelText: "Address Line 2 (Optional)", prefixIcon: Icon(Icons.home_outlined), border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(labelText: "City", prefixIcon: Icon(Icons.location_city), border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _postalCodeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Postal Code", border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── KYC verified chip (shown after KYC passes) ────────────────
            if (_kycVerified)
              Container(
                margin:  const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color:        AppColors.successBg,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  border:       Border.all(color: AppColors.successGreen),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified_user, color: AppColors.successGreen, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Identity Verified ✔',
                      style: TextStyle(
                        color:      AppColors.successGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            // ── Register / Verify & Register button ───────────────────────
            SizedBox(
              width:  double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                // If not yet KYC-verified → open KYC screen first
                // If already verified    → re-submit (edge case safety)
                onPressed: _isLoading
                    ? null
                    : (_kycVerified ? _registerDriver : _openKyc),
                icon:  const Icon(Icons.verified_user),
                label: _isLoading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        _kycVerified ? 'Complete Registration' : 'Verify Identity & Register',
                        style: const TextStyle(fontSize: 16),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreenDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}