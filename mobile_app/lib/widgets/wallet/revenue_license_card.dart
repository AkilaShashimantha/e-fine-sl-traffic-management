// lib/widgets/wallet/revenue_license_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/app_constants.dart';
import '../../models/wallet_model.dart';

class RevenueLicenseCard extends StatelessWidget {
  final RevenueLicenseModel? revenueLicense;
  final String registrationNo;

  const RevenueLicenseCard({
    super.key,
    required this.revenueLicense,
    required this.registrationNo,
  });

  String _fmt(String? iso) {
    if (iso == null) return '-';
    try {
      return DateFormat('dd-MMM-yyyy').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (revenueLicense == null) {
      return Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.large)),
        elevation: 1,
        child: const Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Icon(Icons.document_scanner_outlined,
                  color: AppColors.textSecondary),
              SizedBox(width: AppSpacing.sm),
              Text('No revenue license data available',
                  style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    final rl = revenueLicense!;
    const headerGradient = LinearGradient(
      colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
        side: BorderSide(
          color: rl.isExpired
              ? AppColors.errorRed.withAlpha(60)
              : AppColors.divider,
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Government-style header ──────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(gradient: headerGradient),
            padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.md, horizontal: AppSpacing.md),
            child: Stack(
              children: [
                // Subtle decorative circle
                Positioned(
                  right: -15,
                  top: -15,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(15),
                    ),
                  ),
                ),
                Column(
                  children: [
                    // Crest simulation
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withAlpha(180), width: 2),
                        color: Colors.white.withAlpha(20),
                      ),
                      child: const Center(
                        child: Text('SL',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text('REVENUE LICENSE',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 2)),
                    const SizedBox(height: 2),
                    Text(
                      rl.issuingAuthority ?? 'Provincial Revenue Authority',
                      style: TextStyle(
                          color: Colors.white.withAlpha(180), fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── License number ───────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              rl.licenseNo ?? '-',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                letterSpacing: 3,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Divider(height: 1),

          // ── Info grid ────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: _GridCell('Issue Date', _fmt(rl.issueDate)),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: _GridCell('Expiry Date', _fmt(rl.expiryDate),
                      valueColor: rl.isExpired
                          ? AppColors.errorRed
                          : AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: _GridCell(
                    'Issuing Authority',
                    rl.issuingAuthority ?? '-',
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: _GridCell(
                    'Annual Fee',
                    rl.annualFee != null
                        ? 'LKR ${rl.annualFee!.toStringAsFixed(0)}'
                        : '-',
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // ── Status banner ────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: rl.isExpired
                ? AppColors.errorRed
                : AppColors.successGreen,
            child: Text(
              rl.isExpired ? '✗ LICENSE EXPIRED' : '✓ LICENSE VALID',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1),
              textAlign: TextAlign.center,
            ),
          ),

          // ── Renewal notice ───────────────────────────
          if (!rl.isExpired && rl.daysUntilExpiry <= 30)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: AppColors.warningBg,
              child: Text(
                '⚠  Renewal due in ${rl.daysUntilExpiry} day(s)',
                style: const TextStyle(
                    color: AppColors.warningOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

class _GridCell extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _GridCell(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary),
            textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: valueColor ?? AppColors.textPrimary),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
