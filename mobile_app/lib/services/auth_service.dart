import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'api_logger.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_constants.dart';
import 'secure_storage_service.dart';

class AuthService {
  // Emulator: 10.0.2.2 | Real Device: Your PC IP Address
  final String baseUrl = ApiConstants.baseUrl; 
  final _storage = const FlutterSecureStorage();

  // -------------------------
  // COMMON HELPER FUNCTIONS
  // -------------------------

  // Get Token
  Future<String?> getToken() async {
    return await _storage.read(key: PrefKeys.authToken);
  }

  // Logout
  Future<void> logout() async {
    debugPrint('[AuthService] logout() called.');
    await SecureStorageService().clearAllAuth();
    debugPrint('[AuthService] All session data cleared via SecureStorageService.');
  }

  // Login (Common for Police & Driver)
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storage.write(key: PrefKeys.authToken, value: data['token']);
      await _storage.write(key: PrefKeys.userName, value: data['name']);
      // For drivers, save license number
      if (data['role'] == UserRoles.driver && data['licenseNumber'] != null) {
        await _storage.write(key: PrefKeys.licenseNum, value: data['licenseNumber']);
      }
      // Save user role and data if needed
      return data;
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Login Failed');
    }
  }

  // Get Current User Profile (Driver/Police)
  // This fixes 'getUserProfile' error
  Future<Map<String, dynamic>> getUserProfile() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  // -------------------------
  // PASSWORD RESET FUNCTIONS
  // -------------------------

  // 1. Forgot Password Request
  Future<void> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Failed to send OTP');
    }
  }

  // 2. Verify Reset OTP
  Future<void> verifyResetOTP(String email, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-reset-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );

    if (response.statusCode != 200) {
      throw Exception('Invalid OTP');
    }
  }

  // 3. Reset Password
  Future<void> resetPassword(String email, String newPassword, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'newPassword': newPassword,
        'otp': otp
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to reset password');
    }
  }

  // -------------------------
  // POLICE FUNCTIONS
  // -------------------------

  Future<void> requestVerification(String badgeNumber, String stationCode) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/request-verification'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'badgeNumber': badgeNumber,
        'stationCode': stationCode,
      }),
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Failed to request OTP');
    }
  }

  Future<void> verifyOTP(String badgeNumber, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'badgeNumber': badgeNumber,
        'otp': otp,
      }),
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Invalid OTP');
    }
  }

  Future<List<Map<String, dynamic>>> getStations() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/stations')); 
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => {
          'name': e['name'],
          'code': e['stationCode'] ?? e['_id']
        }).toList();
      } else {
        return [
          {'name': 'Colombo Fort', 'code': 'COL-01'},
          {'name': 'Maradana', 'code': 'COL-02'},
        ];
      }
    } catch (e) {
       return [
          {'name': 'Colombo Fort', 'code': 'COL-01'},
          {'name': 'Maradana', 'code': 'COL-02'},
        ];
    }
  }

  Future<void> registerPolice(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register-police'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Registration Failed');
    }
  }

  // -------------------------
  // DRIVER FUNCTIONS
  // -------------------------

  Future<void> registerDriver(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register-driver'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      if (!(response.headers['content-type']?.contains('application/json') ?? false)) {
        throw Exception('Server Error: Invalid response format (${response.statusCode})');
      }
      try {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Driver Registration Failed');
      } on FormatException {
         throw Exception('Server Error: Invalid JSON response (${response.statusCode})');
      }
    }
  }

  // Driver License Verification (Fixes 'verifyDriverLicense' error)
  Future<void> verifyDriverLicense(Map<String, dynamic> data) async {
    final token = await getToken();
    // Assuming backend endpoint is /verify-driver based on previous code
    final response = await http.put(
      Uri.parse('$baseUrl/auth/verify-driver'), 
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      if (!(response.headers['content-type']?.contains('application/json') ?? false)) {
        throw Exception('Server Error: Invalid response format (${response.statusCode})');
      }
      try {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Verification Failed');
      } on FormatException {
         throw Exception('Server Error: Invalid JSON response (${response.statusCode})');
      }
    }
  }

  // -------------------------
  // COMMON UPDATE FUNCTIONS
  // -------------------------

  Future<void> updateProfileImage(String userId, String base64Image) async {
    final token = await getToken();
    
    final response = await http.put(
      Uri.parse('$baseUrl/auth/update-profile-image'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'id': userId,
        'profileImage': base64Image,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update image: ${response.body}');
    }
  }

  // Update Driver Profile Address
  Future<Map<String, dynamic>> updateProfile(Map<String, String> data) async {
    final token = await getToken();
    
    final response = await http.put(
      Uri.parse('$baseUrl/auth/update-profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Failed to update profile');
    }
  }
}