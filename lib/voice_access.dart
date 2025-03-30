import 'package:flutter/material.dart';
import 'package:voice_access_app/pages/register_page.dart';

class VoiceAccess extends StatefulWidget {
  const VoiceAccess({super.key});
  @override
  State<StatefulWidget> createState() {
    return _VoiceAccessState();
  }
}

class _VoiceAccessState extends State<VoiceAccess> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("음성인식 출입"),
          actions: [
            TextButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RegisterPage())),
                child: Text("회원가입")),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => print("로그인 버튼"),
                icon: Icon(
                  size: 140,
                  Icons.mic,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextButton(onPressed: () {}, child: Text("전화번호로 로그인"))
            ],
          ),
        ));
  }
}
