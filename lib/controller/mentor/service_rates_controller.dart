import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/mentor/service_rates_model.dart';

class ServiceRatesController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final TextEditingController rateController = TextEditingController();

  // State
  ServiceRateModel? currentRateModel;
  bool isLoading = false;
  String? errorMessage;

  /// Getter tarif saat ini (0 jika belum ada)
  int get currentRate => currentRateModel?.pricePerSession ?? 0;

  /// Ambil tarif mentor yang sedang login dari tabel service_rates
  Future<void> fetchCurrentRate() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      errorMessage = 'User not authenticated.';
      return;
    }

    isLoading = true;
    errorMessage = null;

    try {
      final response = await _supabase
          .from('service_rates')
          .select()
          .eq('mentor_id', userId)
          .maybeSingle();

      if (response != null) {
        currentRateModel = ServiceRateModel.fromJson(response);
      }
    } on PostgrestException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = 'Failed to load rate: $e';
    } finally {
      isLoading = false;
    }
  }

  /// Simpan atau update tarif. Mengembalikan null jika sukses, pesan error jika gagal.
  Future<String?> saveRate() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return 'User not authenticated.';

    final rawText =
        rateController.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
    final newPrice = int.tryParse(rawText);

    if (newPrice == null || newPrice <= 0) {
      return 'Please enter a valid rate greater than 0.';
    }

    isLoading = true;
    errorMessage = null;

    try {
      if (currentRateModel == null) {
        // INSERT — belum punya tarif sama sekali
        final response = await _supabase
            .from('service_rates')
            .insert({'mentor_id': userId, 'price_per_session': newPrice})
            .select()
            .single();
        currentRateModel = ServiceRateModel.fromJson(response);
      } else {
        // UPDATE — sudah punya tarif sebelumnya
        final response = await _supabase
            .from('service_rates')
            .update({'price_per_session': newPrice})
            .eq('id', currentRateModel!.id)
            .select()
            .single();
        currentRateModel = ServiceRateModel.fromJson(response);
      }

      rateController.clear();
      return null; // sukses
    } on PostgrestException catch (e) {
      errorMessage = e.message;
      return e.message;
    } catch (e) {
      errorMessage = 'Failed to save rate: $e';
      return errorMessage;
    } finally {
      isLoading = false;
    }
  }

  void dispose() {
    rateController.dispose();
  }
}