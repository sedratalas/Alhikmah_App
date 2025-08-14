
import 'package:alhekmah_app/model/standard_hadith_model.dart';
import 'package:alhekmah_app/screen/all_books/bloc/all_book_bloc.dart';
import 'package:alhekmah_app/screen/hadeth_recitation/bloc/hadith_bloc.dart';
import 'package:alhekmah_app/screen/login/bloc/login_bloc.dart';
import 'package:alhekmah_app/screen/sign_up/bloc/signup_bloc.dart';
import 'package:alhekmah_app/service/book_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';

import 'config/observar.dart';
import 'core/app_service.dart';
import 'model/hadith_model.dart';
import 'model/standard_remote_book.dart';
import 'model/token_model.dart';
import 'repository/book_repository.dart';
import 'screen/ahadith/ahadith_screen.dart';
import 'screen/all_books/all_books_screen.dart';
import 'screen/bouquet/bouquet_screen.dart';
import 'screen/hadeth_recitation/hadeth_recitation_screen.dart';
import 'screen/sign_up/signup_step1_screen.dart';
import 'screen/sign_up/signup_step2_screen.dart';
import 'screen/splash/splash_screen.dart';
import 'screen/widget/bloc/profile_bloc.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = MyBlocObserver();
  Stripe.publishableKey = "pk_test_51PcMXuK9NSOyCAsqltlmEPk7QnS0xEtuDfXEcUcFIv5hhV5nQ39m3aSODSUD9dd1U7U0UX8v2iDukRX7LLtTtThx00ylCzUDZn";
  await Stripe.instance.applySettings();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);

  Hive.registerAdapter(TokenResponseModelAdapter());
  Hive.registerAdapter(HadithAdapter());
  Hive.registerAdapter(RemotBookAdapter());

  await AppServices.init();

  final tokenBox = Hive.box('tokenBox');
  final accessToken = tokenBox.get('accessToken');
print(accessToken);

  Widget initialScreen;
  if (accessToken != null) {
    initialScreen = const AllBooksScreen();
  } else {
    initialScreen = SplashScreen();
  }

  runApp(MyApp(initialScreen: initialScreen));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SignupBloc>(
            create: (_) => SignupBloc(authenticationService: AppServices.authenticationService)
        ),
        BlocProvider<LoginBloc>(
            create: (_) => LoginBloc(authenticationService: AppServices.authenticationService)
        ),
        BlocProvider<AllBookBloc>(
          create: (_) => AllBookBloc(bookRepository: AppServices.bookRepository)..add(FetchAllBooks()),
        ),
        BlocProvider<ProfileBloc>(
          create: (_) => ProfileBloc(profileRepository: AppServices.profileRepository),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: initialScreen,
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:dio/dio.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   Stripe.publishableKey = "pk_test_51PcMXuK9NSOyCAsqltlmEPk7QnS0xEtuDfXEcUcFIv5hhV5nQ39m3aSODSUD9dd1U7U0UX8v2iDukRX7LLtTtThx00ylCzUDZn"; // TEST MODE
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Stripe Test Cards',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: StripeTestPage(),
//     );
//   }
// }
//
// class StripeTestPage extends StatelessWidget {
//   final Dio dio = Dio(BaseOptions(baseUrl: "https://alhekmah-server-side.onrender.com/"));
//
//   final List<Map<String, String>> testCards = [
//     {
//       "label": "✅ Success",
//       "card": "4242 4242 4242 4242",
//       "desc": "Any expiry, any CVC",
//     },
//     {
//       "label": "🔐 3D Secure (Authentication)",
//       "card": "4000 0027 6000 3184",
//       "desc": "Triggers 3D Secure challenge",
//     },
//     {
//       "label": "❌ Declined",
//       "card": "4000 0000 0000 9995",
//       "desc": "Always declined",
//     },
//     {
//       "label": "💳 Incorrect CVC",
//       "card": "4000 0000 0000 0101",
//       "desc": "CVC check fails",
//     },
//   ];
//
//   Future<String> createPaymentIntent(int amount) async {
//     final response = await dio.post(
//       "stripe/create-payment-intent",
//       data: {"amount": amount},
//       options: Options(
//           headers: {
//             "Content-Type": "application/json",
//             "Authorization": "Bearer "
//           }
//       ),
//     );
//     return response.data["client_secret"];
//   }
//
//   Future<void> startPaymentFlow(BuildContext context, String scenario) async {
//     try {
//       final clientSecret = await createPaymentIntent(10); // $10 USD test
//
//       await Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: SetupPaymentSheetParameters(
//           paymentIntentClientSecret: clientSecret,
//           merchantDisplayName: "Test Merchant",
//           style: ThemeMode.system,
//           //testEnv: true,
//         ),
//       );
//
//       await Stripe.instance.presentPaymentSheet();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("$scenario payment succeeded")),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("$scenario payment failed: $e")),
//       );
//     }
//   }
//
//   void showCardInfo(BuildContext context, String label, String card, String desc) {
//     showModalBottomSheet(
//       context: context,
//       builder: (_) => Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Wrap(
//           children: [
//             Text(label, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             SizedBox(height: 10),
//             SelectableText("Card Number: $card"),
//             Text("Expiry: Any future date (e.g., 12/34)"),
//             Text("CVC: Any 3 digits (e.g., 123)"),
//             SizedBox(height: 8),
//             Text(desc, style: TextStyle(color: Colors.grey[700])),
//             SizedBox(height: 16),
//             ElevatedButton.icon(
//               onPressed: () {
//                 Navigator.pop(context);
//                 startPaymentFlow(context, label);
//               },
//               icon: Icon(Icons.payment),
//               label: Text("Open Payment Sheet"),
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Stripe Test Cards")),
//       body: ListView.builder(
//         itemCount: testCards.length,
//         itemBuilder: (context, index) {
//           final card = testCards[index];
//           return ListTile(
//             title: Text(card["label"]!),
//             subtitle: Text(card["desc"]!),
//             onTap: () => showCardInfo(context, card["label"]!, card["card"]!, card["desc"]!),
//           );
//         },
//       ),
//     );
//   }
// }