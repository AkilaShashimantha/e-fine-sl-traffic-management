import 'dart:math';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

// ---------------------------------------------------------------------------
// CustomPainter — 300° gauge arc (speedometer style)
// ---------------------------------------------------------------------------
class _GaugeArcPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0
  final Color arcColor;

  _GaugeArcPainter({required this.progress, required this.arcColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 10;

    const double sweepTotal = 300 * pi / 180; // 300°
    const double startAngle = 120 * pi / 180; // bottom-left start

    // Background track
    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepTotal,
      false,
      bgPaint,
    );

    // Foreground (filled) arc
    if (progress > 0) {
      final fgPaint = Paint()
        ..color = arcColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepTotal * progress,
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GaugeArcPainter old) =>
      old.progress != progress || old.arcColor != arcColor;
}

// ---------------------------------------------------------------------------
// DemeritStatusCard — gauge version with localization
// ---------------------------------------------------------------------------
class DemeritStatusCard extends StatefulWidget {
  final int points;            // 0–100
  final String status;         // 'ACTIVE' or 'SUSPENDED'
  final DateTime? suspendedAt;

  const DemeritStatusCard({
    required this.points,
    required this.status,
    this.suspendedAt,
    super.key,
  });

  @override
  State<DemeritStatusCard> createState() => _DemeritStatusCardState();
}

class _DemeritStatusCardState extends State<DemeritStatusCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween<double>(begin: 0.0, end: widget.points / 100)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant DemeritStatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points != widget.points) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.points / 100,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // -- Color helper based on points --
  Color _getStatusColor(int pts) {
    if (pts >= 70) return const Color(0xFF4CAF50); // Green
    if (pts >= 40) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFF44336);                 // Red
  }

  // -- Localized label helper based on points --
  String _getStatusLabel(int pts) {
    if (pts <= 0) return 'demerit_suspended'.tr();
    if (pts >= 70) return 'demerit_good'.tr();
    if (pts >= 40) return 'demerit_warning'.tr();
    return 'demerit_danger'.tr();
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(widget.points);
    final label = widget.status == 'SUSPENDED'
        ? 'demerit_suspended'.tr()
        : _getStatusLabel(widget.points);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Title ──────────────────────────────────────
            Text(
              'demerit_title'.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 20),

            // ── Gauge circle ───────────────────────────────
            AnimatedBuilder(
              animation: _animation,
              builder: (context, _) {
                final displayPts = (_animation.value * 100).round();
                final animColor = _getStatusColor(displayPts);
                return SizedBox(
                  width: 180,
                  height: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(180, 180),
                        painter: _GaugeArcPainter(
                          progress: _animation.value,
                          arcColor: animColor,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$displayPts / 100',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: animColor,
                            ),
                          ),
                          Text(
                            'demerit_points_label'.tr(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            // ── Status label ───────────────────────────────
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),

            // ── Suspended date ─────────────────────────────
            if (widget.status == 'SUSPENDED' &&
                widget.suspendedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'demerit_suspended_on'.tr(args: [_formatDate(widget.suspendedAt!)]),
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],

            // ── Reinstatement info banner ───────────────────
            if (widget.status == 'SUSPENDED') ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'demerit_reinstate_info'.tr(),
                        style: const TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
