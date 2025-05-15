import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class RecordingBottomsheet extends StatefulWidget {
  final Function(List<File>) onFinished;
  const RecordingBottomsheet({super.key, required this.onFinished});

  @override
  State<RecordingBottomsheet> createState() => _RecordingBottomsheetState();
}

class _RecordingBottomsheetState extends State<RecordingBottomsheet> {
  FlutterSoundRecorder recorder = FlutterSoundRecorder();
  bool isRecording = false;
  List<File> recordedFiles = [];

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
    String path =
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.wav';
    await recorder.startRecorder(
      toFile: path,
      codec: Codec.pcm16WAV,
    );
    setState(() {
      isRecording = true;
    });
  }

  Future<void> stopRecording() async {
    String? path = await recorder.stopRecorder();
    if (path != null) {
      recordedFiles.add(File(path));
    }
    setState(() {
      isRecording = false;
    });
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Text(
                  "🎙️ 녹음 ${recordedFiles.length}/5",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
                icon: Icon(isRecording ? Icons.stop : Icons.mic),
                label: Text(isRecording ? "녹음 중지" : "녹음 시작"),
                onPressed: recordedFiles.length >= 5
                    ? null
                    : () async {
                        if (!isRecording) {
                          await startRecording();
                        } else {
                          await stopRecording();
                        }
                      },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: recordedFiles.length == 5
                    ? () {
                        widget.onFinished(recordedFiles);
                        Navigator.pop(context);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("✅ 녹음 완료", style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
