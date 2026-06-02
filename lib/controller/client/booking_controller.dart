import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/client/booking_model.dart';
import '../../services/duitku_service.dart';

// ================================================================
//  BOOKING FORM CONTROLLER — MentUp
//  File: lib/controller/client/booking_controller.dart
//
//  Layer Controller (MVC). Menangani:
//  - Ambil slot jadwal mentor yang tersedia
//  - Submit multiple booking ke Supabase
//  - Orchestration pembayaran Duitku (buat invoice + verifikasi)
//
//  View TIDAK melakukan query Supabase sama sekali — semua di sini.
// ================================================================

class BookingFormController {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<BookingFormModel> availableSlots = [];
  bool isLoading = false;
  String? errorMessage;

  // ── State pembayaran (dipakai antara submit → verify) ──
  List<String> currentBookingIds = [];
  String? currentMerchantOrderId;
  String? currentMasterBookingId;
  String? currentPaymentUrl;

  // ─────────────────────────────────────────────────────
  // FETCH semua slot tersedia milik mentor
  // ─────────────────────────────────────────────────────
  Future<void> fetchAvailableSlots(String mentorId) async {
    isLoading = true;
    errorMessage = null;

    try {
      final response = await _supabase
          .from('mentor_schedules')
          .select('id, available_date, start_time, end_time')
          .eq('mentor_id', mentorId)
          .eq('is_booked', false)
          .gte('available_date',
              DateTime.now().toIso8601String().substring(0, 10))
          .order('available_date', ascending: true)
          .order('start_time', ascending: true);

      availableSlots = (response as List)
          .map((e) => BookingFormModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = 'Gagal memuat jadwal: $e';
    } finally {
      isLoading = false;
    }
  }

  /// Cari slot yang tersedia di tanggal tertentu, paling dekat ke jam preferensi.
  /// Mengembalikan null jika tidak ada slot di tanggal tersebut.
  BookingFormModel? findClosestSlot(DateTime date, TimeOfDay? preferredTime) {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final dailySlots =
        availableSlots.where((s) => s.availableDate == dateStr).toList();

    if (dailySlots.isEmpty) return null;
    if (preferredTime == null) return dailySlots.first;

    final prefMinutes = preferredTime.hour * 60 + preferredTime.minute;
    dailySlots.sort((a, b) {
      final aParts = a.startTime.split(':');
      final bParts = b.startTime.split(':');
      final aMin = int.parse(aParts[0]) * 60 + int.parse(aParts[1]);
      final bMin = int.parse(bParts[0]) * 60 + int.parse(bParts[1]);
      return (aMin - prefMinutes).abs().compareTo((bMin - prefMinutes).abs());
    });
    return dailySlots.first;
  }

  /// Set tanggal-tanggal yang punya slot tersedia (untuk highlight di kalender)
  Set<DateTime> get availableDays {
    return availableSlots.map((s) => s.dateTime).toSet();
  }

  // ─────────────────────────────────────────────────────
  // SUBMIT MULTIPLE BOOKING SEKALIGUS
  // Untuk setiap tanggal terpilih → insert 1 booking
  // ─────────────────────────────────────────────────────
  Future<BookingSubmitResult> submitMultipleBookings({
    required String mentorId,
    required List<DateTime> selectedDates,
    required TimeOfDay selectedTime,
    required String locationText,
    String? notes,
  }) async {
    final clientId = _supabase.auth.currentUser?.id;
    if (clientId == null) {
      return BookingSubmitResult(
        successIds: [],
        failedDates: selectedDates,
        errorMessage: 'User belum login.',
      );
    }

    debugPrint('CLIENT ID  : $clientId');
    debugPrint('MENTOR ID  : $mentorId');
    debugPrint('TOTAL DATE : ${selectedDates.length}');

    final List<String> successIds = [];
    final List<DateTime> failedDates = [];
    String? lastError;

    for (final date in selectedDates) {
      final slot = findClosestSlot(date, selectedTime);
      if (slot == null) {
        failedDates.add(date);
        continue;
      }

      try {
        final result = await _supabase
            .from('bookings')
            .insert({
              'client_id': clientId,
              'mentor_id': mentorId,
              'schedule_id': slot.scheduleId,
              'booking_status': 'pending',
              'session_type': 'Offline',
              'session_link': locationText,
              'notes': notes,
            })
            .select('id')
            .single();

        // NOTE: slot BELUM ditandai booked di sini.
        // Slot ditandai booked nanti SETELAH pembayaran sukses
        // (lihat verifyCurrentPayment). Ini mencegah slot terkunci
        // padahal pembayaran belum tentu jadi.

        successIds.add(result['id'] as String);
      } on PostgrestException catch (e) {
        lastError = e.message;
        failedDates.add(date);
      } catch (e) {
        lastError = '$e';
        failedDates.add(date);
      }
    }

    return BookingSubmitResult(
      successIds: successIds,
      failedDates: failedDates,
      errorMessage: successIds.isEmpty
          ? (lastError ?? 'Tidak ada booking yang berhasil dibuat')
          : null,
    );
  }

  // ─────────────────────────────────────────────────────
  // BUAT INVOICE DUITKU untuk booking yang berhasil
  // Dipanggil View setelah submitMultipleBookings sukses
  // ─────────────────────────────────────────────────────
  Future<PaymentInitResult> createPaymentForBookings({
    required List<String> bookingIds,
    required int amountPerBooking,
    required String mentorName,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return const PaymentInitResult(errorMessage: 'User belum login');
      }

      // Ambil data klien (di controller, bukan view)
      final userRow = await _supabase
          .from('appuser')
          .select('nama_lengkap, email')
          .eq('id', user.id)
          .single();

      final bioRow = await _supabase
          .from('bio_profil')
          .select('nomor_hp')
          .eq('user_id', user.id)
          .maybeSingle();

      final clientName = userRow['nama_lengkap'] as String? ?? 'Klien';
      final clientEmail = userRow['email'] as String? ?? '';
      final clientPhone = bioRow?['nomor_hp'] as String? ?? '08100000000';

      final totalAmount = amountPerBooking * bookingIds.length;
      final masterBookingId = bookingIds.first;
      final merchantOrderId =
          masterBookingId.replaceAll('-', '').substring(0, 20);

      // Panggil Duitku
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
        return PaymentInitResult(errorMessage: invoice.statusMessage);
      }

      // Insert 1 row payment per booking (sharing transaction_id sama)
      for (final bid in bookingIds) {
        await _supabase.from('payments').insert({
          'booking_id': bid,
          'payment_method': 'duitku',
          'transaction_id': invoice.reference,
          'amount': amountPerBooking,
          'payment_status': 'pending',
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // Simpan state untuk verifikasi nanti
      currentBookingIds = bookingIds;
      currentMerchantOrderId = merchantOrderId;
      currentMasterBookingId = masterBookingId;
      currentPaymentUrl = invoice.paymentUrl;

      return PaymentInitResult(
        paymentUrl: invoice.paymentUrl,
        merchantOrderId: merchantOrderId,
        masterBookingId: masterBookingId,
      );
    } catch (e) {
      return PaymentInitResult(
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  // ─────────────────────────────────────────────────────
  // VERIFIKASI status pembayaran setelah kembali dari Duitku
  // Update payments + bookings + tandai slot booked jika lunas
  // Return: 'paid' | 'pending' | 'failed' | 'error'
  // ─────────────────────────────────────────────────────
  Future<String> verifyCurrentPayment() async {
    if (currentMerchantOrderId == null || currentBookingIds.isEmpty) {
      return 'error';
    }

    try {
      final status = await DuitkuService.checkTransactionStatus(
        merchantOrderId: currentMerchantOrderId!,
      );

      final ps = status.paymentStatus; // 'paid' | 'pending' | 'failed'

      for (final bid in currentBookingIds) {
        // Update payment
        await _supabase.from('payments').update({
          'payment_status': ps,
          'paid_at': ps == 'paid' ? DateTime.now().toIso8601String() : null,
        }).eq('booking_id', bid);

        if (ps == 'paid') {
          // Konfirmasi booking
          await _supabase
              .from('bookings')
              .update({'booking_status': 'confirmed'}).eq('id', bid);

          // Tandai slot mentor jadi booked
          final bookingRow = await _supabase
              .from('bookings')
              .select('schedule_id')
              .eq('id', bid)
              .maybeSingle();

          if (bookingRow?['schedule_id'] != null) {
            await _supabase.from('mentor_schedules').update(
                {'is_booked': true}).eq('id', bookingRow!['schedule_id']);
          }
        }
      }

      return ps;
    } catch (e) {
      return 'error';
    }
  }
}

/// Hasil submit multiple booking
class BookingSubmitResult {
  final List<String> successIds;
  final List<DateTime> failedDates;
  final String? errorMessage;

  const BookingSubmitResult({
    required this.successIds,
    required this.failedDates,
    this.errorMessage,
  });

  bool get isFullSuccess => successIds.isNotEmpty && failedDates.isEmpty;
  bool get isPartialSuccess => successIds.isNotEmpty && failedDates.isNotEmpty;
  bool get isFullFail => successIds.isEmpty;
}

/// Hasil inisiasi pembayaran Duitku
class PaymentInitResult {
  final String? paymentUrl;
  final String? merchantOrderId;
  final String? masterBookingId;
  final String? errorMessage;

  const PaymentInitResult({
    this.paymentUrl,
    this.merchantOrderId,
    this.masterBookingId,
    this.errorMessage,
  });

  bool get isSuccess => paymentUrl != null && paymentUrl!.isNotEmpty;
}
