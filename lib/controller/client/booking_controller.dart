import 'package:supabase_flutter/supabase_flutter.dart';

class BookingController {
  final _supabase = Supabase.instance.client;

  // =========================================================
  // CREATE BOOKING
  // =========================================================
  Future<String?> createBooking({
    required String mentorId,
    required String scheduleId,
    required String notes,
  }) async {
    try {
      final clientId = _supabase.auth.currentUser?.id;

      if (clientId == null) {
        throw Exception('User belum login');
      }

      final result = await _supabase
          .from('bookings')
          .insert({
            'client_id': clientId,
            'mentor_id': mentorId,
            'schedule_id': scheduleId,
            'booking_status': 'pending',
            'notes': notes,
          })
          .select()
          .single();

      // set slot booked
      await _supabase.from('mentor_schedules').update({
        'is_booked': true,
      }).eq('id', scheduleId);

      return result['id'];
    } catch (e) {
      print(e);
      return null;
    }
  }
}
