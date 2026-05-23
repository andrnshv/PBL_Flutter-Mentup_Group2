import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Ditambahkan untuk tipe data LatLng
import '../../models/client/mentor_search_model.dart';

class MentorSearchController {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<MentorSearchModel> allMentors = [];
  List<MentorSearchModel> filteredMentors = [];
  List<String> categories = ['All'];

  bool isLoading = false;
  String? errorMessage;

  String searchQuery = '';
  String selectedCategory = 'All';
  int maxPrice = 500000;
  String selectedAlamat = 'All';

  final TextEditingController searchTextController = TextEditingController();

  // Koordinat fallback dipindah ke sini agar Model kamu tetap bersih
  static const Map<String, LatLng> cityCoordinates = {
    'Malang City': LatLng(-7.9653, 112.6214),
    'Malang': LatLng(-7.9653, 112.6214),
    'Surabaya': LatLng(-7.2575, 112.7521),
    'Jakarta': LatLng(-6.2088, 106.8456),
    'Bandung': LatLng(-6.9175, 107.6191),
    'Yogyakarta': LatLng(-7.7956, 110.3695),
  };

  Future<void> fetchCategories() async {
    try {
      final response = await _supabase
          .from('categories')
          .select('category_name')
          .order('category_name');

      categories = [
        'All',
        ...response.map<String>((e) => e['category_name'] as String),
      ];
    } on PostgrestException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = 'Failed to load categories: $e';
    }
  }

  Future<void> fetchMentors() async {
    isLoading = true;
    errorMessage = null;

    try {
      final response = await _supabase.from('appuser').select('''
            id,
            nama_lengkap,
            bio_profil!inner(
              nama_lengkap,
              foto_url,
              bio,
              alamat,
              categories(category_name)
            ),
            service_rates(price_per_session)
          ''').eq('role', 'mentor');

      allMentors = (response as List)
          .map((e) => MentorSearchModel.fromJson(e as Map<String, dynamic>))
          .toList();

      applyFilter();
    } on PostgrestException catch (e) {
      errorMessage = e.message;
      filteredMentors = [];
    } catch (e) {
      errorMessage = 'Failed to load mentors: $e';
      filteredMentors = [];
    } finally {
      isLoading = false;
    }
  }

  void applyFilter() {
    filteredMentors = allMentors.where((mentor) {
      final matchSearch =
          mentor.namaLengkap.toLowerCase().contains(searchQuery.toLowerCase());

      final matchCategory = selectedCategory == 'All' ||
          (mentor.categoryName?.toLowerCase() ==
              selectedCategory.toLowerCase());

      final price = mentor.pricePerSession ?? 0;
      final matchPrice = price == 0 || price <= maxPrice;

      final matchAlamat = selectedAlamat == 'All' ||
          (mentor.alamat
                  ?.toLowerCase()
                  .contains(selectedAlamat.toLowerCase()) ??
              false);

      return matchSearch && matchCategory && matchPrice && matchAlamat;
    }).toList();
  }

  /// Ekstrak nama kota dari alamat panjang.
  static String _extractCity(String alamat) {
    final parts = alamat.split(',');
    return parts.last.trim();
  }

  List<String> get uniqueAlamatList {
    final set = <String>{};
    for (final m in allMentors) {
      if (m.alamat != null && m.alamat!.isNotEmpty) {
        set.add(_extractCity(m.alamat!));
      }
    }
    return ['All', ...set.toList()..sort()];
  }

  void dispose() {
    searchTextController.dispose();
  }
}
