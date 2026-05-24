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

      // merchantOrderId unik
      final merchantOrderId = bookingId.replaceAll('-', '').substring(0, 20);

      // =====================================================
      // CREATE INVOICE KE DUITKU
      // =====================================================
      final invoice = await DuitkuService.createInvoice(
        merchantOrderId: merchantOrderId,
        paymentAmount: amount,
        productDetails: 'Mentoring Session - $mentorName',
        email: clientEmail,
        phoneNumber: clientPhone,
        customerName: clientName,
        returnUrl: 'mentup://payment/return',
      );

      // =====================================================
      // SAVE PAYMENT KE SUPABASE
      // =====================================================
      await _supabase.from('payments').insert({
        'booking_id': bookingId,
        'amount': amount,
        'payment_status': 'pending',
        'merchant_order_id': merchantOrderId,
        'reference': invoice.reference,
        'payment_url': invoice.paymentUrl,
        'payment_method': 'DUITKU',
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
  // VERIFY PAYMENT
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

      // =====================================================
      // UPDATE PAYMENTS
      // =====================================================
      await _supabase.from('payments').update({
        'payment_status': status,
        'paid_at': status == 'paid' ? DateTime.now().toIso8601String() : null,
      }).eq('merchant_order_id', merchantOrderId);

      // =====================================================
      // UPDATE BOOKINGS
      // =====================================================
      await _supabase.from('bookings').update({
        'booking_status': status == 'paid' ? 'paid' : status,
      }).eq('id', bookingId);

      // =====================================================
      // INSERT BOOKING HISTORY
      // =====================================================
      if (status == 'paid') {
        final booking = await _supabase
            .from('bookings')
            .select()
            .eq('id', bookingId)
            .single();

        await _supabase.from('booking_histories').insert({
          'booking_id': bookingId,
          'client_id': booking['client_id'],
          'mentor_id': booking['mentor_id'],
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      return status;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();

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
