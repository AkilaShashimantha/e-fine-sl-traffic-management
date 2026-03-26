// lib/services/wallet_service.dart
// Digital Wallet API service — connects to the separate mock_data_loader backend.
// This service NEVER calls backend_api.
// ─────────────────────────────────────────────────────────
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wallet_model.dart';
import '../config/app_constants.dart';

class WalletService {
  // ── Points to mock_data_loader on Render ─────────────────
  // For local testing: change ApiConstants.walletBaseUrl in app_constants.dart
  // Android emulator: 'http://10.0.2.2:5001/api/wallet'
  // iOS simulator:    'http://localhost:5001/api/wallet'
  static const String _baseUrl = ApiConstants.walletBaseUrl;


  static const Duration _timeout = Duration(seconds: 15);

  // ── POST /api/wallet/verify ───────────────────────────────
  /// Verify identity and load the full digital wallet.
  Future<WalletModel> verifyAndLoadWallet(
    String nic,
    String licenseNumber,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/verify'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'nic':           nic.trim().toUpperCase(),
              'licenseNumber': licenseNumber.trim().toUpperCase(),
            }),
          )
          .timeout(_timeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return WalletModel.fromJson(data['wallet'] as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        throw WalletException(
          'No wallet found. Check your NIC and License Number.',
          statusCode: 404,
        );
      } else {
        throw WalletException(
          data['message'] as String? ?? 'Server error. Please try again.',
          statusCode: response.statusCode,
        );
      }
    } on WalletException {
      rethrow;
    } catch (e) {
      throw WalletException('Server error. Please try again later.');
    }
  }

  // ── GET /api/wallet/vehicle/:registrationNo?nic= ──────────
  /// Get all documents for a single vehicle.
  Future<VehicleModel> getVehicleDocuments(
    String registrationNo,
    String nic,
  ) async {
    try {
      final uri = Uri.parse('$_baseUrl/vehicle/${Uri.encodeComponent(registrationNo)}')
          .replace(queryParameters: {'nic': nic.trim().toUpperCase()});

      final response = await http.get(uri).timeout(_timeout);
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return VehicleModel.fromJson(data['vehicle'] as Map<String, dynamic>);
      } else if (response.statusCode == 403) {
        throw WalletException(
          'This vehicle does not belong to your NIC.',
          statusCode: 403,
        );
      } else if (response.statusCode == 404) {
        throw WalletException(
          'Vehicle not found.',
          statusCode: 404,
        );
      } else {
        throw WalletException('Server error. Please try again later.');
      }
    } on WalletException {
      rethrow;
    } catch (e) {
      throw WalletException('Server error. Please try again later.');
    }
  }

  // ── GET /api/wallet/check/:nic ────────────────────────────
  /// Quick summary check — use for dashboard badge/alert.
  Future<WalletSummaryModel> checkValidity(String nic) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/check/${Uri.encodeComponent(nic.trim().toUpperCase())}'))
          .timeout(_timeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return WalletSummaryModel.fromJson(data['summary'] as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        throw WalletException('No wallet found for this NIC.', statusCode: 404);
      } else {
        throw WalletException('Server error. Please try again later.');
      }
    } on WalletException {
      rethrow;
    } catch (e) {
      throw WalletException('Server error. Please try again later.');
    }
  }

  // ── POST /api/wallet/refresh ──────────────────────────────
  /// Force a fresh wallet fetch (cache-busting).
  Future<WalletModel> refreshWallet(String nic, String licenseNumber) async {
    return verifyAndLoadWallet(nic, licenseNumber);
  }
}

// ─────────────────────────────────────────────────────────
// Custom exception for wallet API errors
// ─────────────────────────────────────────────────────────
class WalletException implements Exception {
  final String message;
  final int? statusCode;

  const WalletException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
