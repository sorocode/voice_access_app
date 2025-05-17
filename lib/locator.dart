import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio();

    // 공통 설정
    dio.options.baseUrl = const String.fromEnvironment('API_BASE_URL',
        defaultValue: 'http://10.0.2.2:8080');
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    return dio;
  });
}
