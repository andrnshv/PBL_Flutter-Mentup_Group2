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
//  Semua logika pembayaran berada di PaymentController.
//
//  Revisi:
//  - session_type dihapus
//  - session_link dihapus
//  - mentor_address otomatis diambil dari bio_profil
//  - session_start_time disimpan ke bookings
//  - session_end_time disimpan ke bookings
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
          .gte(
            'available_date',
            DateTime.now().toIso8601String().substring(0, 10),
          )
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

  /// Cari slot yang tersedia di tanggal tertentu
  BookingFormModel? findClosestSlot(
    DateTime date,
    TimeOfDay? preferredTime,
  ) {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final dailySlots =
        availableSlots.where((s) => s.availableDate == dateStr).toList();

    if (dailySlots.isEmpty) return null;
    if (preferredTime == null) return dailySlots.first;

    final prefMinutes =
        preferredTime.hour * 60 + preferredTime.minute;

    dailySlots.sort((a, b) {
      final aParts = a.startTime.split(':');
      final bParts = b.startTime.split(':');

      final aMin =
          int.parse(aParts[0]) * 60 + int.parse(aParts[1]);

      final bMin =
          int.parse(bParts[0]) * 60 + int.parse(bParts[1]);

      return (aMin - prefMinutes)
          .abs()
          .compareTo((bMin - prefMinutes).abs());
    });

    return dailySlots.first;
  }

  /// Highlight kalender
  Set<DateTime> get availableDays {
    return availableSlots.map((s) => s.dateTime).toSet();
  }

  // ─────────────────────────────────────────────────────
  // SUBMIT BOOKING
  // ─────────────────────────────────────────────────────
  Future<BookingSubmitResult> submitMultipleBookings({
    required String mentorId,
    required List<DateTime> selectedDates,

    /// Jam yang dipilih client
    required TimeOfDay selectedStartTime,
    required TimeOfDay selectedEndTime,

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

    String clientAddress = '';

    try {
      final profile = await _supabase
          .from('bio_profil')
          .select('address')
          .eq('user_id', mentorId)
          .single();

      clientAddress = profile['address'] ?? '';
    } catch (_) {
      clientAddress = '';
    }

    final sessionStartTime =
        '${selectedStartTime.hour.toString().padLeft(2, '0')}:${selectedStartTime.minute.toString().padLeft(2, '0')}';

    final sessionEndTime =
        '${selectedEndTime.hour.toString().padLeft(2, '0')}:${selectedEndTime.minute.toString().padLeft(2, '0')}';

    final List<String> successIds = [];
    final List<DateTime> failedDates = [];

    String? lastError;

    for (final date in selectedDates) {
      final slot = findClosestSlot(
        date,
        selectedStartTime,
      );

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
              'notes': notes,

              // Revisi schema
              'session_start_time': sessionStartTime,
              'session_end_time': sessionEndTime,
              'client_address': clientAddress,
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
/// Hasil submit booking
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

  bool get isFullSuccess =>
      successIds.isNotEmpty && failedDates.isEmpty;

  bool get isPartialSuccess =>
      successIds.isNotEmpty && failedDates.isNotEmpty;

  bool get isFullFail => successIds.isEmpty;
}