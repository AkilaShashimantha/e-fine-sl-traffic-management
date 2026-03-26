// lib/widgets/wallet/wallet_identity_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/app_constants.dart';
import '../../models/wallet_model.dart';

class WalletIdentityCard extends StatelessWidget {
  final WalletModel wallet;
  const WalletIdentityCard({super.key, required this.wallet});

  static const _kGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B5E20), Color(0xFF388E3C), Color(0xFF4CAF50)],
  );

  String _formatDate(String? iso) {
    if (iso == null) return '-';
    try {
      return DateFormat('dd-MMM-yyyy').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  String _initials(String name) {
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final owner = wallet.owner;
    final dl    = wallet.drivingLicense;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Credit-card style ID card ───────────────────
        Container(
          width: double.infinity,
          height: 210,
          decoration: BoxDecoration(
            gradient: _kGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withAlpha(100),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Faint decorative circles
              Positioned(
                top: -20,
                right: -20,
                child: _circle(120, Colors.white.withAlpha(12)),
              ),
              Positioned(
                bottom: -30,
                left: -20,
                child: _circle(100, Colors.white.withAlpha(8)),
              ),

              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TOP ROW: brand + icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('e-Fine SL',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 1)),
                            Text('Digital Wallet',
                                style: TextStyle(
                                    color: Colors.white.withAlpha(180),
                                    fontSize: 11)),
                          ],
                        ),
                        Icon(Icons.account_balance_wallet_outlined,
                            color: Colors.white.withAlpha(220), size: 32),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // MIDDLE: avatar + name + NIC + blood group
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white.withAlpha(50),
                          child: Text(_initials(owner.fullName),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20)),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(owner.fullName,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Text('NIC: ${owner.nic}',
                                  style: TextStyle(
                                      color: Colors.white.withAlpha(180),
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                        if (owner.bloodGroup != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.red[700],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(owner.bloodGroup!,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const Spacer(),

                    // BOTTOM: license strip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(40),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          // License No
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('LICENSE NO',
                                    style: TextStyle(
                                        color: Colors.white.withAlpha(160),
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1)),
                                Text(dl?.licenseNo ?? owner.licenseNumber,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        letterSpacing: 2)),
                              ],
                            ),
                          ),
                          // Valid Till
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('VALID TILL',
                                  style: TextStyle(
                                      color: Colors.white.withAlpha(160),
                                      fontSize: 9,
                                      letterSpacing: 1)),
                              Text(_formatDate(dl?.expiryDate),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            ],
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          // Status badge
                          _StatusBadge(
                              status: dl?.status ?? '',
                              large: false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Vehicle classes row ──────────────────────────
        if (dl != null && dl.vehicleClasses.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          const Text('Authorized Vehicle Classes',
              style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: dl.vehicleClasses
                .map((cls) => _ClassChip(cls))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

// ── Private Widgets ───────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  final bool large;
  const _StatusBadge({required this.status, this.large = false});

  @override
  Widget build(BuildContext context) {
    final cfg = switch (status.toUpperCase()) {
      'VALID'      => (color: Colors.green[600]!, label: '✓ VALID'),
      'SUSPENDED'  => (color: Colors.red[700]!,   label: '⊘ SUSPENDED'),
      'EXPIRED'    => (color: Colors.grey[600]!,   label: '✗ EXPIRED'),
      _            => (color: Colors.grey[500]!,   label: status),
    };

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: large ? 12 : 8, vertical: large ? 6 : 3),
      decoration: BoxDecoration(
        color: cfg.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(cfg.label,
          style: TextStyle(
              color: Colors.white,
              fontSize: large ? 12 : 10,
              fontWeight: FontWeight.bold)),
    );
  }
}

class _ClassChip extends StatelessWidget {
  final String cls;
  const _ClassChip(this.cls);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryGreen, width: 1.5),
      ),
      child: Text(cls,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen)),
    );
  }
}
