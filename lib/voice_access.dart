import 'dart:io';
import 'package:flutter/material.dart';
import 'package:voice_access_app/pages/register_page.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

class VoiceAccess extends StatefulWidget {
  const VoiceAccess({super.key});
  @override
  State<StatefulWidget> createState() => _VoiceAccessState();
}

class _VoiceAccessState extends State<VoiceAccess> {
  final Dio _dio = Dio();
  bool isLoading = false;

  FlutterSoundRecorder recorder = FlutterSoundRecorder();
  bool isRecording = false;
  File? recordedFile;

  @override
  void initState() {
    super.initState();
    initRecorder();
  }

  Future<void> initRecorder() async {
    await Permission.microphone.request();
    await recorder.openRecorder();
  }

  Future<void> startRecording() async {
    Directory tempDir = await getTemporaryDirectory();
    String path = '${tempDir.path}/login_audio.wav';
    await recorder.startRecorder(toFile: path, codec: Codec.pcm16WAV);
    setState(() {
      isRecording = true;
    });
  }

  Future<void> stopRecording() async {
    String? path = await recorder.stopRecorder();
    setState(() {
      isRecording = false;
      if (path != null) recordedFile = File(path);
    });
  }

  Future<void> submitLogin() async {
    if (recordedFile == null) return;

    setState(() => isLoading = true);

    FormData formData = FormData.fromMap({
      'audio': await MultipartFile.fromFile(
        recordedFile!.path,
        filename: 'login_audio.wav',
        contentType: MediaType('audio', 'wav'),
      ),
    });

    try {
      final response = await _dio.post(
        'http://127.0.0.1:8080/api/login', // FIXME: 백엔드서버 배포 후 환경변수로 넣기
        data: formData,
        options: Options(contentType: "multipart/form-data"),
      );

      setState(() => isLoading = false);

      //  로그인 성공 SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${response.data.toString()}'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() => isLoading = false);
      //  로그인 실패 SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ 로그인 실패! 음성을 다시 시도해주세요'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("음성인식 출입"),
        actions: [
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegisterPage()),
            ),
            child: Text("회원가입"),
          ),
        ],
      ),
      body: Center(
        child: isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text("로그인 중입니다..."),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 140,
                    icon: Icon(isRecording ? Icons.stop_circle : Icons.mic),
                    onPressed: () async {
                      if (!isRecording) {
                        await startRecording();
                      } else {
                        await stopRecording();
                        await submitLogin();
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  TextButton(onPressed: () {}, child: Text("전화번호로 로그인")),
                ],
              ),
      ),
    );
  }
}
