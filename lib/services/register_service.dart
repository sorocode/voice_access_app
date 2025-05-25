import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:voice_access_app/locator.dart';
import 'package:voice_access_app/models/user.dart';

class RegisterService {
  final dio = getIt<Dio>();

  RegisterService();

  Future<Response> submitRegistration({
    required User user,
    required List<File> voiceFiles,
  }) async {
    final birthdayFormatted = DateFormat('yyyy-MM-dd').format(user.birthday);

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
      'username': user.name,
      'phoneNumber': user.phone,
      'homeAddress': user.address,
      'weight': double.parse(user.weight),
      'height': double.parse(user.height),
      'gender': user.gender.name, // enum → 문자열
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
