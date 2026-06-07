import 'package:flutter/material.dart';

// ================================================================
//  TEACHING PROOF MODEL — MentUp
//  File: lib/models/mentor/teaching_proof_model.dart
//
//  Model untuk data Teaching Proof yang ditampilkan di halaman
//  TeachingProofPage (sisi mentor).
//
//  Sumber: tabel bookings JOIN mentor_schedules + appuser + bio_profil
//
//  Status mapping:
//    confirmed             → Tab "Required"  (belum upload bukti)
//    awaiting_verification → Tab "In Review" (menunggu client verify)
//    completed             → Tab "Verified"  (client sudah verify)
// ================================================================

class TeachingProofModel {
  // ── Dari bookings ──────────────────────────────────────
  final String bookingId;
  final String bookingStatus; // confirmed / awaiting_verification / completed
  final String? proofUrl; // URL foto bukti mengajar (Supabase Storage)
  final String? sessionSummary; // catatan sesi dari mentor
  final String? proofSubmittedAt; // kapan proof disubmit

  // ── Waktu sesi ─────────────────────────────────────────
  final String dateLabel; // "12 Mei 2026"
  final String timeLabel; // "09:00 - 11:00" (booking client)

  // ── Dari appuser (client) ──────────────────────────────
  final String clientId;
  final String clientName; // nama_lengkap client
  final String? clientPhotoUrl; // foto_url dari bio_profil client

  // ── Dari bio_profil (mentor kategori) ─────────────────
  final String categoryName; // kategori mentor

  // ── UI ────────────────────────────────────────────────
  final Color accentColor; // warna aksen kartu (cycling)

  const TeachingProofModel({
    required this.bookingId,
    required this.bookingStatus,
    required this.clientId,
    required this.clientName,
    required this.categoryName,
    required this.dateLabel,
    required this.timeLabel,
    required this.accentColor,
    this.proofUrl,
    this.sessionSummary,
    this.proofSubmittedAt,
    this.clientPhotoUrl,
  });

  // ─────────────────────────────────────────────────────
  factory TeachingProofModel.fromJson(
    Map<String, dynamic> json, {
    required Color accentColor,
  }) {
    // bookings → mentor_schedules (via FK schedule_id)
    final schedule = json['mentor_schedules'] as Map<String, dynamic>? ?? {};

    // bookings → appuser (client via FK client_id)
    final client = json['appuser'] as Map<String, dynamic>? ?? {};

    // appuser → bio_profil
    final rawBio = client['bio_profil'];
    Map<String, dynamic> bio = {};
    if (rawBio is List && rawBio.isNotEmpty) {
      bio = rawBio.first as Map<String, dynamic>;
    } else if (rawBio is Map) {
      bio = rawBio as Map<String, dynamic>;
    }

    // bio_profil → categories
    final category = bio['categories'] as Map<String, dynamic>?;

    // Jam sesi: pakai session_start/end (booking client),
    // fallback ke slot mentor (start_time/end_time schedule)
    final sessionStart = json['session_start_time'] as String?;
    final sessionEnd = json['session_end_time'] as String?;
    final slotStart = schedule['start_time'] as String?;
    final slotEnd = schedule['end_time'] as String?;

    return TeachingProofModel(
      bookingId: json['id'] as String,
      bookingStatus: json['booking_status'] as String? ?? '',
      proofUrl: json['proof_url'] as String?,
      sessionSummary: json['session_summary'] as String?,
      proofSubmittedAt: json['proof_submitted_at'] as String?,
      dateLabel: _fmtDate(schedule['available_date'] as String?),
      timeLabel: _buildTimeLabel(
        sessionStart ?? slotStart,
        sessionEnd ?? slotEnd,
      ),
      clientId: client['id'] as String? ?? '',
      clientName: client['nama_lengkap'] as String? ?? 'Client',
      clientPhotoUrl: bio['foto_url'] as String?,
      categoryName: category?['category_name'] as String? ?? 'Mentor',
      accentColor: accentColor,
    );
  }

  // ─────────────────────────────────────────────────────
  // Getters
  // ─────────────────────────────────────────────────────

  /// Inisial nama client (untuk avatar fallback)
  String get clientInitial =>
      clientName.isNotEmpty ? clientName[0].toUpperCase() : '?';

  /// Apakah sudah ada proof yang diupload
  bool get hasProof => proofUrl != null && proofUrl!.isNotEmpty;

  /// Apakah sudah ada catatan sesi
  bool get hasSummary => sessionSummary != null && sessionSummary!.isNotEmpty;

  /// Label tab berdasarkan status
  String get tabLabel {
    switch (bookingStatus) {
      case 'confirmed':
        return 'Required';
      case 'awaiting_verification':
        return 'In Review';
      case 'completed':
        return 'Verified';
      default:
        return bookingStatus;
    }
  }

  /// Label status untuk chip di kartu
  String get statusChipLabel {
    switch (bookingStatus) {
      case 'confirmed':
        return 'Pending Proof';
      case 'awaiting_verification':
        return 'In Review';
      case 'completed':
        return 'Completed';
      default:
        return bookingStatus;
    }
  }

  /// Warna chip status
  Color get statusChipColor {
    switch (bookingStatus) {
      case 'confirmed':
        return const Color(0xFFF5B3CE);
      case 'awaiting_verification':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // ─────────────────────────────────────────────────────
  // Static helpers
  // ─────────────────────────────────────────────────────

  static String _fmtDate(String? raw) {
    if (raw == null) return '-';
    try {
      final dt = DateTime.parse(raw);
      const months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  static String _buildTimeLabel(String? start, String? end) {
    final s = _norm(start);
    final e = _norm(end);
    if (s.isEmpty) return '-';
    return e.isEmpty ? s : '$s - $e';
  }

  static String _norm(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final p = raw.split(':');
    if (p.length < 2) return raw;
    return '${p[0].padLeft(2, '0')}:${p[1].padLeft(2, '0')}';
  }
}
