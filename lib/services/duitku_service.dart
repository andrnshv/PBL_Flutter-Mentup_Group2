import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

// ================================================================
//  DUITKU SERVICE — MentUp
//  File: lib/services/duitku_service.dart
//
//  Dependency (tambahkan di pubspec.yaml):
//    http: ^1.2.0
//    crypto: ^3.0.3
//
//  Cara pakai:
//    1. Isi merchantCode & apiKey di DuitkuConfig
//    2. Panggil DuitkuService.createInvoice(...) dari PaymentController
//    3. Buka paymentUrl hasil response di WebView
// ================================================================

// ----------------------------------------------------------------
//  KONFIGURASI
//  Ambil nilai dari: https://merchant.duitku.com → Project
// ----------------------------------------------------------------
class DuitkuConfig {
  /// Merchant Code dari dashboard Duitku (contoh: D12345)
  static const String merchantCode = 'DS30773';

  /// API Key dari dashboard Duitku
  static const String apiKey = '4f5ad6b58c27a72ca001ea67828e9692';

  /// true  → Sandbox  (testing)
  /// false → Production (live)
  static const bool isSandbox = true;

  /// Base URL otomatis berdasarkan mode
  static String get baseUrl => isSandbox
      ? 'https://api-sandbox.duitku.com'
      : 'https://api-prod.duitku.com';
}

// ----------------------------------------------------------------
//  MODEL: Response Create Invoice
// ----------------------------------------------------------------
class DuitkuInvoiceResponse {
  final String merchantCode;
  final String reference; // ID unik dari Duitku, simpan di DB
  final String paymentUrl; // buka ini di WebView
  final String statusCode; // '00' = sukses
  final String statusMessage;

  DuitkuInvoiceResponse({
    required this.merchantCode,
    required this.reference,
    required this.paymentUrl,
    required this.statusCode,
    required this.statusMessage,
  });

  factory DuitkuInvoiceResponse.fromJson(Map<String, dynamic> json) {
    return DuitkuInvoiceResponse(
      merchantCode: json['merchantCode'] ?? '',
      reference: json['reference'] ?? '',
      paymentUrl: json['paymentUrl'] ?? '',
      statusCode: json['statusCode'] ?? '',
      statusMessage: json['statusMessage'] ?? '',
    );
  }

  @override
  String toString() => 'DuitkuInvoiceResponse(statusCode: $statusCode, '
      'reference: $reference, paymentUrl: $paymentUrl)';
}

// ----------------------------------------------------------------
//  MODEL: Response Cek Status Transaksi
// ----------------------------------------------------------------
class DuitkuTransactionStatus {
  final String merchantOrderId;
  final String reference;
  final int amount;
  final String statusCode; // '00'=sukses, '01'=pending, '02'=gagal
  final String statusMessage;

  DuitkuTransactionStatus({
    required this.merchantOrderId,
    required this.reference,
    required this.amount,
    required this.statusCode,
    required this.statusMessage,
  });

  factory DuitkuTransactionStatus.fromJson(Map<String, dynamic> json) {
    return DuitkuTransactionStatus(
      merchantOrderId: json['merchantOrderId'] ?? '',
      reference: json['reference'] ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      statusCode: json['statusCode'] ?? '',
      statusMessage: json['statusMessage'] ?? '',
    );
  }

  /// Kembalikan string status yang ramah (untuk update DB)
  String get paymentStatus {
    switch (statusCode) {
      case '00':
        return 'paid';
      case '01':
        return 'pending';
      default:
        return 'failed';
    }
  }

  bool get isSuccess => statusCode == '00';
  bool get isPending => statusCode == '01';
  bool get isFailed => statusCode == '02';
}

// ----------------------------------------------------------------
//  MODEL: Payment Method (opsional, untuk tampilkan pilihan metode)
// ----------------------------------------------------------------
class DuitkuPaymentMethod {
  final String paymentMethod; // kode, contoh: 'VA', 'OV', 'SA'
  final String paymentName; // nama tampil, contoh: 'Virtual Account'
  final String paymentImage; // URL gambar logo
  final int totalFee; // biaya admin dalam Rupiah

  DuitkuPaymentMethod({
    required this.paymentMethod,
    required this.paymentName,
    required this.paymentImage,
    required this.totalFee,
  });

  factory DuitkuPaymentMethod.fromJson(Map<String, dynamic> json) {
    return DuitkuPaymentMethod(
      paymentMethod: json['paymentMethod'] ?? '',
      paymentName: json['paymentName'] ?? '',
      paymentImage: json['paymentImage'] ?? '',
      totalFee: (json['totalFee'] as num?)?.toInt() ?? 0,
    );
  }
}

// ----------------------------------------------------------------
//  DUITKU SERVICE
// ----------------------------------------------------------------
class DuitkuService {
  // ==============================================================
  //  PRIVATE: Generate Timestamp WIB (Jakarta)
  //  Format: "2025-01-15 13:45:00"
  // ==============================================================
  static String _getTimestamp() {
    return DateTime.now()
        .toUtc()
        .add(const Duration(hours: 7)) // UTC+7 WIB
        .toString()
        .substring(0, 19)
        .replaceFirst('T', ' ');
  }

  // ==============================================================
  //  PRIVATE: Generate Signature HMAC-SHA256
  //
  //  Untuk create invoice & get payment method:
  //    HMAC-SHA256(merchantCode + amount + datetime, apiKey)
  //
  //  Untuk check status:
  //    HMAC-SHA256(merchantCode + merchantOrderId + apiKey, apiKey)
  // ==============================================================
  static String _hmacSha256(String stringToSign, String key) {
    final keyBytes = utf8.encode(key);
    final dataBytes = utf8.encode(stringToSign);
    final hmac = Hmac(sha256, keyBytes);
    return hmac.convert(dataBytes).toString(); // hex lowercase
  }

  // ==============================================================
  //  PRIVATE: Build Headers standar Duitku
  // ==============================================================
  static Map<String, String> _buildHeaders({
    required String timestamp,
    required String signature,
  }) {
    return {
      'Content-Type': 'application/json',
      'x-duitku-merchantcode': DuitkuConfig.merchantCode,
      'x-duitku-timestamp': timestamp,
      'x-duitku-signature': signature,
    };
  }

  // ==============================================================
  //  GET PAYMENT METHOD
  //  Ambil daftar metode pembayaran yang tersedia
  //  Panggil ini saat menampilkan pilihan metode ke user
  //
  //  Contoh:
  //    final methods = await DuitkuService.getPaymentMethods(amount: 150000);
  // ==============================================================
  static Future<List<DuitkuPaymentMethod>> getPaymentMethods({
    required int amount,
  }) async {
    final timestamp = _getTimestamp();
    final stringToSign = '${DuitkuConfig.merchantCode}$amount$timestamp';
    final signature = _hmacSha256(stringToSign, DuitkuConfig.apiKey);
    final headers = _buildHeaders(timestamp: timestamp, signature: signature);

    final body = {
      'merchantcode': DuitkuConfig.merchantCode,
      'amount': amount,
      'datetime': timestamp,
      'signature': signature,
    };

    final response = await http.post(
      Uri.parse(
        '${DuitkuConfig.baseUrl}/api/merchant/paymentmethod/getpaymentmethod',
      ),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final list = decoded['paymentFee'] as List<dynamic>? ?? [];
      return list
          .map((e) => DuitkuPaymentMethod.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw DuitkuException(
        code: response.statusCode,
        message: 'getPaymentMethods gagal: ${response.body}',
      );
    }
  }

  // ==============================================================
  //  CREATE INVOICE
  //  Request transaksi pembayaran ke Duitku
  //
  //  Dipanggil saat klien klik "Lanjut Bayar" di booking_page.dart
  //
  //  Contoh:
  //    final result = await DuitkuService.createInvoice(
  //      merchantOrderId: bookingId,
  //      paymentAmount:   150000,
  //      productDetails:  'Sesi Mentoring Flutter - 1 jam',
  //      email:           'klien@email.com',
  //      phoneNumber:     '081234567890',
  //      customerName:    'Budi Santoso',
  //    );
  //    if (result.statusCode == '00') {
  //      // buka result.paymentUrl di WebView
  //    }
  //
  //  Parameter paymentMethod (opsional, kosongkan = klien pilih sendiri):
  //    'VA'  → Virtual Account (semua bank)
  //    'BT'  → BCA Transfer
  //    'M2'  → Mandiri VA
  //    'BV'  → BRI VA
  //    'OV'  → OVO
  //    'SA'  → ShopeePay
  //    'DA'  → DANA
  //    'LF'  → Pegadaian
  //    'FT'  → Alfa Group (Alfamart)
  // ==============================================================
  static Future<DuitkuInvoiceResponse> createInvoice({
    required String merchantOrderId,
    required int paymentAmount,
    required String productDetails,
    required String email,
    required String phoneNumber,
    required String customerName,
    String? paymentMethod, // null = tampilkan semua pilihan di halaman Duitku
    String? returnUrl, // deep link / URL setelah selesai bayar
    String? callbackUrl, // webhook URL notifikasi (harus bisa diakses publik)
    String? firstName,
    String? lastName,
    String? address,
    String? city,
    int expiryPeriod = 60, // menit sampai invoice expired
  }) async {
    final timestamp = _getTimestamp();
    final stringToSign = '${DuitkuConfig.merchantCode}$paymentAmount$timestamp';
    final signature = _hmacSha256(stringToSign, DuitkuConfig.apiKey);
    final headers = _buildHeaders(timestamp: timestamp, signature: signature);

    // Split nama jika firstName tidak diisi
    final nameParts = customerName.trim().split(' ');
    final fName = firstName ?? nameParts.first;
    final lName = lastName ??
        (nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '');

    final body = <String, dynamic>{
      'merchantCode': DuitkuConfig.merchantCode,
      'paymentAmount': paymentAmount,
      'merchantOrderId': merchantOrderId,
      'productDetails': productDetails,
      'additionalParam': '',
      'merchantUserInfo': '',
      'customerVaName': customerName,
      'email': email,
      'phoneNumber': phoneNumber,
      'itemDetails': [
        {
          'name': productDetails,
          'quantity': 1,
          'price': paymentAmount,
        }
      ],
      'customerDetail': {
        'firstName': fName,
        'lastName': lName,
        'email': email,
        'phoneNumber': phoneNumber,
        'billingAddress': {
          'firstName': fName,
          'lastName': lName,
          'address': address ?? 'Indonesia',
          'city': city ?? 'Jakarta',
          'postalCode': '10000',
          'phone': phoneNumber,
          'countryCode': 'ID',
        },
        'shippingAddress': {
          'firstName': fName,
          'lastName': lName,
          'address': address ?? 'Indonesia',
          'city': city ?? 'Jakarta',
          'postalCode': '10000',
          'phone': phoneNumber,
          'countryCode': 'ID',
        },
      },
      'callbackUrl': callbackUrl ?? '',
      'returnUrl': returnUrl ?? '',
      'expiryPeriod': expiryPeriod,
    };

    // Tambahkan paymentMethod hanya jika diisi
    if (paymentMethod != null && paymentMethod.isNotEmpty) {
      body['paymentMethod'] = paymentMethod;
    }

    final response = await http.post(
      Uri.parse('${DuitkuConfig.baseUrl}/api/merchant/createInvoice'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return DuitkuInvoiceResponse.fromJson(decoded);
    } else {
      throw DuitkuException(
        code: response.statusCode,
        message:
            'createInvoice gagal: ${response.statusCode} — ${response.body}',
        raw: response.body,
      );
    }
  }

  // ==============================================================
  //  CHECK TRANSACTION STATUS
  //  Verifikasi status pembayaran setelah user kembali dari Duitku
  //
  //  Contoh:
  //    final status = await DuitkuService.checkTransactionStatus(
  //      merchantOrderId: orderId,
  //    );
  //    if (status.isSuccess) {
  //      // update DB → paid, confirmed
  //    }
  // ==============================================================
  static Future<DuitkuTransactionStatus> checkTransactionStatus({
    required String merchantOrderId,
  }) async {
    final timestamp = _getTimestamp();

    // Signature check status: HMAC-SHA256(merchantCode + merchantOrderId + apiKey)
    final stringToSign =
        '${DuitkuConfig.merchantCode}$merchantOrderId${DuitkuConfig.apiKey}';
    final signature = _hmacSha256(stringToSign, DuitkuConfig.apiKey);
    final headers = _buildHeaders(timestamp: timestamp, signature: signature);

    final body = {
      'merchantCode': DuitkuConfig.merchantCode,
      'merchantOrderId': merchantOrderId,
    };

    final response = await http.post(
      Uri.parse('${DuitkuConfig.baseUrl}/api/merchant/transactionStatus'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return DuitkuTransactionStatus.fromJson(decoded);
    } else {
      throw DuitkuException(
        code: response.statusCode,
        message: 'checkStatus gagal: ${response.statusCode} — ${response.body}',
        raw: response.body,
      );
    }
  }
}

// ----------------------------------------------------------------
//  CUSTOM EXCEPTION
//  Memudahkan catch error spesifik dari Duitku
//
//  Contoh:
//    try {
//      await DuitkuService.createInvoice(...);
//    } on DuitkuException catch (e) {
//      print('Error Duitku: ${e.message}');
//    }
// ----------------------------------------------------------------
class DuitkuException implements Exception {
  final int code;
  final String message;
  final String raw;

  DuitkuException({
    required this.code,
    required this.message,
    this.raw = '',
  });

  @override
  String toString() => 'DuitkuException($code): $message';
}
