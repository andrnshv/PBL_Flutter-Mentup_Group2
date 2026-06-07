import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/mentor/teaching_proof_model.dart';

// ================================================================
//  TEACHING PROOF CONTROLLER — MentUp
//  File: lib/controller/mentor/teaching_proof_controller.dart
//
//  Tab "Required"  → booking status = 'confirmed'
//  Tab "In Review" → booking status = 'awaiting_verification'
//  Tab "Verified"  → booking status = 'completed'
// ================================================================

class TeachingProofController {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<TeachingProofModel> requiredList = [];
  List<TeachingProofModel> inReviewList = [];
  List<TeachingProofModel> verifiedList = [];

  bool isLoading = false;
  String? errorMessage;

  static const List<Color> _colors = [
    Color(0xFFF5B3CE),
    Color(0xFFA7C7E7),
    Color(0xFFCDB4DB),
    Color(0xFFB5EAD7),
    Color(0xFFFFDAC1),
  ];

  // ─────────────────────────────────────────────────────
  // FETCH
  // ─────────────────────────────────────────────────────
  Future<void> fetchProofs({String searchQuery = ''}) async {
    isLoading = true;
    errorMessage = null;

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        errorMessage = 'User belum login.';
        isLoading = false;
        return;
      }

      final response = await _supabase
          .from('bookings')
          .select('''
            id, booking_status,
            proof_url, session_summary, proof_submitted_at,
            session_start_time, session_end_time,
            mentor_schedules!schedule_id (
              available_date, start_time, end_time
            ),
            appuser:client_id (
              id, nama_lengkap,
              bio_profil ( foto_url, categories ( category_name ) )
            )
          ''')
          .eq('mentor_id', userId)
          .inFilter('booking_status',
              ['confirmed', 'awaiting_verification', 'completed'])
          .order('created_at', ascending: false);

      final list = List<Map<String, dynamic>>.from(response);

      final required = <TeachingProofModel>[];
      final inReview = <TeachingProofModel>[];
      final verified = <TeachingProofModel>[];

      for (int i = 0; i < list.length; i++) {
        final b = list[i];

        // Filter search (berdasarkan nama client)
        final client = b['appuser'] as Map<String, dynamic>? ?? {};
        final clientName = client['nama_lengkap'] as String? ?? '';
        if (searchQuery.isNotEmpty &&
            !clientName.toLowerCase().contains(searchQuery.toLowerCase())) {
          continue;
        }

        final model = TeachingProofModel.fromJson(
          b,
          accentColor: _colors[i % _colors.length],
        );

        switch (model.bookingStatus) {
          case 'confirmed':
            required.add(model);
            break;
          case 'awaiting_verification':
            inReview.add(model);
            break;
          case 'completed':
            verified.add(model);
            break;
        }
      }

      requiredList = required;
      inReviewList = inReview;
      verifiedList = verified;
    } on PostgrestException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = 'Gagal memuat data: $e';
    } finally {
      isLoading = false;
    }
  }

  // ─────────────────────────────────────────────────────
  // SUBMIT PROOF:
  //   1. Upload foto ke Storage bucket 'teaching-proof'
  //   2. Update bookings → awaiting_verification
  // ─────────────────────────────────────────────────────
  Future<String?> submitProof({
    required String bookingId,
    required File imageFile,
    String? summary,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return 'User belum login.';

      // 1. Upload foto ke bucket 'teaching-proof'
      final ext = imageFile.path.split('.').last;
      final fileName =
          'proof_${bookingId}_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final filePath = '$userId/$fileName';

      await _supabase.storage.from('teaching-proof').upload(filePath, imageFile,
          fileOptions: const FileOptions(upsert: true));

      final proofUrl =
          _supabase.storage.from('teaching-proof').getPublicUrl(filePath);

      // 2. Update booking
      await _supabase.from('bookings').update({
        'proof_url': proofUrl,
        'session_summary': summary,
        'proof_submitted_at': DateTime.now().toIso8601String(),
        'booking_status': 'awaiting_verification',
      }).eq('id', bookingId);

      return null; // sukses
    } on PostgrestException catch (e) {
      return e.message;
    } on StorageException catch (e) {
      return 'Gagal upload foto: ${e.message}';
    } catch (e) {
      return 'Error: $e';
    }
  }
}
