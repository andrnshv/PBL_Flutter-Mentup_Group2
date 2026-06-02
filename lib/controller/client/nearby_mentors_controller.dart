import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

// ================================================================
//  NEARBY MENTORS CONTROLLER — MentUp
//  File: lib/controller/client/nearby_mentors_controller.dart
//
//  Menampilkan mentor TERDEKAT dengan lokasi client.
//
//  CATATAN: untuk TES, GPS sementara di-bypass (langsung Malang).
//  Setelah map muncul, baca instruksi di bawah _getClientLocation
//  untuk mengaktifkan GPS asli kembali.
// ================================================================

class NearbyMentorModel {
  final String userId;
  final String namaLengkap;
  final String? categoryName;
  final String? alamat;
  final double latitude;
  final double longitude;
  final double distanceKm;

  const NearbyMentorModel({
    required this.userId,
    required this.namaLengkap,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    this.categoryName,
    this.alamat,
  });
}

class NearbyMentorsController {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<NearbyMentorModel> nearbyMentors = [];
  Set<Marker> markers = {};
  LatLng? clientLocation;
  bool isLoading = false;
  String? errorMessage;

  // Radius pencarian (km)
  static const double radiusKm = 50.0;

  // Fallback / lokasi default (Malang)
  static const LatLng _fallbackCenter = LatLng(-7.9653, 112.6214);

  // ─────────────────────────────────────────────────────
  //  Ambil lokasi client
  //
  //  >>> MODE TES: GPS DI-BYPASS, LANGSUNG PAKAI MALANG <<<
  //  Kalau map sudah muncul dengan ini, berarti masalah di GPS.
  //  Untuk mengaktifkan GPS asli: HAPUS 2 baris bertanda (TES)
  //  di bawah, supaya kode di bawahnya jalan.
  // ─────────────────────────────────────────────────────
  Future<LatLng> _getClientLocation() async {
    // ===== (TES) BYPASS GPS — hapus 2 baris ini untuk pakai GPS asli =====
    debugPrint('[NEARBY] BYPASS GPS - pakai Malang langsung');
    return _fallbackCenter;
    // =====================================================================

    // ignore: dead_code
    try {
      debugPrint('[NEARBY] cek service lokasi...');
      final serviceEnabled = await Geolocator.isLocationServiceEnabled()
          .timeout(const Duration(seconds: 5), onTimeout: () => false);
      debugPrint('[NEARBY] service lokasi aktif = $serviceEnabled');
      if (!serviceEnabled) return _fallbackCenter;

      debugPrint('[NEARBY] cek izin lokasi...');
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('[NEARBY] izin saat ini = $permission');
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        debugPrint('[NEARBY] izin setelah request = $permission');
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return _fallbackCenter;
      }

      debugPrint('[NEARBY] ambil getCurrentPosition...');
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      ).timeout(
        const Duration(seconds: 8),
        onTimeout: () async {
          final last = await Geolocator.getLastKnownPosition();
          if (last != null) return last;
          throw Exception('GPS timeout');
        },
      );
      return LatLng(pos.latitude, pos.longitude);
    } catch (e) {
      debugPrint('[NEARBY] _getClientLocation error → fallback: $e');
      return _fallbackCenter;
    }
  }

  // ─────────────────────────────────────────────────────
  //  Load mentor terdekat
  // ─────────────────────────────────────────────────────
  Future<void> fetchNearbyMentors({
    Function(String mentorId)? onMarkerTap,
  }) async {
    isLoading = true;
    errorMessage = null;

    try {
      debugPrint('[NEARBY] ambil lokasi client...');
      clientLocation = await _getClientLocation();
      debugPrint('[NEARBY] lokasi client = $clientLocation');

      debugPrint('[NEARBY] query mentor dari Supabase...');
      final response = await _supabase.from('appuser').select('''
            id,
            bio_profil!inner ( nama_lengkap, alamat, categories(category_name) )
          ''').eq('role', 'mentor');

      final list = List<Map<String, dynamic>>.from(response);
      debugPrint('[NEARBY] jumlah mentor dari DB = ${list.length}');

      final result = <NearbyMentorModel>[];
      final tempMarkers = <Marker>{};

      for (final row in list) {
        final bio = row['bio_profil'];
        final bioMap = bio is List
            ? (bio.isNotEmpty ? bio.first as Map<String, dynamic> : null)
            : bio as Map<String, dynamic>?;
        if (bioMap == null) continue;

        final alamat = bioMap['alamat'] as String?;
        if (alamat == null || alamat.isEmpty) {
          debugPrint('[NEARBY] mentor tanpa alamat, dilewati');
          continue;
        }

        final namaLengkap = bioMap['nama_lengkap'] as String? ?? 'Mentor';
        final category = (bioMap['categories']
            as Map<String, dynamic>?)?['category_name'] as String?;

        try {
          debugPrint('[NEARBY] geocode alamat: "$alamat"');
          final locations = await locationFromAddress(alamat).timeout(
            const Duration(seconds: 6),
            onTimeout: () => <Location>[],
          );
          if (locations.isEmpty) {
            debugPrint('[NEARBY] geocode kosong untuk "$alamat"');
            continue;
          }

          final loc = locations.first;
          final distanceMeters = Geolocator.distanceBetween(
            clientLocation!.latitude,
            clientLocation!.longitude,
            loc.latitude,
            loc.longitude,
          );
          final distanceKm = distanceMeters / 1000.0;
          debugPrint(
              '[NEARBY] $namaLengkap jarak = ${distanceKm.toStringAsFixed(1)} km');

          if (distanceKm > radiusKm) {
            debugPrint('[NEARBY] $namaLengkap di luar radius, dilewati');
            continue;
          }

          final mentorId = row['id'] as String;

          result.add(NearbyMentorModel(
            userId: mentorId,
            namaLengkap: namaLengkap,
            categoryName: category,
            alamat: alamat,
            latitude: loc.latitude,
            longitude: loc.longitude,
            distanceKm: distanceKm,
          ));

          tempMarkers.add(
            Marker(
              markerId: MarkerId(mentorId),
              position: LatLng(loc.latitude, loc.longitude),
              infoWindow: InfoWindow(
                title: namaLengkap,
                snippet:
                    '${category ?? 'Mentor'} • ${distanceKm.toStringAsFixed(1)} km',
                onTap: () => onMarkerTap?.call(mentorId),
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueViolet),
            ),
          );
        } catch (e) {
          debugPrint('[NEARBY] gagal geocode $namaLengkap: $e');
        }
      }

      result.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      nearbyMentors = result;
      markers = tempMarkers;
      debugPrint('[NEARBY] SELESAI. mentor dalam radius = ${result.length}');
    } on PostgrestException catch (e) {
      debugPrint('[NEARBY] PostgrestException: ${e.message}');
      errorMessage = e.message;
    } catch (e) {
      debugPrint('[NEARBY] ERROR: $e');
      errorMessage = 'Gagal memuat mentor terdekat: $e';
    } finally {
      isLoading = false;
    }
  }

  int get nearbyCount => nearbyMentors.length;
  LatLng get cameraCenter => clientLocation ?? _fallbackCenter;
}
