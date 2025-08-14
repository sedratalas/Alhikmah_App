// payment_model.dart
import 'dart:convert';

// PaymentIntentModel
class PaymentIntentModel {
  final String clientSecret;
  final int amount;

  PaymentIntentModel({
    required this.clientSecret,
    required this.amount,
  });

  factory PaymentIntentModel.fromJson(Map<String, dynamic> json) {
    return PaymentIntentModel(
      clientSecret: json['client_secret'] as String,
      amount: json['amount'] as int,
    );
  }
}

// WalletUpdateModel
class WalletUpdateModel {
  final String detail;

  WalletUpdateModel({required this.detail});

  factory WalletUpdateModel.fromJson(Map<String, dynamic> json) {
    return WalletUpdateModel(
      detail: json['detail'] as String,
    );
  }
}