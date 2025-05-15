import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:voice_access_app/locator.dart';

class RegisterService {
  final dio = getIt<Dio>();

  RegisterService();

  Future<Response> submitRegistration({
    required String name,
    required String phone,
    required String address,
    required String weight,
    required String height,
    required String gender,
    required DateTime birthday,
    required List<File> voiceFiles,
  }) async {
    final birthdayFormatted = DateFormat('yyyy-MM-dd').format(birthday);

    List<MultipartFile> multipartFiles = [];
    for (File file in voiceFiles) {
      multipartFiles.add(
        await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
          contentType: MediaType('audio', 'wav'),
        ),
      );
    }

    FormData formData = FormData.fromMap({
      'username': name,
      'phoneNumber': phone,
      'homeAddress': address,
      'weight': double.parse(weight),
      'height': double.parse(height),
      'gender': gender,
      'birthday': birthdayFormatted,
      'voiceFiles': multipartFiles,
    });

    return await dio.post(
      '/api/signup',
      data: formData,
      options: Options(contentType: "multipart/form-data"),
    );
  }
}
