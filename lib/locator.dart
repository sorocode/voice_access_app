import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio();

    // 공통 설정 (선택)
    dio.options.baseUrl = const String.fromEnvironment('API_BASE_URL',
        defaultValue: 'http://localhost:8080');
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);

    return dio;
  });
}
