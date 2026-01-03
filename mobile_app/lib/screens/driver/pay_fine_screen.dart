import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:payhere_mobilesdk_flutter/payhere_mobilesdk_flutter.dart';

class PayFineScreen extends StatefulWidget {
  final Map<String, dynamic> fine;

  const PayFineScreen({super.key, required this.fine});

  @override
  State<PayFineScreen> createState() => _PayFineScreenState();
}

class _PayFineScreenState extends State<PayFineScreen> {
  
  // PayHere Sandbox Credentials
  final String _merchantId = "1232005"; 
  // Secret is now handled in Backend via Hash


  @override
  Widget build(BuildContext context) {
    double amount = double.tryParse(widget.fine['amount'].toString()) ?? 0.0;
    String offense = widget.fine['offenseName'] ?? "Traffic Fine";
    String fineId = widget.fine['_id'] ?? "Unknown ID";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pay Fine", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bill Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withAlpha(26), blurRadius: 10, spreadRadius: 2)
                ],
                border: Border.all(color: Colors.green.withAlpha(76)),
              ),
              child: Column(
                children: [
                   const Icon(Icons.receipt_long, size: 50, color: Colors.green),
                   const SizedBox(height: 10),
                   Text(offense, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                   const SizedBox(height: 20),
                   const Divider(),
                   const SizedBox(height: 10),
                   _buildRow("Fine ID", fineId.substring(0, 8).toUpperCase()),
                   _buildRow("Date", (widget.fine['createdAt'] ?? "").toString().substring(0, 10)),
                   _buildRow("Vehicle", widget.fine['vehicleNumber'] ?? "N/A"),
                   
                   const SizedBox(height: 20),
                   const Divider(),
                   const SizedBox(height: 10),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       const Text("Total Amount", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                       Text("LKR ${amount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                     ],
                   )
                ],
              ),
            ),
            const Spacer(),
            
            // Pay Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () => _startPayHerePayment(amount, offense, fineId),
                icon: const Icon(Icons.payment, color: Colors.white), 
                label: const Text("PAY NOW (PayHere)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
        ],
      ),
    );
  }

  Future<void> _startPayHerePayment(double amount, String item, String orderId) async {
    
    // 1. Fetch Hash from Backend
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Initializing Secure Payment...")));
    
    String? hash = await _getPayHereHash(orderId, amount);

    if (hash == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Security Error: Could not generate hash."), backgroundColor: Colors.red));
      return;
    }

    // 2. Start Payment
    Map paymentObject = {
      "sandbox": true,                 
      "merchant_id": _merchantId,      
      // "merchant_secret": NO LONGER NEEDED HERE
      "notify_url": "https://e-fine-sl-traffic-management-1.onrender.com/api/fines/payment_notify", 
      "order_id": orderId,             
      "items": item,                   
      "amount": amount.toStringAsFixed(2), 
      "currency": "LKR",
      "hash": hash, // <-- The Secure Hash from Backend               
      "first_name": "Saman",           
      "last_name": "Perera",
      "email": "samanp@gmail.com",
      "phone": "0771234567",
      "address": "No.1, Galle Road",
      "city": "Colombo",
      "country": "Sri Lanka",
      "delivery_address": "No. 46, Galle road, Kalutara South",
      "delivery_city": "Kalutara",
      "delivery_country": "Sri Lanka",
      "custom_1": "",
      "custom_2": ""
    };

    print("---------------- PAYHERE DEBUG ----------------");
    print("Merchant ID: $_merchantId");
    print("Order ID: $orderId");
    print("Hash: $hash");
    print("-----------------------------------------------");

    PayHere.startPayment(
      paymentObject, 
      (paymentId) {
        print("PayHere Success: $paymentId");
        // Success
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payment Successful!"), backgroundColor: Colors.green));
        // TODO: Call Backend to update Fine Status to 'Paid'
        Navigator.pop(context);
      }, 
      (error) {
        print("PayHere Error: $error");
        // Error
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Payment Failed: $error"), backgroundColor: Colors.red));
      }, 
      () {
        // Dismissed
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payment Dismissed")));
      }
    );
  }

  Future<String?> _getPayHereHash(String orderId, double amount) async {
      try {

        final apiUrl = Uri.parse('https://e-fine-sl-traffic-management-1.onrender.com/api/payment/hash');

        final response = await http.post(
          apiUrl,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "order_id": orderId,
            "amount": amount,
            "currency": "LKR"
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['hash'];
        } else {
           print("Hash Error: ${response.body}");
           return null;
        }
      } catch (e) {
        print("Hash Exception: $e");
        return null;
      }
  }
}
