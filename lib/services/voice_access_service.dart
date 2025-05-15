import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

class VoiceAccessService {
  final Dio _dio;
  final String baseUrl;

  VoiceAccessService(this._dio, this.baseUrl);

  Future<Response> loginWithVoice(File audioFile) async {
    final formData = FormData.fromMap({
      'audio': await MultipartFile.fromFile(
        audioFile.path,
        filename: 'login_audio.wav',
        contentType: MediaType('audio', 'wav'),
      ),
    });

    return await _dio.post(
      '$baseUrl/api/login',
      data: formData,
      options: Options(contentType: "multipart/form-data"),
    );
  }
}
