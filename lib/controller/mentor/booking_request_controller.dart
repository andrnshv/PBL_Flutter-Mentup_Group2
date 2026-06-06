import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/mentor/booking_request_model.dart';

class BookingRequestController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ── State ──────────────────────────────────────────────
  List<BookingRequestModel> allRequests = [];
  bool isLoading = false;
  String? errorMessage;

  String searchQuery = '';
  bool isAscending = true;

  // ─────────────────────────────────────────────────────
  // FETCH semua booking milik mentor yang login
  //
  // 2 query sequential (sama seperti BookingDetailController):
  //   1. bookings + appuser + mentor_schedules
  //   2. bio_profil via email → tempelkan ke model
  // ─────────────────────────────────────────────────────
  Future<void> fetchRequests() async {
    final mentorId = _supabase.auth.currentUser?.id;
    if (mentorId == null) {
      errorMessage = 'User not authenticated.';
      return;
    }

    isLoading = true;
    errorMessage = null;

    try {
      // Query 1: bookings + client (appuser) + schedule
      final response = await _supabase
          .from('bookings')
          .select('''
            id,
            booking_status,
            notes,
            created_at,
            session_start_time,
            session_end_time,
            client_address,
            appuser:client_id(
              id,
              nama_lengkap,
              email
            ),
            mentor_schedules:schedule_id(
              available_date,
              start_time,
              end_time
            )
          ''')
          .eq('mentor_id', mentorId)
          .neq('booking_status', 'pending')
          .order('created_at', ascending: false);

      final List<BookingRequestModel> parsed = (response as List)
          .map((e) => BookingRequestModel.fromJson(e as Map<String, dynamic>))
          .toList();

      // Query 2: kumpulkan email unik, fetch bio_profil sekaligus
      final emails = parsed
          .where((b) => b.clientEmail != null && b.clientEmail!.isNotEmpty)
          .map((b) => b.clientEmail!)
          .toSet()
          .toList();

      final Map<String, Map<String, dynamic>> bioMap = {};
      if (emails.isNotEmpty) {
        final bios = await _supabase
            .from('bio_profil')
            .select('email, foto_url, categories(category_name)')
            .inFilter('email', emails);

        for (final bio in List<Map<String, dynamic>>.from(bios)) {
          final email = bio['email'] as String?;
          if (email != null) bioMap[email] = bio;
        }
      }

      // Tempelkan bio ke tiap model
      allRequests = parsed.map((b) {
        final bio = b.clientEmail != null ? bioMap[b.clientEmail!] : null;
        final category = bio?['categories'] as Map<String, dynamic>?;
        return b.withBio(
          fotoUrl: bio?['foto_url'] as String?,
          category: category?['category_name'] as String?,
        );
      }).toList();
    } on PostgrestException catch (e) {
      errorMessage = e.message;
      allRequests = [];
    } catch (e) {
      errorMessage = 'Gagal memuat booking: $e';
      allRequests = [];
    } finally {
      isLoading = false;
    }
  }

  // ─────────────────────────────────────────────────────
  // Filter per tab: 'Pending' | 'Accepted' | 'Rejected'
  // ─────────────────────────────────────────────────────
  List<BookingRequestModel> listFor(String tab) {
    var result = allRequests.where((b) => b.tabGroup == tab).toList();

    // Filter search
    if (searchQuery.isNotEmpty) {
      result = result
          .where((b) =>
              b.clientName.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    // Sort nama
    result.sort((a, b) {
      final cmp = a.clientName.compareTo(b.clientName);
      return isAscending ? cmp : -cmp;
    });

    return result;
  }

  // ─────────────────────────────────────────────────────
  // ACCEPT booking → 'confirmed'
  // ─────────────────────────────────────────────────────
  Future<String?> acceptBooking(String bookingId) async {
    try {
      await _supabase
          .from('bookings')
          .update({'booking_status': 'confirmed'}).eq('id', bookingId);

      _updateLocalStatus(bookingId, 'confirmed');
      return null;
    } on PostgrestException catch (e) {
      return e.message;
    } catch (e) {
      return 'Gagal menerima booking: $e';
    }
  }

  // ─────────────────────────────────────────────────────
  // REJECT booking → 'rejected' + bebaskan slot
  // ─────────────────────────────────────────────────────
  Future<String?> rejectBooking(String bookingId) async {
    try {
      // Ambil schedule_id dulu
      final row = await _supabase
          .from('bookings')
          .select('schedule_id')
          .eq('id', bookingId)
          .maybeSingle();

      await _supabase
          .from('bookings')
          .update({'booking_status': 'rejected'}).eq('id', bookingId);

      // Bebaskan slot
      if (row?['schedule_id'] != null) {
        await _supabase
            .from('mentor_schedules')
            .update({'is_booked': false}).eq('id', row!['schedule_id']);
      }

      _updateLocalStatus(bookingId, 'rejected');
      return null;
    } on PostgrestException catch (e) {
      return e.message;
    } catch (e) {
      return 'Gagal menolak booking: $e';
    }
  }

  // Update state lokal tanpa fetch ulang
  void _updateLocalStatus(String bookingId, String newStatus) {
    final idx = allRequests.indexWhere((b) => b.bookingId == bookingId);
    if (idx == -1) return;
    final old = allRequests[idx];
    allRequests[idx] = old.withBio(
      fotoUrl: old.clientFotoUrl,
      category: old.categoryName,
    );
    // Rebuild dengan status baru via copyWith-like manual
    allRequests[idx] = BookingRequestModel(
      bookingId: old.bookingId,
      bookingStatus: newStatus,
      notes: old.notes,
      createdAt: old.createdAt,
      sessionStartTime: old.sessionStartTime,
      sessionEndTime: old.sessionEndTime,
      clientAddress: old.clientAddress,
      scheduleDate: old.scheduleDate,
      clientId: old.clientId,
      clientName: old.clientName,
      clientEmail: old.clientEmail,
      clientFotoUrl: old.clientFotoUrl,
      categoryName: old.categoryName,
    );
  }
}
