import 'package:supabase_flutter/supabase_flutter.dart';

// ================================================================
//  WHAT THEY SAY CONTROLLER — MentUp
//  File: lib/controller/client/what_they_say_controller.dart
//
//  Menampilkan komentar/review dari klien (tabel `reviews`).
//  Sumber data SAMA dengan Top Mentors — review yang diinput klien
//  di History page langsung muncul di sini.
//
//  Bedanya dengan Top Mentors:
//   - Top Mentors  : per-mentor (rata-rata rating, diranking)
//   - What They Say : per-review (komentar individual dari klien)
// ================================================================

class TestimonialModel {
  final String reviewerName; // nama klien yang memberi review
  final String? reviewerFoto; // foto klien
  final int rating;
  final String comment;
  final String mentorName; // mentor yang dikomentari

  const TestimonialModel({
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.mentorName,
    this.reviewerFoto,
  });
}

class WhatTheySayController {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<TestimonialModel> testimonials = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchTestimonials() async {
    isLoading = true;
    errorMessage = null;

    try {
      // Ambil review yang ada komentarnya, terbaru dulu
      final reviews = await _supabase
          .from('reviews')
          .select('client_id, mentor_id, rating, review_text, created_at')
          .not('review_text', 'is', null)
          .order('created_at', ascending: false)
          .limit(20);

      final list = List<Map<String, dynamic>>.from(reviews);

      // Buang yang komentarnya kosong
      final filtered = list.where((r) {
        final txt = r['review_text'] as String?;
        return txt != null && txt.trim().isNotEmpty;
      }).toList();

      if (filtered.isEmpty) {
        testimonials = [];
        isLoading = false;
        return;
      }

      // Kumpulkan id klien (pemberi review) + mentor (yang dikomentari)
      final clientIds = filtered
          .map((r) => r['client_id'] as String?)
          .whereType<String>()
          .toSet()
          .toList();
      final mentorIds = filtered
          .map((r) => r['mentor_id'] as String?)
          .whereType<String>()
          .toSet()
          .toList();

      final allIds = {...clientIds, ...mentorIds}.toList();

      // Ambil nama + foto dari bio_profil untuk semua id
      final Map<String, Map<String, dynamic>> bioMap = {};
      if (allIds.isNotEmpty) {
        final bios = await _supabase
            .from('bio_profil')
            .select('user_id, nama_lengkap, foto_url')
            .inFilter('user_id', allIds);
        for (final bio in List<Map<String, dynamic>>.from(bios)) {
          bioMap[bio['user_id'] as String] = bio;
        }
      }

      // Fallback nama dari appuser (kalau klien tidak punya bio_profil)
      final Map<String, String> userNameMap = {};
      if (clientIds.isNotEmpty) {
        final users = await _supabase
            .from('appuser')
            .select('id, nama_lengkap')
            .inFilter('id', clientIds);
        for (final u in List<Map<String, dynamic>>.from(users)) {
          userNameMap[u['id'] as String] =
              u['nama_lengkap'] as String? ?? 'Klien';
        }
      }

      testimonials = filtered.map((r) {
        final clientId = r['client_id'] as String?;
        final mentorId = r['mentor_id'] as String?;

        final clientBio = clientId != null ? bioMap[clientId] : null;
        final mentorBio = mentorId != null ? bioMap[mentorId] : null;

        final reviewerName = clientBio?['nama_lengkap'] as String? ??
            (clientId != null ? userNameMap[clientId] : null) ??
            'Klien';

        return TestimonialModel(
          reviewerName: reviewerName,
          reviewerFoto: clientBio?['foto_url'] as String?,
          rating: (r['rating'] as num?)?.toInt() ?? 0,
          comment: r['review_text'] as String? ?? '',
          mentorName: mentorBio?['nama_lengkap'] as String? ?? 'Mentor',
        );
      }).toList();
    } on PostgrestException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = 'Gagal memuat testimoni: $e';
    } finally {
      isLoading = false;
    }
  }
}
