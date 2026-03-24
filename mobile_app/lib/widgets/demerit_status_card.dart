import 'package:flutter/material.dart';

class DemeritStatusCard extends StatelessWidget {
  final int points;      // 0–100
  final String status;      // 'ACTIVE' or 'SUSPENDED'
  final DateTime? suspendedAt;

  const DemeritStatusCard({
    required this.points,
    required this.status,
    this.suspendedAt,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isSuspended = status == 'SUSPENDED';
    final color       = isSuspended ? Colors.red : Colors.green;
    final bgColor     = isSuspended ? Colors.red.shade50 : Colors.green.shade50;
    final icon        = isSuspended ? Icons.block : Icons.verified_user;
    final label       = isSuspended ? 'License Suspended' : 'License Active';

    return Card(
      color:  bgColor,
      shape:  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Header row
            Row(
              children: [
                Icon(icon, color: color, size: 36),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize:   18,
                        fontWeight: FontWeight.bold,
                        color:      color,
                      ),
                    ),
                    if (isSuspended && suspendedAt != null)
                      Text(
                        'Suspended on ${_formatDate(suspendedAt!)}',
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Points label
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Demerit Points Remaining',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                Text(
                  '$points / 100',
                  style: TextStyle(
                    fontSize:   14,
                    fontWeight: FontWeight.bold,
                    color:      color,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value:           points / 100,
                minHeight:       12,
                backgroundColor: Colors.grey.shade300,
                color:           color,
              ),
            ),

            if (isSuspended) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:        Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.red, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your license will be reinstated on the 1st of next month.',
                        style: TextStyle(fontSize: 12, color: Colors.red),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
