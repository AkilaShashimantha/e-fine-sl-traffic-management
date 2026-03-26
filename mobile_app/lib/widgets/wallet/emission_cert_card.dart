// lib/widgets/wallet/emission_cert_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/app_constants.dart';
import '../../models/wallet_model.dart';

class EmissionCertCard extends StatefulWidget {
  final EmissionCertModel? emission;
  final String registrationNo;

  const EmissionCertCard({
    super.key,
    required this.emission,
    required this.registrationNo,
  });

  @override
  State<EmissionCertCard> createState() => _EmissionCertCardState();
}

class _EmissionCertCardState extends State<EmissionCertCard> {
  bool _expanded = false;

  String _fmt(String? iso) {
    if (iso == null) return '-';
    try {
      return DateFormat('dd-MMM-yyyy').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  Color get _accentColor {
    final e = widget.emission;
    if (e == null) return Colors.grey;
    if (e.isExpired) return Colors.grey;
    if (e.overallStatus == 'FAIL') return AppColors.errorRed;
    return AppColors.successGreen;
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.emission;
    if (e == null) {
      return _noDataCard('Emission Certificate', 'No emission data available');
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
        side: BorderSide(color: _accentColor.withAlpha(60), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Left accent bar + header ─────────────────
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 6, color: _accentColor),
                Expanded(
                  child: _buildHeader(e),
                ),
              ],
            ),
          ),

          // ── Certificate title ────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _SectionTitle('VEHICLE EMISSION TEST CERTIFICATE'),
          ),

          // ── Validity strip ───────────────────────────
          _buildValidityStrip(e),
          const Divider(height: 1),

          // ── Expandable section ───────────────────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                // Vehicle info grid
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: _buildInfoGrid(e),
                ),
                const Divider(height: 1),
                // Readings table
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: _buildReadingsTable(e),
                ),
              ],
            ),
          ),

          // ── Expand toggle ────────────────────────────
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _expanded
                        ? 'Hide Details ▲'
                        : 'View Full Certificate ▼',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),

          // ── Result banner ─────────────────────────────
          _buildResultBanner(e),
        ],
      ),
    );
  }

  Widget _buildHeader(EmissionCertModel e) {
    return Container(
      color: const Color(0xFFF9F9F9),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // LAUGFS logo simulation
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
                color: AppColors.primaryGreen, shape: BoxShape.circle),
            child: const Center(
              child: Text('L',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.issuingCompany ?? 'LAUGFS ECO SRI LIMITED',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                const Text('Vehicle Emission Test',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          _LargeBadge(
            label: e.isExpired
                ? 'EXPIRED'
                : (e.overallStatus ?? '-'),
            color: _accentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildValidityStrip(EmissionCertModel e) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Stack(
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('Issued: ${_fmt(e.dateOfIssue)}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
              const Spacer(),
              const Icon(Icons.arrow_forward,
                  size: 14, color: AppColors.textSecondary),
              const Spacer(),
              const Icon(Icons.calendar_today,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('Valid Till: ${_fmt(e.validTill)}',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: e.isExpired
                          ? AppColors.errorRed
                          : AppColors.textPrimary)),
            ],
          ),
          if (e.isExpired)
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: _OverlayBadge('EXPIRED', AppColors.errorRed),
              ),
            )
          else if (!e.isExpired && e.daysUntilExpiry <= 30)
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: _OverlayBadge(
                    'Expiring in ${e.daysUntilExpiry}d',
                    AppColors.warningOrange),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(EmissionCertModel e) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _InfoChipWidget(Icons.tag, 'Serial No', e.serialNo),
        _InfoChipWidget(Icons.computer, 'System No', e.systemNo ?? '-'),
        _InfoChipWidget(
            Icons.location_on, 'Test Centre', e.testCentre ?? '-'),
        _InfoChipWidget(Icons.person, 'Inspector', e.inspector ?? '-'),
        _InfoChipWidget(Icons.receipt, 'Reference', e.referenceNo ?? '-'),
        _InfoChipWidget(Icons.attach_money, 'Test Fee',
            e.testFee != null ? 'LKR ${e.testFee!.toStringAsFixed(0)}' : '-'),
      ],
    );
  }

  Widget _buildReadingsTable(EmissionCertModel e) {
    final hcStd = e.standards?.hc?.toDouble();
    final coStd = e.standards?.co?.toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('TEST READINGS'),
        const SizedBox(height: 8),
        Table(
          border: TableBorder.all(
              color: AppColors.divider, borderRadius: BorderRadius.circular(8)),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1.5),
            2: FlexColumnWidth(1.5),
            3: FlexColumnWidth(1.5),
            4: FlexColumnWidth(1.5),
          },
          children: [
            // Header
            _tableRow(
                ['RPM', 'HC\n(ppm)', 'CO\n(%)', 'O₂\n(%)', 'CO₂\n(%)'],
                isHeader: true,
                rowLabel: 'Reading'),
            // Standards
            _tableRow([
              '-',
              hcStd?.toStringAsFixed(0) ?? '-',
              coStd?.toStringAsFixed(2) ?? '-',
              '-',
              '-',
            ], rowLabel: 'Standard', isStandard: true),
            // Idle
            if (e.readings?.idle != null)
              _tableDataRow(
                  label: 'Idle',
                  row: e.readings!.idle!,
                  hcStd: hcStd,
                  coStd: coStd),
            // 2500 RPM
            if (e.readings?.rpm2500 != null)
              _tableDataRow(
                  label: '2500 RPM',
                  row: e.readings!.rpm2500!,
                  hcStd: hcStd,
                  coStd: coStd),
          ],
        ),
      ],
    );
  }

  TableRow _tableRow(List<String> cells,
      {bool isHeader = false,
      bool isStandard = false,
      required String rowLabel}) {
    final bg = isHeader
        ? const Color(0xFFE8F5E9)
        : isStandard
            ? const Color(0xFFFAFAFA)
            : Colors.white;

    return TableRow(
      decoration: BoxDecoration(color: bg),
      children: [
        Padding(
          padding: const EdgeInsets.all(6),
          child: Text(rowLabel,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: isHeader ? FontWeight.bold : FontWeight.w500,
                  color: isStandard
                      ? AppColors.textSecondary
                      : AppColors.textPrimary)),
        ),
        ...cells.map((c) => Padding(
              padding: const EdgeInsets.all(6),
              child: Text(c,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                      color: isStandard
                          ? AppColors.textSecondary
                          : AppColors.textPrimary)),
            )),
      ],
    );
  }

  TableRow _tableDataRow({
    required String label,
    required EmissionReadingRow row,
    double? hcStd,
    double? coStd,
  }) {
    bool hcOver = hcStd != null &&
        row.hc != null &&
        row.hc!.toDouble() > hcStd;
    bool coOver = coStd != null &&
        row.co != null &&
        row.co!.toDouble() > coStd;

    return TableRow(
      decoration: const BoxDecoration(color: Colors.white),
      children: [
        Padding(
          padding: const EdgeInsets.all(6),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w500)),
        ),
        _readingCell(row.rpm?.toString() ?? '-', false),
        _readingCell(row.hc?.toString() ?? '-', hcOver),
        _readingCell(row.co?.toStringAsFixed(2) ?? '-', coOver),
        _readingCell(row.o2?.toStringAsFixed(2) ?? '-', false),
        _readingCell(row.co2?.toStringAsFixed(2) ?? '-', false),
      ],
    );
  }

  Widget _readingCell(String val, bool isOver) {
    return Container(
      color: isOver ? AppColors.errorRed.withAlpha(15) : null,
      padding: const EdgeInsets.all(6),
      child: Text(val,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 11,
              fontWeight: isOver ? FontWeight.bold : FontWeight.normal,
              color: isOver ? AppColors.errorRed : AppColors.successGreen)),
    );
  }

  Widget _buildResultBanner(EmissionCertModel e) {
    final isPass = e.overallStatus == 'PASS';
    final color  = e.isExpired ? Colors.grey[600]! : (isPass ? AppColors.successGreen : AppColors.errorRed);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: color,
      child: Column(
        children: [
          Text(
            e.isExpired
                ? '✗ CERTIFICATE EXPIRED'
                : (isPass ? '✓ OVERALL STATUS: PASS' : '✗ OVERALL STATUS: FAIL'),
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1),
            textAlign: TextAlign.center,
          ),
          if (e.issuingCompany != null)
            Text(e.issuingCompany!,
                style: TextStyle(
                    color: Colors.white.withAlpha(200), fontSize: 10),
                textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _noDataCard(String title, String msg) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.sm),
            Text(msg,
                style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ── Shared Private Widgets ────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(title,
              style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.5,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600)),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _LargeBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _LargeBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12)),
    );
  }
}

class _OverlayBadge extends StatelessWidget {
  final String text;
  final Color color;
  const _OverlayBadge(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(8)),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _InfoChipWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoChipWidget(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 72) / 2,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textSecondary)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
