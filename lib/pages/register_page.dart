import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:voice_access_app/models/user.dart';
import 'package:voice_access_app/services/register_service.dart';
import 'package:voice_access_app/widgets/recording_bottomsheet.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late String backendUrl;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  // 사용자 정보
  late String _name, _phone, _address, _weight, _height;
  Gender gender = Gender.MALE;
  DateTime? birthday;
  User? user;

  // 음성파일
  List<File> voiceFiles = [];

  @override
  void initState() {
    super.initState();
    backendUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
  }

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (voiceFiles.length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("음성 파일 5개를 업로드해주세요.")),
      );
      return;
    }

    _formKey.currentState!.save();

    user = User(
      name: _name,
      phone: _phone,
      address: _address,
      weight: _weight,
      height: _height,
      gender: gender,
      birthday: birthday!,
    );

    final api = RegisterService();
    setState(() => isLoading = true);
    try {
      final response = await api.submitRegistration(
        user: user!,
        voiceFiles: voiceFiles,
      );

      print("✅ 회원가입 성공: ${response.data}");

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("회원가입 성공"),
          content: Text("${user!.name}님 반갑습니다."),
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
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showRecordingDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => RecordingBottomsheet(
        onFinished: (List<File> recordedFiles) {
          setState(() {
            voiceFiles = recordedFiles;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  onSaved: (val) => _name = val ?? '',
                  validator: (val) => val == null || val.trim().isEmpty
                      ? '이름은 필수 입력값입니다.'
                      : null,
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: '전화번호', hintText: "010-0000-0000"),
                  keyboardType: TextInputType.phone,
                  onSaved: (val) => _phone = val ?? '',
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
                  onSaved: (val) => _address = val ?? '',
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: '몸무게'),
                  keyboardType: TextInputType.number,
                  onSaved: (val) => _weight = val ?? '',
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: '키'),
                  keyboardType: TextInputType.number,
                  onSaved: (val) => _height = val ?? '',
                ),
                DropdownButtonFormField<Gender>(
                  value: gender,
                  items: Gender.values
                      .map((g) => DropdownMenuItem(
                            value: g,
                            child: Text(g.name),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => gender = val!),
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
                  child: isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
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
