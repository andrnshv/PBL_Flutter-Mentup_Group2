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
            reschedule_reason,
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

  Future<String?> acceptBooking(String bookingId) async {
    return _updateStatus(bookingId, 'confirmed');
  }

  Future<String?> rejectBooking(
    String bookingId, {
    required String reason,
  }) async {
    return _updateStatus(bookingId, 'rejected', rejectionNote: reason);
  }

  Future<String?> _updateStatus(
    String bookingId,
    String newStatus, {
    String? rejectionNote,
  }) async {
    try {
      final Map<String, dynamic> payload = {'booking_status': newStatus};

      // ✅ Simpan reason ke reschedule_reason, bukan notes
      if (newStatus == 'rejected' &&
          rejectionNote != null &&
          rejectionNote.isNotEmpty) {
        payload['reschedule_reason'] = rejectionNote;
      }

      // ✅ Bebaskan slot jika rejected
      if (newStatus == 'rejected' && detail?.scheduleId.isNotEmpty == true) {
        await _supabase
            .from('mentor_schedules')
            .update({'is_booked': false}).eq('id', detail!.scheduleId);
      }

      await _supabase.from('bookings').update(payload).eq('id', bookingId);

      if (detail != null) {
        detail = ScheduleBookingDetailModel(
          bookingId: detail!.bookingId,
          bookingStatus: newStatus,
          notes: detail!.notes, // ✅ notes tidak diubah
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
          rescheduleReason: (newStatus == 'rejected' && rejectionNote != null)
              ? rejectionNote
              : detail!.rescheduleReason, // ✅ update rescheduleReason lokal
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
