import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/mentor/manage_slot_model.dart';

class ManageSlotController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ─────────────────────────────────────────────────────
  // FETCH: slot per tanggal (tanpa JOIN, query simpel)
  // ─────────────────────────────────────────────────────
  Future<List<ManageSlotModel>> fetchSlotsForDate(DateTime date) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final dateStr =
        '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    try {
      final response = await _supabase
          .from('mentor_schedules')
          .select('id, available_date, start_time, end_time, is_booked')
          .eq('mentor_id', userId)
          .eq('available_date', dateStr)
          .order('start_time', ascending: true);

      return (response as List)
          .map((e) => ManageSlotModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ─────────────────────────────────────────────────────
  // FETCH: semua tanggal yang punya slot (dot kalender)
  // ─────────────────────────────────────────────────────
  Future<Set<DateTime>> fetchAllSlotDates() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return {};

    try {
      final response = await _supabase
          .from('mentor_schedules')
          .select('available_date')
          .eq('mentor_id', userId)
          .gte('available_date',
              DateTime.now().toIso8601String().substring(0, 10));

      return (response as List)
          .map<DateTime>(
              (e) => DateTime.parse(e['available_date'] as String))
          .map((d) => DateTime(d.year, d.month, d.day))
          .toSet();
    } catch (_) {
      return {};
    }
  }

  // ─────────────────────────────────────────────────────
  // INSERT: simpan satu slot baru ke mentor_schedules
  // ─────────────────────────────────────────────────────
  Future<String?> insertSlot({
    required DateTime date,
    required String startTime, // "HH:mm"
    required String endTime,   // "HH:mm"
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return 'User not authenticated.';

    final tempModel = ManageSlotModel(
      id:            '',
      availableDate: date,
      startTime:     startTime,
      endTime:       endTime,
      isBooked:      false,
    );

    try {
      await _supabase
          .from('mentor_schedules')
          .insert(tempModel.toInsertJson(userId));
      return null; // sukses
    } on PostgrestException catch (e) {
      return e.message;
    } catch (e) {
      return 'Failed to save slot: $e';
    }
  }

  // ─────────────────────────────────────────────────────
  // DELETE: hapus slot berdasarkan id
  // ─────────────────────────────────────────────────────
  Future<String?> deleteSlot(String slotId) async {
    try {
      await _supabase
          .from('mentor_schedules')
          .delete()
          .eq('id', slotId);
      return null; // sukses
    } on PostgrestException catch (e) {
      return e.message;
    } catch (e) {
      return 'Failed to delete slot: $e';
    }
  }
}