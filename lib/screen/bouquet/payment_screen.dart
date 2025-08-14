// payment_screen.dart
import 'package:alhekmah_app/core/utils/color_manager.dart';
import 'package:alhekmah_app/service/payment_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../core/app_service.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;
  String? _paymentIntentClientSecret;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }


  Future<void> _processPayment() async {
    setState(() {
      _isLoading = true;
    });

    final amountText = _amountController.text;
    final int? amount = int.tryParse(amountText);

    if (amount == null || amount <= 0) {
      _showSnackbar('الرجاء إدخال مبلغ صحيح.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // 1. إنشاء نية الدفع (Payment Intent) على الخادم
      print('Sending amount to server: $amount');
      final paymentIntentData = await AppServices.paymentService.createPaymentIntent(amount);

      // تأكد من أن الـ client_secret ليس فارغًا
      if (paymentIntentData.clientSecret == null) {
        throw Exception('Failed to get client secret from server.');
      }

      _paymentIntentClientSecret = paymentIntentData.clientSecret;
      print('Received client_secret: $_paymentIntentClientSecret');


      // 2. تهيئة شاشة الدفع
      print('Initializing Payment Sheet...');
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: _paymentIntentClientSecret!,
          merchantDisplayName: 'Alhekmah App',
          style: ThemeMode.light,
        ),
      );
      print('Payment Sheet initialized successfully.');

      // 3. عرض شاشة الدفع ومعالجة النتيجة
      try {
        print('Presenting Payment Sheet...');
        await Stripe.instance.presentPaymentSheet();
        print('Payment completed successfully!');

        // إذا وصل الكود إلى هنا، فهذا يعني أن الدفع اكتمل بنجاح
        // قم باستدعاء الدالة التي تؤكد الدفع على الخادم
        await _confirmPayment(_paymentIntentClientSecret!);
        _showSnackbar('تم شحن المحفظة بنجاح!');

      } on Exception catch (e) {
        if (e is StripeException) {
          if (e.error.code == FailureCode.Canceled) {
            print('Payment canceled by user.');
            _showSnackbar('تم إلغاء عملية الدفع من قبل المستخدم.');
          } else {
            print('Stripe Payment failed: ${e.error.localizedMessage}');
            _showSnackbar('فشل الدفع: ${e.error.localizedMessage}');
          }
        } else {
          print('An unexpected error occurred during payment: ${e.toString()}');
          _showSnackbar('حدث خطأ غير متوقع أثناء الدفع: ${e.toString()}');
        }
      }

    } catch (e) {
      print('Error creating payment intent: ${e.toString()}');
      _showSnackbar('حدث خطأ في إنشاء نية الدفع: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmPayment(String paymentIntentId) async {
    try {
      final response = await AppServices.paymentService.confirmPayment(paymentIntentId);
      _showSnackbar(response.detail);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackbar('خطأ في تأكيد الدفع: ${e.toString()}');
    }
  }

  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('شحن المحفظة'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'أدخل المبلغ',
                hintText: 'مثال: 50',
                border: OutlineInputBorder(),
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text(
                'شحن',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}