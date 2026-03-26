// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wallet_model.dart';

class WalletApiService {
  // Use your actual backend URL/IP here
  static const String baseUrl = 'http://10.0.2.2:5001/api/wallet';

  /// Verifies identity and loads wallet documents
  Future<WalletModel?> verifyAndLoadWallet(String nic, String licenseNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nic': nic,
          'licenseNumber': licenseNumber,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['wallet'] != null) {
          return WalletModel.fromJson(data['wallet']);
        }
      } else if (response.statusCode == 404) {
        // No records found
        return null;
      } else {
        throw Exception('Failed to load wallet data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Server error during wallet verification: $e');
    }
    return null;
  }
}
