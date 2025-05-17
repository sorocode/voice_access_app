import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:voice_access_app/pages/register_page.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:voice_access_app/services/voice_access_service.dart';

class VoiceAccessPage extends StatefulWidget {
  const VoiceAccessPage({super.key});
  @override
  State<StatefulWidget> createState() => _VoiceAccessPageState();
}

class _VoiceAccessPageState extends State<VoiceAccessPage> {
  bool isLoading = false;

  late String baseUrl;

  FlutterSoundRecorder recorder = FlutterSoundRecorder();
  bool isRecording = false;
  File? recordedFile;

  @override
  void initState() {
    super.initState();
    initRecorder();
    baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
  }

  Future<void> initRecorder() async {
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("🎙 마이크 권한이 필요합니다."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
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
    });

    if (path != null) {
      File file = File(path);
      bool exists = await file.exists();
      int size = await file.length();
      print('📁 녹음 파일 경로: $path');
      print('✅ 존재 여부: $exists');
      print('📦 파일 크기: $size bytes');

      if (exists && size > 0) {
        setState(() {
          recordedFile = file;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 파일 저장 실패. 다시 녹음해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> submitLogin() async {
    if (recordedFile == null) return;

    setState(() => isLoading = true);

    final service = VoiceAccessService();

    try {
      final response = await service.loginWithVoice(recordedFile!);
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${response.data.toString()}'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() => isLoading = false);
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
