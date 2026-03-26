// lib/screens/driver/wallet_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/app_constants.dart';
import '../../models/wallet_model.dart';
import '../../services/wallet_service.dart';
import '../../widgets/wallet/wallet_identity_card.dart';
import '../../widgets/wallet/vehicle_selector_tab.dart';
import '../../widgets/wallet/emission_cert_card.dart';
import '../../widgets/wallet/insurance_cert_card.dart';
import '../../widgets/wallet/revenue_license_card.dart';
import '../../widgets/wallet/wallet_summary_banner.dart';
import '../../widgets/wallet/wallet_skeleton_loader.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _walletService    = WalletService();
  final _nicController    = TextEditingController();
  final _licenseController = TextEditingController();
  final _formKey          = GlobalKey<FormState>();

  WalletModel? _wallet;
  bool   _isLoading = false;
  bool   _isLoaded  = false;
  String? _errorMessage;
  int    _selectedVehicleIndex = 0;

  // ── NIC Validation ─────────────────────────────────────
  static final _nicOld = RegExp(r'^[0-9]{9}[VvXx]$');
  static final _nicNew = RegExp(r'^[0-9]{12}$');

  String? _validateNic(String? val) {
    if (val == null || val.isEmpty) return 'NIC is required';
    if (!_nicOld.hasMatch(val) && !_nicNew.hasMatch(val)) {
      return 'Enter a valid Sri Lankan NIC number';
    }
    return null;
  }

  String? _validateLicense(String? val) {
    if (val == null || val.isEmpty) return 'License number is required';
    if (val.length < 6) return 'Enter a valid license number';
    return null;
  }

  // ── Load Wallet ─────────────────────────────────────────
  Future<void> _loadWallet() async {
    if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      if (!_isLoaded) _isLoading = true;
      _errorMessage = null;
    });

    try {
      final wallet = await _walletService.verifyAndLoadWallet(
        _nicController.text.trim(),
        _licenseController.text.trim(),
      );
      if (mounted) {
        setState(() {
          _wallet   = wallet;
          _isLoaded = true;
          _isLoading = false;
          _selectedVehicleIndex = 0;
        });
      }
    } on WalletException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isLoading    = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Connection failed. Check your internet.';
          _isLoading    = false;
        });
      }
    }
  }

  void _resetWallet() {
    setState(() {
      _wallet       = null;
      _isLoaded     = false;
      _isLoading    = false;
      _errorMessage = null;
      _selectedVehicleIndex = 0;
    });
  }

  void _selectVehicle(int index) {
    setState(() => _selectedVehicleIndex = index);
  }

  @override
  void dispose() {
    _nicController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const WalletSkeletonLoader();
    if (_isLoaded && _wallet != null) return _buildWalletView();
    return _buildEntryForm();
  }

  // ══════════════════════════════════════════════════════
  // ENTRY FORM
  // ══════════════════════════════════════════════════════
  Widget _buildEntryForm() {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryGreen),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5E9), Colors.white],
            stops: [0.0, 0.55],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.xl),

                // ── Icon + Title ─────────────────────────
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withAlpha(80),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.account_balance_wallet,
                      color: Colors.white, size: 44),
                ),
                const SizedBox(height: AppSpacing.md),
                const Text('Digital Wallet',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                const Text('e-Fine SL',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: AppSpacing.xl),

                // ── Form Card ────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.large),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(15),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Enter your details',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        const Text(
                            'Your wallet contains your driving documents securely',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary)),
                        const SizedBox(height: AppSpacing.lg),

                        // NIC Field
                        TextFormField(
                          controller: _nicController,
                          textCapitalization: TextCapitalization.characters,
                          maxLength: 12,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9VvXx]')),
                            UpperCaseTextFormatter(),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'National Identity Card Number',
                            hintText: 'e.g. 199012345678 or 987654321V',
                            prefixIcon: Icon(Icons.credit_card),
                            border: OutlineInputBorder(),
                            counterText: '',
                          ),
                          validator: _validateNic,
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // License Field
                        TextFormField(
                          controller: _licenseController,
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [UpperCaseTextFormatter()],
                          decoration: const InputDecoration(
                            labelText: 'Driving License Number',
                            hintText: 'e.g. B1234567',
                            prefixIcon: Icon(Icons.badge),
                            border: OutlineInputBorder(),
                          ),
                          validator: _validateLicense,
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Error message
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.errorBg,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.small),
                              border: Border.all(
                                  color:
                                      AppColors.errorRed.withAlpha(100)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: AppColors.errorRed, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(_errorMessage!,
                                      style: const TextStyle(
                                          color: AppColors.errorRed,
                                          fontSize: 13)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],

                        // Load Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _loadWallet,
                            icon: const Icon(Icons.account_balance_wallet,
                                color: Colors.white),
                            label: const Text('Load My Wallet',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.medium),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // WALLET LOADED VIEW
  // ══════════════════════════════════════════════════════
  Widget _buildWalletView() {
    final wallet  = _wallet!;
    final vehicle = wallet.vehicles.isNotEmpty
        ? wallet.vehicles[_selectedVehicleIndex]
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('My Digital Wallet',
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _resetWallet,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadWallet,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadWallet,
        color: AppColors.primaryGreen,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 1. Summary Banner
                  WalletSummaryBanner(summary: wallet.summary),
                  const SizedBox(height: AppSpacing.md),

                  // 2. Identity Card
                  WalletIdentityCard(wallet: wallet),
                  const SizedBox(height: AppSpacing.md),

                  // 3. Vehicle Selector (only if >1)
                  if (wallet.vehicles.length > 1) ...[
                    VehicleSelectorTab(
                      vehicles: wallet.vehicles,
                      selectedIndex: _selectedVehicleIndex,
                      onVehicleSelected: _selectVehicle,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // 4. Documents for selected vehicle
                  if (vehicle != null) ...[
                    EmissionCertCard(
                      emission: vehicle.documents.emission,
                      registrationNo: vehicle.registrationNo,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    InsuranceCertCard(
                      insurance: vehicle.documents.insurance,
                      registrationNo: vehicle.registrationNo,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    RevenueLicenseCard(
                      revenueLicense: vehicle.documents.revenueLicense,
                      registrationNo: vehicle.registrationNo,
                    ),
                  ],
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper: Uppercase Text Formatter ─────────────────────
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
