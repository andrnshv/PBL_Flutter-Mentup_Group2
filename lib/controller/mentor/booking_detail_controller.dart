import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/mentor/booking_detail_model.dart';

class ScheduleBookingDetailController {
  final SupabaseClient _supabase = Supabase.instance.client;

  ScheduleBookingDetailModel? detail;
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchDetail(String bookingId) async {
    isLoading = true;
    errorMessage = null;
    detail = null;

    try {
      final response = await _supabase.from('bookings').select('''
            id,
            booking_status,
            notes,
            session_start_time,
            session_end_time,
            client_address,
            mentor_schedules!schedule_id (
              id,
              available_date,
              start_time,
              end_time
            ),
            appuser:client_id (
              id,
              nama_lengkap,
              email,
              bio_profil (
                nomor_hp,
                foto_url,
                alamat,
                categories (
                  category_name
                )
              )
            )
          ''').eq('id', bookingId).single();

      detail = ScheduleBookingDetailModel.fromJson(
        response as Map<String, dynamic>,
      );
    } on PostgrestException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = 'Gagal memuat detail booking: $e';
    } finally {
      isLoading = false;
    }
  }

  // ─────────────────────────────────────────────────────
  // ACCEPT booking (paid → confirmed)
  // ─────────────────────────────────────────────────────
  Future<String?> acceptBooking(String bookingId) async {
    return _updateStatus(bookingId, 'confirmed');
  }

  // ─────────────────────────────────────────────────────
  // REJECT booking (paid → rejected) + simpan alasan
  // ─────────────────────────────────────────────────────
  Future<String?> rejectBooking(
    String bookingId, {
    required String reason,
  }) async {
    return _updateStatus(bookingId, 'rejected', rejectionNote: reason);
  }

  // ─────────────────────────────────────────────────────
  // Update status umum
  // ─────────────────────────────────────────────────────
  Future<String?> _updateStatus(
    String bookingId,
    String newStatus, {
    String? rejectionNote,
  }) async {
    try {
      final Map<String, dynamic> payload = {
        'booking_status': newStatus,
      };

      if (newStatus == 'rejected' &&
          rejectionNote != null &&
          rejectionNote.isNotEmpty) {
        payload['notes'] = rejectionNote;
      }

      await _supabase.from('bookings').update(payload).eq('id', bookingId);

      // Update salinan lokal supaya UI langsung berubah
      if (detail != null) {
        detail = ScheduleBookingDetailModel(
          bookingId: detail!.bookingId,
          bookingStatus: newStatus,
          notes: (newStatus == 'rejected' && rejectionNote != null)
              ? rejectionNote
              : detail!.notes,
          scheduleId: detail!.scheduleId,
          availableDate: detail!.availableDate,
          startTime: detail!.startTime,
          endTime: detail!.endTime,
          sessionStartTime: detail!.sessionStartTime,
          sessionEndTime: detail!.sessionEndTime,
          clientId: detail!.clientId,
          clientName: detail!.clientName,
          clientEmail: detail!.clientEmail,
          clientPhone: detail!.clientPhone,
          clientPhotoUrl: detail!.clientPhotoUrl,
          clientBioAddress: detail!.clientBioAddress,
          clientAddress: detail!.clientAddress,
          categoryName: detail!.categoryName,
        );
      }

      return null;
    } on PostgrestException catch (e) {
      return e.message;
    } catch (e) {
      return 'Gagal memperbarui status: $e';
    }
  }
}
