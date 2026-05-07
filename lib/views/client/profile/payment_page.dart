import 'package:flutter/material.dart';
import '../data/dummy_data.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final history = DummyData.historyMentors;

    return Scaffold(
      appBar: AppBar(title: const Text("Payment & Billing")),
      backgroundColor: const Color(0xFFF8F9FB),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// 💳 PAYMENT METHOD
          const Text(
            "Payment Method",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Row(
              children: [
                Icon(Icons.credit_card),
                SizedBox(width: 10),
                Text("Gopay / Virtual Account"),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// 📜 HISTORY
          const Text(
            "Transactions",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          ...history.map((item) {
            String status;
            Color color;

            if (item["status"] == "Done") {
              status = "Paid";
              color = Colors.green;
            } else {
              status = "Refunded";
              color = Colors.grey;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item["name"],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        Text(item["date"]),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Rp 80.000"),
                      Text(
                        status,
                        style: TextStyle(color: color, fontSize: 12),
                      )
                    ],
                  )
                ],
              ),
            );
          })
        ],
      ),
    );
  }
}