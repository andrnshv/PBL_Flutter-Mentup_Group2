class PaymentModel {
  final String id;
  final String bookingId;
  final int amount;
  final String paymentStatus;
  final String? paymentMethod;
  final String? transactionId;
  final String? merchantOrderId;
  final String? reference;
  final String? paymentUrl;

  PaymentModel({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.paymentStatus,
    this.paymentMethod,
    this.transactionId,
    this.merchantOrderId,
    this.reference,
    this.paymentUrl,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      bookingId: json['booking_id'],
      amount: json['amount'] ?? 0,
      paymentStatus: json['payment_status'] ?? 'pending',
      paymentMethod: json['payment_method'],
      transactionId: json['transaction_id'],
      merchantOrderId: json['merchant_order_id'],
      reference: json['reference'],
      paymentUrl: json['payment_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'amount': amount,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'transaction_id': transactionId,
      'merchant_order_id': merchantOrderId,
      'reference': reference,
      'payment_url': paymentUrl,
    };
  }
}
