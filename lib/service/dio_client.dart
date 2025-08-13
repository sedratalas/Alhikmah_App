//
// import 'package:dio/dio.dart';
// import 'package:hive/hive.dart';
// import 'package:alhekmah_app/model/token_model.dart'; // تأكد من المسار الصحيح
//
// import 'auth_service.dart';
// import '../core/app_service.dart'; // قد تحتاج إلى تحديث المسار
//
// class DioClient {
//   final Dio dio;
//   final Box<dynamic> tokenBox;
//   late final AuthenticationService authService;
//
//   // قائمة الـ Endpoints التي لا تتطلب توكن (عامة)
//   final List<String> publicEndpoints = [
//     'books/',
//     'auth/login',
//     'auth/register',
//   ];
//
//   DioClient(this.tokenBox)
//       : dio = Dio(BaseOptions(
//     baseUrl: 'https://alhekmah-server-side.onrender.com/',
//   )) {
//     // يجب أن ننشئ Dio جديد لـ authService لمنع حلقة لانهائية في الـ interceptor
//     authService = AuthenticationService(dio: Dio(BaseOptions(baseUrl: dio.options.baseUrl)));
//
//     dio.interceptors.add(InterceptorsWrapper(
//       onRequest: (options, handler) {
//         // التحقق مما إذا كان الطلب إلى endpoint عام
//         final isPublicEndpoint = publicEndpoints.any(
//               (endpoint) => options.path.contains(endpoint),
//         );
//
//         // إذا لم يكن عاماً، أضف التوكن
//         if (!isPublicEndpoint) {
//           final accessToken = tokenBox.get('accessToken');
//           if (accessToken != null) {
//             options.headers['Authorization'] = 'Bearer $accessToken';
//           }
//         }
//         handler.next(options);
//       },
//       onError: (error, handler) async {
//         // التعامل مع خطأ 401
//         if (error.response?.statusCode == 401) {
//           final refreshToken = tokenBox.get('refreshToken');
//           if (refreshToken != null) {
//             try {
//               // طلب تحديث التوكن
//               final tokenResponse = await authService.refreshToken(refreshToken: refreshToken);
//
//               // حفظ التوكن الجديد
//               await tokenBox.put('accessToken', tokenResponse.accessToken);
//               await tokenBox.put('refreshToken', tokenResponse.refreshToken);
//
//               // إعادة الطلب الأصلي
//               final requestOptions = error.requestOptions;
//               requestOptions.headers['Authorization'] = 'Bearer ${tokenResponse.accessToken}';
//               final response = await dio.fetch(requestOptions);
//               return handler.resolve(response);
//
//             } catch (e) {
//               // إذا فشل التحديث، قم بتسجيل خروج المستخدم
//               await tokenBox.clear();
//               // يمكنك هنا إعادة توجيه المستخدم إلى شاشة تسجيل الدخول
//               return handler.reject(error);
//             }
//           } else {
//             // إذا لم يكن هناك refreshToken، قم بتسجيل الخروج مباشرة
//             await tokenBox.clear();
//             return handler.reject(error);
//           }
//         }
//         return handler.next(error);
//       },
//     ));
//   }
// }


import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:alhekmah_app/model/token_model.dart';
import 'auth_service.dart';
import '../core/app_service.dart';

class DioClient {
  final Dio dio;
  final Box<dynamic> tokenBox;
  late final AuthenticationService authService;

  final List<String> publicEndpoints = [
    'books/',
    'auth/login',
    'auth/register',
  ];

  DioClient(this.tokenBox)
      : dio = Dio(BaseOptions(
    baseUrl: 'https://alhekmah-server-side.onrender.com/',
  )) {
    // Create a new Dio instance for authService to avoid a circular dependency in the interceptor
    authService = AuthenticationService(dio: Dio(BaseOptions(baseUrl: dio.options.baseUrl)));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final isPublicEndpoint = publicEndpoints.any(
              (endpoint) => options.path.contains(endpoint),
        );

        if (!isPublicEndpoint) {
          final accessToken = tokenBox.get('accessToken');
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 Unauthorized error
        if (error.response?.statusCode == 401) {
          final refreshToken = tokenBox.get('refreshToken');
          if (refreshToken != null) {
            try {
              // Attempt to refresh the token
              final tokenResponse = await authService.refreshToken(refreshToken: refreshToken);

              // Save the new tokens
              await tokenBox.put('accessToken', tokenResponse.accessToken);
              await tokenBox.put('refreshToken', tokenResponse.refreshToken);

              // Retry the original request with the new access token
              final requestOptions = error.requestOptions;
              requestOptions.headers['Authorization'] = 'Bearer ${tokenResponse.accessToken}';
              final response = await dio.fetch(requestOptions);
              return handler.resolve(response);

            } on DioException catch (e) {
              // The refresh token itself is invalid (e.g., failed with a 401), so log out the user.
              if (e.response?.statusCode == 401) {
                await tokenBox.clear();
                return handler.reject(error);
              } else {
                // Any other error (e.g., network error) should not clear the tokens.
                return handler.reject(error);
              }
            } catch (e) {
              // Handle other unexpected errors by logging out the user.
              await tokenBox.clear();
              return handler.reject(error);
            }
          } else {
            // No refresh token exists, so clear any existing tokens and reject.
            await tokenBox.clear();
            return handler.reject(error);
          }
        }
        return handler.next(error);
      },
    ));
  }
}