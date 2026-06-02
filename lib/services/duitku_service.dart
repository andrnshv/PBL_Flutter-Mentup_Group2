import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

// ================================================================
//  DUITKU SERVICE — FIXED + DEBUG VERSION
// ================================================================

class DuitkuConfig {
  static const String merchantCode = 'DS30773';
  static const String apiKey = '4f5ad6b58c27a72ca001ea67828e9692';

  static const bool isSandbox = true;

  static String get baseUrl =>
      isSandbox ? 'https://api-sandbox.duitku.com' : 'https://api-prod.duitku.com';
}

// ================================================================
// MODELS
// ================================================================
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
      amount: int.tryParse(json['amount'].toString()) ?? 0,
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
}

// ================================================================
// SERVICE
// ================================================================
class DuitkuService {

  // ================================================================
  // TIMESTAMP
  // ================================================================
  static String _getTimestamp() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // ================================================================
  // SHA256 (CREATE INVOICE HEADER SIGNATURE)
  // ================================================================
  static String _generateCreateSignature({
    required String merchantCode,
    required String timestamp,
    required String apiKey,
  }) {
    final raw = '$merchantCode$timestamp$apiKey';

    print('\n===== CREATE SIGNATURE DEBUG =====');
    print('RAW: $raw');

    final digest = sha256.convert(utf8.encode(raw));

    print('SHA256: ${digest.toString()}');
    print('=================================\n');

    return digest.toString();
  }

  // ================================================================
  // MD5 (TRANSACTION STATUS SIGNATURE - FIX)
  // ================================================================
  static String _generateStatusSignature({
    required String merchantCode,
    required String merchantOrderId,
    required String apiKey,
  }) {
    final raw = '$merchantCode$merchantOrderId$apiKey';

    print('\n===== STATUS SIGNATURE DEBUG =====');
    print('RAW: $raw');

    final digest = md5.convert(utf8.encode(raw));

    print('MD5: ${digest.toString()}');
    print('=================================\n');

    return digest.toString();
  }

  // ================================================================
  // CREATE INVOICE
  // ================================================================
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

    final signature = _generateCreateSignature(
      merchantCode: DuitkuConfig.merchantCode,
      timestamp: timestamp,
      apiKey: DuitkuConfig.apiKey,
    );

    final headers = {
      'Content-Type': 'application/json',
      'x-duitku-signature': signature,
      'x-duitku-timestamp': timestamp,
      'x-duitku-merchantcode': DuitkuConfig.merchantCode,
    };

    final body = {
      'paymentAmount': paymentAmount,
      'merchantOrderId': merchantOrderId,
      'productDetails': productDetails,
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
        'firstName': customerName.split(' ').first,
        'lastName': '',
        'email': email,
        'phoneNumber': phoneNumber,
      },
      'callbackUrl': callbackUrl ?? '',
      'returnUrl': returnUrl ?? '',
      'expiryPeriod': expiryPeriod,
    };

    print('\n===== CREATE INVOICE REQUEST =====');
    print('URL: ${DuitkuConfig.baseUrl}/api/merchant/createInvoice');
    print('HEADERS: $headers');
    print('BODY: ${jsonEncode(body)}');
    print('=================================\n');

    final response = await http.post(
      Uri.parse('${DuitkuConfig.baseUrl}/api/merchant/createInvoice'),
      headers: headers,
      body: jsonEncode(body),
    );

    print('\n===== CREATE INVOICE RESPONSE =====');
    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');
    print('==================================\n');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return DuitkuInvoiceResponse.fromJson(decoded);
    }

    throw Exception('CREATE ERROR ${response.statusCode}: ${response.body}');
  }

  // ================================================================
  // CHECK TRANSACTION STATUS (FIXED)
  // ================================================================
  static Future<DuitkuTransactionStatus> checkTransactionStatus({
    required String merchantOrderId,
  }) async {

    final signature = _generateStatusSignature(
      merchantCode: DuitkuConfig.merchantCode,
      merchantOrderId: merchantOrderId,
      apiKey: DuitkuConfig.apiKey,
    );

    final body = {
      'merchantCode': DuitkuConfig.merchantCode,
      'merchantOrderId': merchantOrderId,
      'signature': signature,
    };

    print('\n===== STATUS REQUEST =====');
    print('BODY: ${jsonEncode(body)}');
    print('=========================\n');

    final response = await http.post(
      Uri.parse('${DuitkuConfig.baseUrl}/api/merchant/transactionStatus'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    print('\n===== STATUS RESPONSE =====');
    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');
    print('==========================\n');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return DuitkuTransactionStatus.fromJson(decoded);
    }

    throw Exception('STATUS ERROR ${response.statusCode}: ${response.body}');
  }
}

// ================================================================
// EXCEPTION
// ================================================================
class DuitkuException implements Exception {
  final int code;
  final String message;

  DuitkuException({required this.code, required this.message});

  @override
  String toString() => 'DuitkuException($code): $message';
}