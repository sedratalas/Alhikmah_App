
import 'package:alhekmah_app/model/payment_model.dart';
import 'package:dio/dio.dart';

class PaymentService {
  final Dio dio;

  PaymentService({required this.dio});

  static const String _createPaymentIntentEndpoint = '/stripe/create-payment-intent';

  static const String _confirmPaymentEndpoint = '/stripe/confirm-payment';


  Future<PaymentIntentModel> createPaymentIntent(int amount) async {
    try {
      final response = await dio.post(
        _createPaymentIntentEndpoint,
        queryParameters: {'amount': amount},
      );
      if (response.statusCode == 200) {
        return PaymentIntentModel.fromJson(response.data);
      } else {
        throw Exception('Failed to create payment intent');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Server Error: ${e.response!.data['detail']}');
      } else {
        throw Exception('Failed to connect to the server');
      }
    }
  }


  Future<WalletUpdateModel> confirmPayment(String paymentIntentId) async {
    try {
      final response = await dio.post(
        _confirmPaymentEndpoint,
        queryParameters: {'payment_intent_id': paymentIntentId},
      );
      if (response.statusCode == 200) {
        return WalletUpdateModel.fromJson(response.data);
      } else {
        throw Exception('Failed to confirm payment');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Server Error: ${e.response!.data['detail']}');
      } else {
        throw Exception('Failed to connect to the server');
      }
    }
  }
}