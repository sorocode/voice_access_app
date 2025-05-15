import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';

class RegisterService {
  final Dio _dio;
  final String baseUrl;

  RegisterService(this._dio, this.baseUrl);

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

    return await _dio.post(
      '$baseUrl/api/signup',
      data: formData,
      options: Options(contentType: "multipart/form-data"),
    );
  }
}
