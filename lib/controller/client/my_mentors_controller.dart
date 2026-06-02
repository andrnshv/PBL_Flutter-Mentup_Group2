import 'package:supabase_flutter/supabase_flutter.dart';

// ================================================================
//  MY MENTORS CONTROLLER — MentUp
//  File: lib/controller/client/my_mentors_controller.dart
//
//  Mengambil daftar mentor yang dipesan klien dari Supabase,
//  dipisah menjadi:
//   - Active : booking 'confirmed' (sudah bayar, sesi belum selesai)
//   - Past   : booking 'done'/'completed' (selesai) atau 'cancelled'
// ================================================================

class MyMentorItem {
  final String bookingId;
  final String mentorId;
  final String name;
  final String role; // kategori mentor
  final String? fotoUrl;
  final String status; // 'Active' | 'Done' | 'Cancelled'

  const MyMentorItem({
    required this.bookingId,
    required this.mentorId,
    required this.name,
    required this.role,
    required this.status,
    this.fotoUrl,
  });
}

class MyMentorsController {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<MyMentorItem> activeMentors = [];
  List<MyMentorItem> pastMentors = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchMyMentors() async {
    isLoading = true;
    errorMessage = null;

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        errorMessage = 'User belum login.';
        isLoading = false;
        return;
      }

      // 1. Ambil semua booking milik klien ini
      final bookings = await _supabase
          .from('bookings')
          .select('id, mentor_id, booking_status, created_at')
          .eq('client_id', userId)
          .order('created_at', ascending: false);

      final bookingList = List<Map<String, dynamic>>.from(bookings);

      if (bookingList.isEmpty) {
        activeMentors = [];
        pastMentors = [];
        isLoading = false;
        return;
      }

      // 2. Kumpulkan mentor_id unik → ambil nama, kategori, foto
      final mentorIds = bookingList
          .map((b) => b['mentor_id'] as String?)
          .whereType<String>()
          .toSet()
          .toList();

      // bio_profil: nama + foto + kategori (lewat category_id → categories)
      final Map<String, Map<String, dynamic>> bioMap = {};
      if (mentorIds.isNotEmpty) {
        final bios = await _supabase
            .from('bio_profil')
            .select(
                'user_id, nama_lengkap, foto_url, categories(category_name)')
            .inFilter('user_id', mentorIds);

        for (final bio in List<Map<String, dynamic>>.from(bios)) {
          bioMap[bio['user_id'] as String] = bio;
        }
      }

      // 3. Petakan tiap booking → MyMentorItem, pisah active vs past
      final List<MyMentorItem> active = [];
      final List<MyMentorItem> past = [];

      for (final b in bookingList) {
        final mentorId = b['mentor_id'] as String? ?? '';
        final bio = bioMap[mentorId];
        final name = bio?['nama_lengkap'] as String? ?? 'Mentor';
        final fotoUrl = bio?['foto_url'] as String?;
        final category = (bio?['categories']
                as Map<String, dynamic>?)?['category_name'] as String? ??
            'Mentor';

        final rawStatus = (b['booking_status'] as String? ?? '').toLowerCase();

        // Tentukan kategori active / past berdasarkan status booking
        if (rawStatus == 'confirmed' ||
            rawStatus == 'paid' ||
            rawStatus == 'active' ||
            rawStatus == 'ongoing') {
          active.add(MyMentorItem(
            bookingId: b['id'] as String,
            mentorId: mentorId,
            name: name,
            role: category,
            fotoUrl: fotoUrl,
            status: 'Active',
          ));
        } else if (rawStatus == 'done' ||
            rawStatus == 'completed' ||
            rawStatus == 'finished') {
          past.add(MyMentorItem(
            bookingId: b['id'] as String,
            mentorId: mentorId,
            name: name,
            role: category,
            fotoUrl: fotoUrl,
            status: 'Done',
          ));
        } else if (rawStatus == 'cancelled' ||
            rawStatus == 'canceled' ||
            rawStatus == 'failed') {
          past.add(MyMentorItem(
            bookingId: b['id'] as String,
            mentorId: mentorId,
            name: name,
            role: category,
            fotoUrl: fotoUrl,
            status: 'Cancelled',
          ));
        }
        // status 'pending' (belum bayar) sengaja TIDAK ditampilkan di sini
      }

      activeMentors = active;
      pastMentors = past;
    } on PostgrestException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = 'Gagal memuat mentor: $e';
    } finally {
      isLoading = false;
    }
  }
}
