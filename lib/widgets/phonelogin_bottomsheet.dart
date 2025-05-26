import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:voice_access_app/services/voice_access_service.dart';

class PhoneloginBottomsheet extends StatefulWidget {
  const PhoneloginBottomsheet({super.key});

  @override
  State<PhoneloginBottomsheet> createState() => _PhoneloginBottomsheetState();
}

class _PhoneloginBottomsheetState extends State<PhoneloginBottomsheet> {
  late String _last4Digits, backendUrl;
  final _formKey = GlobalKey<FormState>();

  Future<void> submitPhoneNum() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      final api = VoiceAccessService();
      final response = await api.loginWithPhoneNum(_last4Digits);
      if (!mounted) return;

      if (response.statusCode == HttpStatus.ok) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("로그인 성공"),
            content: Text(response.data.toString()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(); // dialog 닫기
                  Navigator.of(context).pop(); // bottom sheet 닫기
                },
                child: Text("확인"),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("로그인 실패"),
            content: Text("에러: ${response.data.toString()}"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text("확인"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("에러 발생"),
          content: Text("서버 오류 또는 네트워크 문제\n"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text("확인"),
            ),
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    backendUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("전화번호로 로그인",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            TextFormField(
              validator: (val) =>
                  val == null || val.trim().isEmpty || val.trim().length != 4
                      ? '전화번호은 필수 입력값입니다. 4자리 값으로 입력해주세요'
                      : null,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "전화번호 뒷 4자리",
                border: OutlineInputBorder(),
              ),
              onSaved: (value) => _last4Digits = value ?? '',
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await submitPhoneNum();
                // Navigator.pop(context);
              },
              child: Text("로그인"),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
