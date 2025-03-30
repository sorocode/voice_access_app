import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:voice_access_app/widgets/%08Recording_sheet.dart';
import 'package:http_parser/http_parser.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
    final birthdayFormatted = DateFormat('yyyy-MM-dd').format(birthday!);
    if (!_formKey.currentState!.validate()) return;
    if (voiceFiles.length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("음성 파일 5개를 업로드해주세요.")),
      );
      return;
    }

    _formKey.currentState!.save();
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

    // 백엔드로 요청 전송
    try {
      // FIXME: 서버 배포 후 환경변수로 변경
      Response response = await _dio.post('http://127.0.0.1:8080/api/signup',
          data: formData, options: Options(contentType: "multipart/form-data"));
      print("✅ 회원가입 성공: ${response.data}");
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Text("회원가입 성공"),
                content: Text("${name}님 반갑습니다."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // 알림창 닫기
                      Navigator.of(context).pop(); // 이전 화면으로 돌아가기 (선택)
                    },
                    child: Text("확인"),
                  ),
                ],
              ));
    } catch (e) {
      if (e is DioException) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("회원가입 입력값에 문제가 있습니다. 값을 다시 확인해주세요")),
        );
        print("❌ DioException 발생!");
        print("📡 상태 코드: ${e.response?.statusCode}");
        print("📄 응답 데이터: ${e.response?.data}");
        print("📋 응답 헤더: ${e.response?.headers}");
        print("🔗 요청 경로: ${e.requestOptions.path}");
        print("📦 전송된 데이터: ${e.requestOptions.data}");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("서버와의 연결에 실패했습니다. 나중에 다시 시도해주세요")),
        );
        print("❌ 예외: $e");
      }
    }
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
                    ElevatedButton(
                      child: Text('생일 선택'),
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
                  child: Text('음성 녹음하기 (5개)'),
                ),
                Text('녹음된 파일: ${voiceFiles.length}개'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: submitForm,
                  child: Text('회원가입 제출'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
