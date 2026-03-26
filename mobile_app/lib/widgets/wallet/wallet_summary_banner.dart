// lib/widgets/wallet/wallet_summary_banner.dart
import 'package:flutter/material.dart';
import '../../config/app_constants.dart';
import '../../models/wallet_model.dart';

class WalletSummaryBanner extends StatelessWidget {
  final WalletSummaryModel summary;
  const WalletSummaryBanner({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return switch (summary.overallStatus) {
      'ALL_VALID'   => _buildBanner(
          color: AppColors.successGreen,
          bgColor: AppColors.successBg,
          icon: Icons.verified_rounded,
          title: 'All documents are valid',
          subtitle: '${summary.totalVehicles} vehicle(s) · ${summary.validDocuments} documents up to date',
          chips: [],
        ),
      'HAS_EXPIRED' => _buildBanner(
          color: AppColors.errorRed,
          bgColor: AppColors.errorBg,
          icon: Icons.cancel_rounded,
          title: 'You have expired documents',
          subtitle: '${summary.expiredDocuments} document(s) need immediate renewal',
          chips: [
            _chip('${summary.expiredDocuments} Expired', AppColors.errorRed),
            if (summary.documentsNeedingRenewal > 0)
              _chip('${summary.documentsNeedingRenewal} Expiring Soon', AppColors.warningOrange),
            _chip('${summary.validDocuments} Valid', AppColors.successGreen),
          ],
        ),
      _ => _buildBanner(
          color: AppColors.warningOrange,
          bgColor: AppColors.warningBg,
          icon: Icons.warning_amber_rounded,
          title: 'Attention Required',
          subtitle: summary.documentsNeedingRenewal > 0
              ? '${summary.documentsNeedingRenewal} document(s) expiring within 30 days'
              : 'Check your vehicle documents',
          chips: [
            if (summary.documentsNeedingRenewal > 0)
              _chip('${summary.documentsNeedingRenewal} Expiring Soon', AppColors.warningOrange),
          ],
        ),
    };
  }

  Widget _buildBanner({
    required Color color,
    required Color bgColor,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> chips,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: color)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(spacing: 8, children: chips),
          ],
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.bold)),
    );
  }
}
