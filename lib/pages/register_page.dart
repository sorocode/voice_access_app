import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:voice_access_app/services/register_service.dart';
import 'package:voice_access_app/widgets/%08Recording_sheet.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // final backendUrl =
  //   Platform.isAndroid ? 'http://10.0.2.2:8080' : 'http://localhost:8080';
  late String backendUrl;
  final _formKey = GlobalKey<FormState>();
  final Dio _dio = Dio();

  // 사용자 정보
  String name = '';
  String phone = '';
  String address = '';
  String weight = '';
  String height = '';
  String gender = 'MALE';
  DateTime? birthday;

  // 음성파일
  List<File> voiceFiles = [];
  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (voiceFiles.length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("음성 파일 5개를 업로드해주세요.")),
      );
      return;
    }

    _formKey.currentState!.save();

    final api = RegisterService(_dio, backendUrl);

    try {
      final response = await api.submitRegistration(
        name: name,
        phone: phone,
        address: address,
        weight: weight,
        height: height,
        gender: gender,
        birthday: birthday!,
        voiceFiles: voiceFiles,
      );

      print("✅ 회원가입 성공: ${response.data}");

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("회원가입 성공"),
          content: Text("$name님 반갑습니다."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text("확인"),
            ),
          ],
        ),
      );
    } catch (e) {
      if (e is DioException) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("서버와의 연결에 실패했습니다. 나중에 다시 시도해주세요")),
        );
        print("❌ DioException 발생!");
        print("📡 상태 코드: ${e.response?.statusCode}");
        print("📄 응답 데이터: ${e.response?.data}");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("알 수 없는 오류가 발생했습니다. 나중에 다시 시도해주세요")),
        );
        print("❌ 예외: $e");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    backendUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
  }

  @override
  Widget build(BuildContext context) {
    void showRecordingDrawer() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => RecordingSheet(
          onFinished: (List<File> recordedFiles) {
            setState(() {
              voiceFiles = recordedFiles;
            });
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('회원가입')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: '이름'),
                  onSaved: (val) => name = val ?? '',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return '이름은 필수 입력값입니다.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: '전화번호', hintText: "010-0000-0000"),
                  keyboardType: TextInputType.phone,
                  onSaved: (val) => phone = val ?? '',
                  validator: (val) {
                    final phonePattern = RegExp(r'\d{3}-\d{4}-\d{4}$');
                    if (val == null || val.isEmpty) {
                      return '전화번호를 입력해주세요.';
                    } else if (!phonePattern.hasMatch(val)) {
                      return '전화번호 형식이 올바르지 않습니다. 예: 010-1234-5678';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: '주소'),
                  onSaved: (val) => address = val ?? '',
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: '몸무게'),
                  keyboardType: TextInputType.number,
                  onSaved: (val) => weight = val ?? '',
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: '키'),
                  keyboardType: TextInputType.number,
                  onSaved: (val) => height = val ?? '',
                ),
                DropdownButtonFormField<String>(
                  value: gender,
                  items: ['MALE', 'FEMALE']
                      .map((g) => DropdownMenuItem(
                            value: g,
                            child: Text(g),
                          ))
                      .toList(),
                  onChanged: (val) => gender = val!,
                  decoration: InputDecoration(labelText: '성별'),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text(birthday != null
                        ? '생일: ${birthday!.toLocal().toString().split(" ")[0]}'
                        : '생일을 선택해주세요'),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.calendar_month),
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime(2000),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) setState(() => birthday = picked);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: showRecordingDrawer,
                  child: Text('🎙️ 음성 녹음하기 (5개)'),
                ),
                Text('녹음된 파일: ${voiceFiles.length}개'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: submitForm,
                  child: Text(
                    '✅ 회원가입 제출',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
