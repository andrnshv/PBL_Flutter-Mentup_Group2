import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/duitku_service.dart';

// ================================================================
//  PAYMENT CONTROLLER — MentUp
//  File: lib/controller/client/payment_controller.dart
//
//  Menangani:
//  - Buat invoice Duitku untuk satu atau banyak booking
//  - Verifikasi status pembayaran dari Duitku
//  - Update tabel payments, bookings, dan mentor_schedules
//
//  SLOT LOCKING:
//  Slot mentor (mentor_schedules.is_booked) dikunci di sini,
//  di dalam verifyPayment(), hanya setelah status = 'paid'.
//  Ini mencegah slot terkunci sebelum pembayaran benar-benar lunas.
// ================================================================

class PaymentController extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  bool isLoading = false;
  String? errorMessage;

  // ─────────────────────────────────────────────────────
  // CREATE PAYMENT — buat 1 invoice Duitku untuk
  // satu atau banyak bookingIds sekaligus.
  //
  // Semua booking berbagi 1 merchantOrderId & transaction_id.
  // Row payments di-insert per bookingId.
  // ─────────────────────────────────────────────────────
  Future<String?> createPaymentForBookings({
    required List<String> bookingIds,
    required int amountPerBooking,
    required String mentorName,
    required String clientEmail,
    required String clientName,
    required String clientPhone,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final totalAmount = amountPerBooking * bookingIds.length;

      // merchantOrderId unik, berbasis bookingId pertama + timestamp
      final base = bookingIds.first.replaceAll('-', '');
      final ts = DateTime.now().millisecondsSinceEpoch.toString();
      // Duitku membatasi max 50 karakter
      final raw = 'MT-${base.substring(0, 8)}-$ts';
      final merchantOrderId = raw.length > 50 ? raw.substring(0, 50) : raw;

      final invoice = await DuitkuService.createInvoice(
        merchantOrderId: merchantOrderId,
        paymentAmount: totalAmount,
        productDetails:
            'Mentoring bersama $mentorName (${bookingIds.length} sesi)',
        email: clientEmail,
        phoneNumber: clientPhone,
        customerName: clientName,
        returnUrl: 'mentup://payment/return',
        // Ganti dengan URL Edge Function Supabase kamu:
        callbackUrl:
            'https://YOUR_PROJECT.supabase.co/functions/v1/duitku-callback',
        expiryPeriod: 60,
      );

      if (invoice.statusCode != '00') {
        throw Exception(invoice.statusMessage);
      }

      // Insert 1 row payment per bookingId (sharing reference & merchantOrderId)
      for (final bookingId in bookingIds) {
        await _supabase.from('payments').insert({
          'booking_id': bookingId,
          'amount': amountPerBooking,
          'payment_status': 'pending',
          'merchant_order_id': merchantOrderId,
          'transaction_id': invoice.reference,
          'payment_url': invoice.paymentUrl,
          'payment_method': 'DUITKU',
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      isLoading = false;
      notifyListeners();

      return invoice.paymentUrl;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  // ─────────────────────────────────────────────────────
  // VERIFY PAYMENT — cek status transaksi ke Duitku,
  // lalu update DB.
  //
  // SLOT LOCKING terjadi di sini:
  //   Jika status == 'paid':
  //     1. payments.payment_status = 'paid'
  //     2. bookings.booking_status = 'confirmed'
  //     3. mentor_schedules.is_booked = true  ← LOCK SLOT
  //
  // Return: 'paid' | 'pending' | 'failed' | 'error'
  // ─────────────────────────────────────────────────────
  Future<String> verifyPayment({
    required List<String> bookingIds,
    required String merchantOrderId,
  }) async {
    try {
      final result = await DuitkuService.checkTransactionStatus(
        merchantOrderId: merchantOrderId,
      );

      final status = result.paymentStatus; // 'paid' | 'pending' | 'failed'

      debugPrint('======= VERIFY PAYMENT =======');
      debugPrint('bookingIds      : $bookingIds');
      debugPrint('merchantOrderId : $merchantOrderId');
      debugPrint('statusCode      : ${result.statusCode}');
      debugPrint('status          : $status');
      debugPrint('==============================');

      // Map Duitku status → booking_status yang valid di skema:
      //   'paid'    → 'paid'
      //   'pending' → 'pending'
      //   lainnya   → 'failed'
      // (constraint hanya allow: pending, paid, completed, cancelled, failed)
      final bookingStatus = status == 'paid'
          ? 'paid'
          : status == 'pending'
              ? 'pending'
              : 'failed';

      for (final bookingId in bookingIds) {
        // 1. Update payments
        await _supabase.from('payments').update({
          'payment_status': status,
          'paid_at':
              status == 'paid' ? DateTime.now().toIso8601String() : null,
        }).eq('booking_id', bookingId);

        // 2. Update bookings — skip jika masih pending (tidak perlu update)
        if (bookingStatus != 'pending') {
          await _supabase.from('bookings').update({
            'booking_status': bookingStatus,
          }).eq('id', bookingId);
        }

        // 3. LOCK SLOT — hanya jika paid
        if (status == 'paid') {
          final bookingRow = await _supabase
              .from('bookings')
              .select('schedule_id')
              .eq('id', bookingId)
              .maybeSingle();

          final scheduleId = bookingRow?['schedule_id'] as String?;
          if (scheduleId != null) {
            await _supabase
                .from('mentor_schedules')
                .update({'is_booked': true}).eq('id', scheduleId);

            debugPrint(
                'SLOT LOCKED: schedule_id=$scheduleId (booking=$bookingId)');
          }
        }
      }

      notifyListeners();
      return status;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();

      debugPrint('======= VERIFY ERROR =======');
      debugPrint(e.toString());
      debugPrint('============================');

      return 'error';
    }
  }

  // ─────────────────────────────────────────────────────
  // RESET error state
  // ─────────────────────────────────────────────────────
  void reset() {
    errorMessage = null;
    notifyListeners();
  }
}