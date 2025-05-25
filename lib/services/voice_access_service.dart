import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:voice_access_app/locator.dart';

class VoiceAccessService {
  final dio = getIt<Dio>();
  VoiceAccessService();

  Future<Response> loginWithVoice(File audioFile) async {
    final formData = FormData.fromMap({
      'audio': await MultipartFile.fromFile(
        audioFile.path,
        filename: 'login_audio.wav',
        contentType: MediaType('audio', 'x-wav'),
      ),
    });
    if (audioFile.exists() == true) {
      print("파일: $audioFile");
      print("폼데이터${formData.fields}");
    } else {
      print("파일이 제대로 입력되지 않았습니다.");
    }
    return await dio.post(
      '/api/login',
      data: formData,
      options: Options(contentType: "multipart/form-data"),
    );
  }
}
