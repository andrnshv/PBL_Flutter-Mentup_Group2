import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/client/booking_model.dart';

// ================================================================
//  RESCHEDULE CONTROLLER — MentUp (sisi CLIENT)
//  File: lib/controller/client/reschedule_page_controller.dart
//
//  Dipakai saat client ingin reschedule booking yang di-reject mentor.
//  Alur:
//    1. Fetch slot mentor yang masih available
//    2. Client pilih tanggal + jam baru
//    3. Update booking: ganti schedule_id + session_start/end
//       + status kembali ke 'paid' (agar mentor bisa acc/reject lagi)
// ================================================================

class ReschedulePageController {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<BookingFormModel> availableSlots = [];
  bool isLoading = false;
  String? errorMessage;

  // ─────────────────────────────────────────────────────
  // FETCH slot mentor yang masih tersedia (is_booked = false)
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

  /// Tanggal tersedia untuk kalender
  Set<DateTime> get availableDays =>
      availableSlots.map((s) => s.dateTime).toSet();

  /// Cari slot di tanggal tertentu yang paling dekat jam yang dipilih
  BookingFormModel? findSlot(DateTime date, TimeOfDay? preferredTime) {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final daily =
        availableSlots.where((s) => s.availableDate == dateStr).toList();
    if (daily.isEmpty) return null;
    if (preferredTime == null) return daily.first;
    final pref = preferredTime.hour * 60 + preferredTime.minute;
    daily.sort((a, b) {
      final ap = a.startTime.split(':');
      final bp = b.startTime.split(':');
      final am = int.parse(ap[0]) * 60 + int.parse(ap[1]);
      final bm = int.parse(bp[0]) * 60 + int.parse(bp[1]);
      return (am - pref).abs().compareTo((bm - pref).abs());
    });
    return daily.first;
  }

  /// Validasi jam booking: durasi 1-4 jam, dalam range slot mentor
  String? validateTime({
    required DateTime date,
    required TimeOfDay start,
    required TimeOfDay end,
  }) {
    final startMin = start.hour * 60 + start.minute;
    final endMin = end.hour * 60 + end.minute;
    if (endMin <= startMin) return 'Jam selesai harus setelah jam mulai.';
    final dur = endMin - startMin;
    if (dur < 60) return 'Durasi minimal 1 jam.';
    if (dur > 240) return 'Durasi maksimal 4 jam.';
    final slot = findSlot(date, start);
    if (slot == null) return 'Mentor tidak punya jadwal di tanggal ini.';
    final ms = slot.startTime.split(':');
    final mentorStart = int.parse(ms[0]) * 60 + int.parse(ms[1]);
    int mentorEnd = 24 * 60;
    if (slot.endTime != null && slot.endTime!.isNotEmpty) {
      final me = slot.endTime!.split(':');
      mentorEnd = int.parse(me[0]) * 60 + int.parse(me[1]);
    }
    if (startMin < mentorStart || endMin > mentorEnd) {
      return 'Jam harus di dalam jadwal mentor '
          '(${slot.startTime} - ${slot.endTime ?? '-'}).';
    }
    return null;
  }

  // ─────────────────────────────────────────────────────
  // UPDATE BOOKING untuk reschedule:
  //   - ganti schedule_id ke slot baru
  //   - update session_start_time / session_end_time
  //   - status kembali ke 'paid' (mentor perlu acc/reject lagi)
  //   - reset reschedule_reason
  // ─────────────────────────────────────────────────────
  Future<String?> submitReschedule({
    required String bookingId,
    required DateTime newDate,
    required TimeOfDay newStart,
    required TimeOfDay newEnd,
  }) async {
    try {
      final slot = findSlot(newDate, newStart);
      if (slot == null) return 'Slot tidak ditemukan untuk tanggal ini.';

      final startStr =
          '${newStart.hour.toString().padLeft(2, '0')}:${newStart.minute.toString().padLeft(2, '0')}';
      final endStr =
          '${newEnd.hour.toString().padLeft(2, '0')}:${newEnd.minute.toString().padLeft(2, '0')}';

      await _supabase.from('bookings').update({
        'schedule_id': slot.scheduleId,
        'session_start_time': startStr,
        'session_end_time': endStr,
        'booking_status': 'paid', // kembali ke paid → mentor acc/reject
        'reschedule_reason': null, // reset alasan
      }).eq('id', bookingId);

      return null; // sukses
    } on PostgrestException catch (e) {
      return e.message;
    } catch (e) {
      return '$e';
    }
  }
}
