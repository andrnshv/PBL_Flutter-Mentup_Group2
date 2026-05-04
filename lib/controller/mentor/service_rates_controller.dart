import 'package:flutter/material.dart';

class ServiceRatesController {
  final TextEditingController rateController = TextEditingController();
  
  // Data State (Simulasi)
  double currentRate = 0;
  double platformFee = 0;
  double netIncome = 0;

  // Logika Perhitungan
  void calculateEarnings(String value) {
    if (value.isEmpty) {
      currentRate = 0;
    } else {
      // Membersihkan titik/karakter non-angka jika ada
      currentRate = double.tryParse(value.replaceAll('.', '')) ?? 0;
    }
    
    // Simulasi potongan platform 10%
    platformFee = currentRate * 0.10;
    netIncome = currentRate - platformFee;
  }

  void dispose() {
    rateController.dispose();
  }
}