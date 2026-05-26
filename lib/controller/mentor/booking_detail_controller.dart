import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/mentor/booking_detail_model.dart';

class ScheduleBookingDetailController {
  final SupabaseClient _supabase = Supabase.instance.client;

  ScheduleBookingDetailModel? detail;
  bool    isLoading    = false;
  String? errorMessage;

  Future<void> fetchDetail(String bookingId) async {
    isLoading    = true;
    errorMessage = null;
    detail       = null;

    try {
      final response = await _supabase
          .from('bookings')
          .select('''
            id,
            booking_status,
            notes,
            session_type,
            session_link,
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
          ''')
          .eq('id', bookingId)
          .single();

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

  Future<String?> updateBookingStatus(
    String bookingId,
    String newStatus, {
    String? rejectionNote,
  }) async {
    try {
      final Map<String, dynamic> payload = {
        'booking_status': newStatus,
      };

      if (newStatus == 'Rejected' &&
          rejectionNote != null &&
          rejectionNote.isNotEmpty) {
        payload['notes'] = rejectionNote;
      }

      await _supabase
          .from('bookings')
          .update(payload)
          .eq('id', bookingId);

      if (detail != null) {
        detail = ScheduleBookingDetailModel(
          bookingId:      detail!.bookingId,
          bookingStatus:  newStatus,
          notes:          newStatus == 'Rejected' && rejectionNote != null
                              ? rejectionNote
                              : detail!.notes,
          sessionType:    detail!.sessionType,
          sessionLink:    detail!.sessionLink,
          scheduleId:     detail!.scheduleId,
          availableDate:  detail!.availableDate,
          startTime:      detail!.startTime,
          endTime:        detail!.endTime,
          clientId:       detail!.clientId,
          clientName:     detail!.clientName,
          clientEmail:    detail!.clientEmail,
          clientPhone:    detail!.clientPhone,
          clientPhotoUrl: detail!.clientPhotoUrl,
          clientAddress:  detail!.clientAddress,
          categoryName:   detail!.categoryName,
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