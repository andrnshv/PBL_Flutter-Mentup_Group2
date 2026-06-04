import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/mentor/schedule_model.dart';

class MyScheduleController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ── State publik ──────────────────────────────────────
  List<MyScheduleModel> allSchedules = [];
  List<MyScheduleModel> filteredSchedules = [];

  bool isLoading = false;
  String? errorMessage;

  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  bool isAscending = true;

  // Query bookings: kolom sesuai schema terbaru
  // (session_type & session_link sudah DIHAPUS, diganti
  //  session_start_time, session_end_time, client_address)
  static const String _selectQuery = '''
    id,
    available_date,
    start_time,
    end_time,
    is_booked,
    bookings(
      id,
      booking_status,
      session_start_time,
      session_end_time,
      client_address,
      appuser:client_id(
        id,
        nama_lengkap
      )
    )
  ''';

  // ─────────────────────────────────────────────────────
  // FETCH: semua jadwal mentor (untuk dot marker kalender)
  // ─────────────────────────────────────────────────────
  Future<void> fetchSchedules() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      errorMessage = 'User not authenticated.';
      return;
    }

    isLoading = true;
    errorMessage = null;

    try {
      final response = await _supabase
          .from('mentor_schedules')
          .select(_selectQuery)
          .eq('mentor_id', userId)
          .order('available_date', ascending: true)
          .order('start_time', ascending: true);

      allSchedules = (response as List)
          .map((e) => MyScheduleModel.fromJson(e as Map<String, dynamic>))
          .toList();

      applyFilter();
    } on PostgrestException catch (e) {
      errorMessage = e.message;
      filteredSchedules = [];
    } catch (e) {
      errorMessage = 'Failed to load schedules: $e';
      filteredSchedules = [];
    } finally {
      isLoading = false;
    }
  }

  // ─────────────────────────────────────────────────────
  // FETCH: jadwal untuk tanggal tertentu (dengan JOIN)
  // ─────────────────────────────────────────────────────
  Future<void> fetchSchedulesForDate(DateTime date) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      errorMessage = 'User not authenticated.';
      return;
    }

    isLoading = true;
    errorMessage = null;

    final dateStr = '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    try {
      final response = await _supabase
          .from('mentor_schedules')
          .select(_selectQuery)
          .eq('mentor_id', userId)
          .eq('available_date', dateStr)
          .order('start_time', ascending: true);

      allSchedules = (response as List)
          .map((e) => MyScheduleModel.fromJson(e as Map<String, dynamic>))
          .toList();

      applyFilter();
    } on PostgrestException catch (e) {
      errorMessage = e.message;
      filteredSchedules = [];
    } catch (e) {
      errorMessage = 'Failed to load schedules: $e';
      filteredSchedules = [];
    } finally {
      isLoading = false;
    }
  }

  // ─────────────────────────────────────────────────────
  // Tanggal yang punya jadwal (untuk dot kalender)
  // ─────────────────────────────────────────────────────
  Set<DateTime> get scheduledDates {
    return allSchedules
        .map((s) => DateTime(
              s.availableDate.year,
              s.availableDate.month,
              s.availableDate.day,
            ))
        .toSet();
  }

  // ─────────────────────────────────────────────────────
  // FILTER + SORT berdasarkan nama client
  // ─────────────────────────────────────────────────────
  void applyFilter() {
    var result = allSchedules.where((s) {
      if (searchQuery.isEmpty) return true;
      return (s.clientName ?? '')
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
    }).toList();

    result.sort((a, b) {
      final cmp = (a.clientName ?? '').compareTo(b.clientName ?? '');
      return isAscending ? cmp : -cmp;
    });

    filteredSchedules = result;
  }

  // ─────────────────────────────────────────────────────
  // Warna aksen cycling per index
  // ─────────────────────────────────────────────────────
  static const List<Color> _accentColors = [
    Color(0xFFA7C7E7),
    Color(0xFFF5B3CE),
    Color(0xFFCDB4DB),
    Color(0xFFB5EAD7),
    Color(0xFFFFDAC1),
  ];

  Color accentColorFor(int index) =>
      _accentColors[index % _accentColors.length];

  void dispose() {
    searchController.dispose();
  }
}
