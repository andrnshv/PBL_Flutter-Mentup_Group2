import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/duitku_service.dart';

class PaymentController extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  bool isLoading = false;
  String? errorMessage;

  // =========================================================
  // CREATE PAYMENT
  // =========================================================
  Future<String?> createPayment({
    required String bookingId,
    required int amount,
    required String mentorName,
    required String clientEmail,
    required String clientName,
    required String clientPhone,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final merchantOrderId =
          'MT-${bookingId.replaceAll('-', '')}-${DateTime.now().millisecondsSinceEpoch}';

      final invoice = await DuitkuService.createInvoice(
        merchantOrderId: merchantOrderId,
        paymentAmount: amount,
        productDetails: 'Mentoring Session - $mentorName',
        email: clientEmail,
        phoneNumber: clientPhone,
        customerName: clientName,
        returnUrl: 'mentup://payment/return',
      );

      await _supabase.from('payments').insert({
        'booking_id': bookingId,
        'amount': amount,
        'payment_status': 'pending',
        'merchant_order_id': merchantOrderId,
        'reference': invoice.reference,
        'payment_url': invoice.paymentUrl,
        'payment_method': 'DUITKU',
        'created_at': DateTime.now().toIso8601String(),
      });

      isLoading = false;
      notifyListeners();

      return invoice.paymentUrl;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // =========================================================
  // VERIFY PAYMENT (CORE LOGIC FIX HERE)
  // =========================================================
Future<String> verifyPayment({
  required String bookingId,
  required String merchantOrderId,
}) async {
  try {
    final result = await DuitkuService.checkTransactionStatus(
      merchantOrderId: merchantOrderId,
    );

    final status = result.paymentStatus;

    print('================ VERIFY PAYMENT =================');
    print('bookingId       : $bookingId');
    print('merchantOrderId : $merchantOrderId');
    print('statusCode      : ${result.statusCode}');
    print('status          : $status');
    print('================================================');

    // =====================================================
    // UPSERT PAYMENT (BASED ON booking_id)
    // =====================================================
    await _supabase.from('payments').upsert({
  'booking_id': bookingId,
  'merchant_order_id': merchantOrderId,
  'payment_status': status,
  'paid_at': status == 'paid'
      ? DateTime.now().toIso8601String()
      : null,
}, onConflict: 'booking_id');

    // =====================================================
    // UPDATE BOOKINGS STATUS
    // =====================================================
    await _supabase.from('bookings').update({
      'booking_status': status,
    }).eq('id', bookingId);

    print('================ UPSERT SUCCESS =================');

    notifyListeners();

    return status;
  } catch (e) {
    errorMessage = e.toString();
    notifyListeners();

    print('================ VERIFY ERROR =================');
    print(e);
    print('===============================================');

    return 'failed';
  }
}

  // =========================================================
  // RESET
  // =========================================================
  void reset() {
    errorMessage = null;
    notifyListeners();
  }
}