import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/client/booking_model.dart';

// ================================================================
//  BOOKING FORM CONTROLLER — MentUp
//  File: lib/controller/client/booking_controller.dart
//
//  Layer Controller (MVC). Menangani:
//  - Ambil slot jadwal mentor yang tersedia
//  - Submit multiple booking ke Supabase
//
//  Semua logika pembayaran Duitku sudah dipindah sepenuhnya ke
//  PaymentController & PaymentPage.
//
//  Slot mentor dikunci (is_booked = true) oleh PaymentPage
//  setelah verifyPayment() mengembalikan status 'paid'.
// ================================================================

class BookingFormController {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<BookingFormModel> availableSlots = [];
  bool isLoading = false;
  String? errorMessage;

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
  //
  // CATATAN PENTING — slot locking:
  // Slot TIDAK langsung dikunci di sini karena pembayaran
  // belum tentu jadi. Slot dikunci oleh PaymentController
  // saat verifyPayment() mengembalikan 'paid'.
  // ─────────────────────────────────────────────────────
  Future<BookingSubmitResult> submitMultipleBookings({
    required String mentorId,
    required List<DateTime> selectedDates,
    required TimeOfDay selectedTime,
    required TimeOfDay selectedEndTime,
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

    // Format jam selesai untuk disimpan ke DB
    final endTimeStr =
        '${selectedEndTime.hour.toString().padLeft(2, '0')}:${selectedEndTime.minute.toString().padLeft(2, '0')}';

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
      // TIDAK ada session_end_time di sini
    })
    .select('id')
    .single();

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
}

// ─────────────────────────────────────────────────────
/// Hasil submit multiple booking
// ─────────────────────────────────────────────────────
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