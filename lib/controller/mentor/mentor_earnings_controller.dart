import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/mentor/mentor_earnings_model.dart';

class MentorEarningsController {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<MentorEarningsModel> allEarnings      = [];
  List<MentorEarningsModel> filteredEarnings = [];

  bool    isLoading    = false;
  String? errorMessage;

  // ── Filter state ─────────────────────────────────────
  String searchQuery   = '';
  bool   sortByAmount  = false; // false = tanggal terbaru, true = amount terbesar
  double minAmount     = 0;
  double maxAmount     = 10000000;

  // ─────────────────────────────────────────────────────
  // FETCH dari mentor_earnings
  // JOIN:  payments → bookings → appuser (client) + mentor_schedules
  // Bio foto: query terpisah via email (karena FK bio_profil via email)
  // ─────────────────────────────────────────────────────
  Future<void> fetchEarnings() async {
    final mentorId = _supabase.auth.currentUser?.id;
    if (mentorId == null) {
      errorMessage = 'User not authenticated.';
      return;
    }

    isLoading    = true;
    errorMessage = null;

    try {
      // Query 1: mentor_earnings + payments + bookings + client
      final response = await _supabase
          .from('mentor_earnings')
          .select('''
            id,
            mentor_id,
            payment_id,
            gross_amount,
            platform_fee,
            net_amount,
            created_at,
            payments(
              payment_method,
              payment_status,
              bookings(
                session_start_time,
                appuser:client_id(
                  id,
                  nama_lengkap,
                  email
                ),
                mentor_schedules:schedule_id(
                  available_date
                )
              )
            )
          ''')
          .eq('mentor_id', mentorId)
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> rows =
          List<Map<String, dynamic>>.from(response as List);

      // Query 2: kumpulkan email unik client → batch fetch bio_profil
      final emails = <String>{};
      for (final row in rows) {
        final payment = row['payments']        as Map<String, dynamic>?;
        final booking = payment?['bookings']   as Map<String, dynamic>?;
        final client  = booking?['appuser']    as Map<String, dynamic>?;
        final email   = client?['email']       as String?;
        if (email != null && email.isNotEmpty) emails.add(email);
      }

      final Map<String, String?> fotoMap = {};
      if (emails.isNotEmpty) {
        final bios = await _supabase
            .from('bio_profil')
            .select('email, foto_url')
            .inFilter('email', emails.toList());

        for (final bio in List<Map<String, dynamic>>.from(bios)) {
          final email = bio['email'] as String?;
          if (email != null) {
            fotoMap[email] = bio['foto_url'] as String?;
          }
        }
      }

      // Gabungkan bio ke tiap row sebelum parse model
      allEarnings = rows.map((row) {
        final payment = row['payments']      as Map<String, dynamic>?;
        final booking = payment?['bookings'] as Map<String, dynamic>?;
        final client  = booking?['appuser']  as Map<String, dynamic>?;
        final email   = client?['email']     as String?;

        final enriched = {
          ...row,
          '_bio': email != null
              ? {'foto_url': fotoMap[email]}
              : null,
        };
        return MentorEarningsModel.fromJson(enriched);
      }).toList();

      applyFilter();
    } on PostgrestException catch (e) {
      errorMessage     = e.message;
      filteredEarnings = [];
    } catch (e) {
      errorMessage     = 'Gagal memuat data: $e';
      filteredEarnings = [];
    } finally {
      isLoading = false;
    }
  }

  // ─────────────────────────────────────────────────────
  // Filter + Sort
  // ─────────────────────────────────────────────────────
  void applyFilter() {
    var result = allEarnings.where((e) {
      final matchSearch = searchQuery.isEmpty ||
          (e.clientName ?? '')
              .toLowerCase()
              .contains(searchQuery.toLowerCase());

      final matchPrice =
          e.netAmount >= minAmount && e.netAmount <= maxAmount;

      return matchSearch && matchPrice;
    }).toList();

    if (sortByAmount) {
      result.sort((a, b) => b.netAmount.compareTo(a.netAmount));
    } else {
      result.sort((a, b) => b.sortKey.compareTo(a.sortKey));
    }

    filteredEarnings = result;
  }

  // ─────────────────────────────────────────────────────
  // Summary dari filteredEarnings
  // ─────────────────────────────────────────────────────
  double get totalGross =>
      filteredEarnings.fold(0, (s, e) => s + e.grossAmount);

  double get totalFee =>
      filteredEarnings.fold(0, (s, e) => s + e.platformFee);

  double get totalNet =>
      filteredEarnings.fold(0, (s, e) => s + e.netAmount);

  /// Max netAmount dari seluruh data (untuk batas slider)
  double get maxNetAmount {
    if (allEarnings.isEmpty) return 10000000;
    final max = allEarnings.map((e) => e.netAmount).reduce(
        (a, b) => a > b ? a : b);
    // Bulatkan ke atas ke kelipatan 50.000
    return ((max / 50000).ceil() * 50000).toDouble();
  }
}