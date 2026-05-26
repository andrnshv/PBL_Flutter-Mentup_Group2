import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

// ================================================================
//  DUITKU SERVICE — MentUp
//  File: lib/services/duitku_service.dart
//
//  Sesuai spesifikasi resmi Duitku POP API:
//  - Timestamp: milliseconds since epoch (string)
//  - Signature: SHA256(merchantCode + timestamp + apiKey) hex lowercase
//  - Headers: x-duitku-signature, x-duitku-timestamp, x-duitku-merchantcode
//
//  Dependency:
//    http: ^1.2.0
//    crypto: ^3.0.3
// ================================================================

// ----------------------------------------------------------------
//  KONFIGURASI — isi dengan credential dari dashboard Duitku
// ----------------------------------------------------------------
class DuitkuConfig {
  /// Merchant Code dari dashboard Duitku (contoh: D12345)
  static const String merchantCode = 'DS30773';

  /// API Key dari dashboard Duitku
  static const String apiKey = '4f5ad6b58c27a72ca001ea67828e9692';

  /// true  → Sandbox (testing)
  /// false → Production (live)
  static const bool isSandbox = true;

  /// Base URL otomatis
  static String get baseUrl => isSandbox
      ? 'https://api-sandbox.duitku.com'
      : 'https://api-prod.duitku.com';
}

// ----------------------------------------------------------------
//  RESPONSE MODELS
// ----------------------------------------------------------------
class DuitkuInvoiceResponse {
  final String merchantCode;
  final String reference;
  final String paymentUrl;
  final String statusCode;
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
}

class DuitkuTransactionStatus {
  final String merchantOrderId;
  final String reference;
  final int amount;
  final String statusCode;
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
//  DUITKU SERVICE
// ----------------------------------------------------------------
class DuitkuService {
  /// Timestamp dalam milliseconds sejak epoch (sesuai spesifikasi Duitku)
  static String _getTimestamp() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Signature: SHA256(merchantCode + timestamp + apiKey)
  /// HASIL: hex lowercase, BUKAN HMAC, BUKAN base64
  static String _generateSignature({
    required String merchantCode,
    required String timestamp,
    required String apiKey,
  }) {
    final stringToSign = '$merchantCode$timestamp$apiKey';
    final bytes = utf8.encode(stringToSign);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Headers standar untuk Duitku POP API
  static Map<String, String> _buildHeaders(String timestamp, String signature) {
    return {
      'Content-Type': 'application/json',
      'x-duitku-signature': signature,
      'x-duitku-timestamp': timestamp,
      'x-duitku-merchantcode': DuitkuConfig.merchantCode,
    };
  }

  // ==============================================================
  //  CREATE INVOICE
  // ==============================================================
  static Future<DuitkuInvoiceResponse> createInvoice({
    required String merchantOrderId,
    required int paymentAmount,
    required String productDetails,
    required String email,
    required String phoneNumber,
    required String customerName,
    String? returnUrl,
    String? callbackUrl,
    int expiryPeriod = 60,
  }) async {
    final timestamp = _getTimestamp();
    final signature = _generateSignature(
      merchantCode: DuitkuConfig.merchantCode,
      timestamp: timestamp,
      apiKey: DuitkuConfig.apiKey,
    );
    final headers = _buildHeaders(timestamp, signature);

    // Split nama jadi firstName + lastName
    final nameParts = customerName.trim().split(' ');
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final body = <String, dynamic>{
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
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phoneNumber,
      },
      'callbackUrl': callbackUrl ?? '',
      'returnUrl': returnUrl ?? '',
      'expiryPeriod': expiryPeriod,
    };

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
  // ==============================================================
  static Future<DuitkuTransactionStatus> checkTransactionStatus({
    required String merchantOrderId,
  }) async {
    final timestamp = _getTimestamp();
    final signature = _generateSignature(
      merchantCode: DuitkuConfig.merchantCode,
      timestamp: timestamp,
      apiKey: DuitkuConfig.apiKey,
    );
    final headers = _buildHeaders(timestamp, signature);

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
