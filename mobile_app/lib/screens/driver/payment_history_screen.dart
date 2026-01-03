import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_app/services/fine_service.dart';
import 'package:intl/intl.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final FineService _fineService = FineService();
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data = await _fineService.getDriverPaidFines();
    if(mounted) {
      setState(() {
        _history = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Payment History", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : _history.isEmpty 
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[400]),
                   const SizedBox(height: 10),
                   Text("No payment history found", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final fine = _history[index];
                
                // Payment Date
                String paidDateStr = fine['paidAt'] ?? fine['updatedAt'] ?? DateTime.now().toIso8601String();
                DateTime paidDateTime = DateTime.parse(paidDateStr);
                String paidDate = DateFormat('yyyy-MM-dd').format(paidDateTime);
                String paidTime = DateFormat('hh:mm a').format(paidDateTime);

                // Issued Date (from fine creation date)
                String issuedDateStr = fine['date'] ?? DateTime.now().toIso8601String();
                DateTime issuedDateTime = DateTime.parse(issuedDateStr);
                String issuedDate = DateFormat('yyyy-MM-dd').format(issuedDateTime);
                String issuedTime = DateFormat('hh:mm a').format(issuedDateTime);

                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 8, offset: const Offset(0, 4))
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.green.withAlpha(30), shape: BoxShape.circle),
                              child: const Icon(Icons.check_circle, color: Colors.green, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                fine['offenseName'] ?? 'Traffic Fine',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            Text(
                              "LKR ${fine['amount']}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                            )
                          ],
                        ),
                        const Divider(height: 20),
                        
                        // Section 1: Issued Details
                        const Text("Issued Details", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 12)),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                             Expanded(child: _buildDetailItem(Icons.calendar_today, "Date", issuedDate)),
                             Expanded(child: _buildDetailItem(Icons.access_time, "Time", issuedTime)),
                             Expanded(child: _buildDetailItem(Icons.location_on, "Location", fine['place'] ?? '-')),
                          ],
                        ),
                        
                        const SizedBox(height: 15),
                        
                        // Section 2: Payment Details
                        const Text("Payment Details", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 12)),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                             Expanded(child: _buildDetailItem(Icons.event_available, "Paid Date", paidDate)),
                             Expanded(child: _buildDetailItem(Icons.schedule, "Paid Time", paidTime)),
                             Expanded(child: Builder(
                               builder: (context) {
                                 String pid = (fine['paymentId'] ?? 'Manual').toString();
                                 String displayPid = pid.length > 8 ? "...${pid.substring(pid.length - 8)}" : pid;
                                 
                                 // Custom layout with a small button
                                 return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.receipt, size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          const Text("Ref ID", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                          const SizedBox(width: 4),
                                          InkWell(
                                            onTap: () => _showRefIdDialog(context, pid),
                                            child: const Icon(Icons.info_outline, size: 14, color: Colors.blue),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                         displayPid, 
                                         style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                         maxLines: 1,
                                         overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                 );
                               }
                             )),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Flexible(child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
           value, 
           style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
           maxLines: 2,
           overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  void _showRefIdDialog(BuildContext context, String fullId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Payment Reference ID"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             const Text("This is the unique transaction ID for your payment."),
             const SizedBox(height: 10),
             Container(
               padding: const EdgeInsets.all(10),
               decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
               width: double.infinity,
               child: SelectableText(fullId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center),
             )
          ],
        ),
        actions: [
          TextButton.icon(
             icon: const Icon(Icons.copy),
             label: const Text("Copy"),
             onPressed: () {
               Clipboard.setData(ClipboardData(text: fullId));
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied to Clipboard")));
               Navigator.pop(ctx);
             },
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close"))
        ],
      )
    );
  }
}
