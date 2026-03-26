// lib/widgets/wallet/insurance_cert_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/app_constants.dart';
import '../../models/wallet_model.dart';

class InsuranceCertCard extends StatelessWidget {
  final InsuranceCertModel? insurance;
  final String registrationNo;

  const InsuranceCertCard({
    super.key,
    required this.insurance,
    required this.registrationNo,
  });

  // ── Gradient by cert type ─────────────────────────────
  LinearGradient _gradient(String? type) {
    return switch ((type ?? '').toUpperCase()) {
      'VIP'           => const LinearGradient(
          colors: [Color(0xFFF9A825), Color(0xFFF57F17)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      'COMPREHENSIVE' => const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      _               => const LinearGradient(
          colors: [Color(0xFF00695C), Color(0xFF004D40)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
    };
  }

  String _fmt(String? iso) {
    if (iso == null) return '-';
    try {
      return DateFormat('dd-MMM-yyyy').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  String _certTypeLabel(String? type) {
    return switch ((type ?? '').toUpperCase()) {
      'VIP'           => 'VIP Policy',
      'COMPREHENSIVE' => 'Comprehensive',
      'THIRD_PARTY'   => 'Third Party',
      _               => type ?? 'Insurance',
    };
  }

  /// Compute coverage progress 0..1
  double _coverageProgress(String? start, String? end) {
    if (start == null || end == null) return 0;
    try {
      final s = DateTime.parse(start);
      final e = DateTime.parse(end);
      final total = e.difference(s).inDays;
      if (total <= 0) return 1;
      final elapsed = DateTime.now().difference(s).inDays;
      return (elapsed / total).clamp(0.0, 1.0);
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (insurance == null) {
      return _noDataCard();
    }
    final ins = insurance!;
    final grad = _gradient(ins.certificateType);
    final progress = _coverageProgress(
        ins.periodOfCoverStart, ins.periodOfCoverEnd);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
        side: BorderSide(
          color: ins.isExpired
              ? AppColors.errorRed.withAlpha(60)
              : AppColors.divider,
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header with gradient ─────────────────────
          Container(
            decoration: BoxDecoration(gradient: grad),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Insurer logo simulation
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white.withAlpha(220),
                  child: Text(
                    (ins.insurer ?? 'I')[0].toUpperCase(),
                    style: TextStyle(
                        color: _gradientPrimaryColor(ins.certificateType),
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ins.insurer ?? 'Insurance Provider',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                          overflow: TextOverflow.ellipsis),
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(_certTypeLabel(ins.certificateType),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11)),
                      ),
                    ],
                  ),
                ),
                // Status badge
                _InsStatusBadge(status: ins.isExpired ? 'EXPIRED' : (ins.statusBadge)),
              ],
            ),
          ),

          // ── Certificate of Insurance label ───────────
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Text(
                'Certificate of Insurance',
                style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary),
              ),
            ),
          ),
          const Divider(height: 1),

          // ── Info rows ────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                _InfoRow('Vehicle No', registrationNo),
                _InfoRow('Policy No', ins.policyNo ?? '-'),
                _InfoRow('Coverage', ins.coverageType ?? '-'),
              ],
            ),
          ),
          const Divider(height: 1),

          // ── Coverage period strip ────────────────────
          _buildCoveragePeriod(ins, progress, context),

          // ── Footer ───────────────────────────────────
          Container(
            width: double.infinity,
            color: const Color(0xFFF5F5F5),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: 10),
            child: Text(
              'Coverage: ${ins.coverageType ?? "-"}  ·  This is an automated digital copy',
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoveragePeriod(
      InsuranceCertModel ins, double progress, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Period of Cover',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                  Text(_fmt(ins.periodOfCoverStart),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              const Expanded(
                child: Center(
                  child: Icon(Icons.arrow_forward,
                      size: 18, color: AppColors.textSecondary),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    ins.isExpired
                        ? 'Expired'
                        : '${ins.daysUntilExpiry} days left',
                    style: TextStyle(
                        fontSize: 11,
                        color: ins.isExpired
                            ? AppColors.errorRed
                            : AppColors.successGreen,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(_fmt(ins.periodOfCoverEnd),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: ins.isExpired
                              ? AppColors.errorRed
                              : AppColors.textPrimary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(
                ins.isExpired ? AppColors.errorRed : AppColors.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _gradientPrimaryColor(String? type) {
    return switch ((type ?? '').toUpperCase()) {
      'VIP'           => const Color(0xFFF57F17),
      'COMPREHENSIVE' => const Color(0xFF0D47A1),
      _               => const Color(0xFF004D40),
    };
  }

  Widget _noDataCard() {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large)),
      elevation: 1,
      child: const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Icon(Icons.shield_outlined, color: AppColors.textSecondary),
            SizedBox(width: AppSpacing.sm),
            Text('No insurance data available',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _InsStatusBadge extends StatelessWidget {
  final String status;
  const _InsStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final cfg = switch (status.toUpperCase()) {
      'ACTIVE'    => (bg: Colors.white, text: Colors.green[700]!, label: 'ACTIVE'),
      'EXPIRED'   => (bg: Colors.white, text: Colors.red[700]!,   label: 'EXPIRED'),
      'CANCELLED' => (bg: Colors.white, text: Colors.grey[600]!,  label: 'CANCELLED'),
      _           => (bg: Colors.white, text: Colors.grey[600]!,  label: status),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: cfg.bg, borderRadius: BorderRadius.circular(12)),
      child: Text(cfg.label,
          style: TextStyle(
              color: cfg.text,
              fontWeight: FontWeight.bold,
              fontSize: 11)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ),
          const Text(': ', style: TextStyle(color: AppColors.textSecondary)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
