import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../config/app_constants.dart';

class PaymentHistoryCard extends StatelessWidget {
  final Map<String, dynamic> fine;

  const PaymentHistoryCard({super.key, required this.fine});

  // ── Date helpers ───────────────────────────────────────────────
  String _fmtDate(String raw) =>
      DateFormat('yyyy-MM-dd').format(DateTime.parse(raw));
  String _fmtTime(String raw) =>
      DateFormat('hh:mm a').format(DateTime.parse(raw));

  // ── Chip builder ───────────────────────────────────────────────
  Widget _infoChip({
    required IconData icon,
    required String label,
    required String value,
    Widget? trailing,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: AppTextSize.bodySmall,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 2),
                  trailing,
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: AppTextSize.bodyMedium,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ── Section label ──────────────────────────────────────────────
  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Text(
          text,
          style: TextStyle(
            fontSize: AppTextSize.caption,
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      );

  // ── Ref ID dialog ──────────────────────────────────────────────
  void _showRefIdDialog(BuildContext context, String fullId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.large)),
        title: const Text('Payment Reference ID'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This is the unique transaction ID for your payment.'),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              width: double.infinity,
              child: SelectableText(
                fullId,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppTextSize.bodyLarge,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: fullId));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to Clipboard')),
              );
              Navigator.pop(ctx);
            },
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ── Parsed data ──────────────────────────────────────────────
    final String paidDateStr =
        fine['paidAt'] ?? fine['updatedAt'] ?? DateTime.now().toIso8601String();
    final String issuedDateStr =
        fine['date'] ?? DateTime.now().toIso8601String();

    final String paidDate = _fmtDate(paidDateStr);
    final String paidTime = _fmtTime(paidDateStr);
    final String issuedDate = _fmtDate(issuedDateStr);
    final String issuedTime = _fmtTime(issuedDateStr);

    final String offenseName = fine['offenseName'] ?? 'Traffic Fine';
    final String amount = fine['amount']?.toString() ?? '0';
    final String fineId = fine['_id']?.toString() ?? '';
    final String shortId =
        fineId.length > 8 ? '...${fineId.substring(fineId.length - 8)}' : fineId;
    final String location = fine['place'] ?? '-';
    final String shortLocation =
        location.length > 10 ? '${location.substring(0, 10)}…' : location;

    final String pid = (fine['paymentId'] ?? 'Manual').toString();
    final String displayPid =
        pid.length > 8 ? '...${pid.substring(pid.length - 8)}' : pid;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── TOP ACCENT BAR ───────────────────────────────────
          Container(
            height: 4,
            color: AppColors.primaryGreen,
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── CARD HEADER ─────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Green circle check icon
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.successGreen.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: AppColors.successGreen,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // Offense name + fine ID
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offenseName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: AppTextSize.bodyLarge,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (shortId.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'ID: $shortId',
                              style: TextStyle(
                                fontSize: AppTextSize.bodySmall,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // Amount + PAID badge
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'LKR $amount',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: AppTextSize.heading3,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.successGreen,
                            borderRadius:
                                BorderRadius.circular(AppRadius.circle),
                          ),
                          child: const Text(
                            'PAID',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: AppTextSize.caption,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: AppSpacing.md),

                // ── SECTION A: ISSUED DETAILS ────────────────────
                _sectionLabel('📋  Issued Details'),
                Row(
                  children: [
                    _infoChip(
                      icon: Icons.calendar_today,
                      label: 'Date',
                      value: issuedDate,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _infoChip(
                      icon: Icons.access_time,
                      label: 'Time',
                      value: issuedTime,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _infoChip(
                      icon: Icons.location_on,
                      label: 'Location',
                      value: shortLocation,
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // ── SECTION B: PAYMENT DETAILS ───────────────────
                _sectionLabel('💳  Payment Details'),
                Row(
                  children: [
                    _infoChip(
                      icon: Icons.event_available,
                      label: 'Paid Date',
                      value: paidDate,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _infoChip(
                      icon: Icons.schedule,
                      label: 'Paid Time',
                      value: paidTime,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _infoChip(
                      icon: Icons.receipt,
                      label: 'Ref ID',
                      value: displayPid,
                      trailing: GestureDetector(
                        onTap: () => _showRefIdDialog(context, pid),
                        child: const Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
