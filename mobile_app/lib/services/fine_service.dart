import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'api_logger.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FineService {
  // Your IP address (change here if it changes)
  // static const String baseUrl = 'http://192.168.8.114:5000/api';
  static const String baseUrl = 'https://e-fine-sl-traffic-management-1.onrender.com/api';
  final _storage = const FlutterSecureStorage();

  // ----------------------------------------------------------------
  // 1. Offenses List (No changes)
  // ----------------------------------------------------------------
  Future<List<dynamic>> getOffenses() async {
    try {
      String? token = await _storage.read(key: 'token');
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/fines/offenses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load offenses');
      }
    } catch (e) {
      throw Exception('Error fetching offenses: $e');
    }
  }

  // ----------------------------------------------------------------
  // 2. Issue Fine (No changes)
  // ----------------------------------------------------------------
  Future<bool> issueFine(Map<String, dynamic> fineData) async {
    try {
      String? token = await _storage.read(key: 'token');
      if (token == null) {
        throw Exception("Token missing. Please Logout & Login.");
      }

      final response = await http.post(
        Uri.parse('$baseUrl/fines/issue'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(fineData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        final msg = jsonDecode(response.body)['message'] ?? response.body;
        throw Exception("Server Error: $msg");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ----------------------------------------------------------------
  // 3. Get History (Correct endpoint)
  // ----------------------------------------------------------------
  Future<List<Map<String, dynamic>>> getOfficerFineHistory() async {
    try {
      String? token = await _storage.read(key: 'token');
      String? badge = await _storage.read(key: 'badgeNumber'); // Officer ID

      if (token == null || badge == null) {
        throw Exception("Auth data missing. Logout and Login.");
      }

      // --- Corrected URL ---
      // The route file you sent has '/history', so this must be '/fines/history'.
      // Since the Database parameter name is 'policeOfficerId', we pass it as a Query Parameter.

      final uri = Uri.parse('$baseUrl/fines/history').replace(queryParameters: {
        'policeOfficerId': badge,
      });

      // print("Calling URL: $uri"); // Helpful for debugging

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection Error: $e');
    }
  }

  // ----------------------------------------------------------------
  // 4. Get Pending Fines (Driver)
  // ----------------------------------------------------------------
  Future<List<Map<String, dynamic>>> getDriverPendingFines() async {
     try {
      String? token = await _storage.read(key: 'token');
      // When Driver logs in, licenseNumber must be saved from AuthService.
      // Otherwise, we cannot extract it here.
      // For now, let's assume it has been saved by AuthService.
      // * Hint: Save licenseNumber inside storage during Login.
      
      // However, extracting the profile details from the user object right away is preferred.
      // We can also fetch it using getUserProfile() from AuthService.
      // But saving it purely during Login is the easiest approach.
      
      // Let's attempt to use the user profile here.
      // Final authService definition removed as it was unused.
      // The most optimal logic is to retrieve what was saved during Login.
      
      // * Correction in AuthService: Save License Number on Login
      
      // Let's assume we saved it as 'licenseNumber'
      String? licenseNumber = await _storage.read(key: 'licenseNumber'); // * Make sure to save this in AuthService login!
      
       if (token == null ) {
         return [];
       }
       
       if(licenseNumber == null) {
          // If not in storage, fetch profile
           // This is a fail-safe
           return [];
       }

      final uri = Uri.parse('$baseUrl/fines/pending').replace(queryParameters: {
        'licenseNumber': licenseNumber,
      });

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Mark Fine as Paid
  Future<bool> payFine(String fineId, String paymentId) async {
    final url = Uri.parse('$baseUrl/fines/$fineId/pay');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'paymentId': paymentId}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint("PayFine Error: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("PayFine Exception: $e");
      return false;
    }
  }

  // Get Paid History
  Future<List<Map<String, dynamic>>> getDriverPaidFines() async {
    String? licenseNumber = await _storage.read(key: 'licenseNumber'); // Correct Key
    if (licenseNumber == null) return [];

    final url = Uri.parse('$baseUrl/fines/driver-history?licenseNumber=$licenseNumber');
    try {
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("Error fetching history: $e");
      return [];
    }
  }

  // ----------------------------------------------------------------
  // 5. Get Driver Status (Demerit Points)
  // ----------------------------------------------------------------
  Future<Map<String, dynamic>> getDriverStatus() async {
    try {
      String? token = await _storage.read(key: 'token');
      String? licenseNumber = await _storage.read(key: 'licenseNumber');

      if (token == null || licenseNumber == null) {
        throw Exception("Auth data missing.");
      }

      final uri = Uri.parse('$baseUrl/drivers/$licenseNumber/status');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching driver status: $e');
    }
  }
}
