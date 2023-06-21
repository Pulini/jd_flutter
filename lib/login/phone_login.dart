import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jd_flutter/http/do_http.dart';
import '../widget/dialogs.dart';
import 'package:jd_flutter/generated/l10n.dart';

import '../widget/custom_widget.dart';

class PhoneLogin extends StatefulWidget {
  const PhoneLogin({Key? key}) : super(key: key);

  @override
  State<PhoneLogin> createState() => _PhoneLoginState();
}

class _PhoneLoginState extends State<PhoneLogin> {
  var buttonName = S.current.get_verify_code;
  late Timer _timer;
  var countTimer = 0;

  TextEditingController phone = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController verificationCode = TextEditingController();

  _verifyCode() {
    //按钮名称不是获取验证码，直接返回
    if (buttonName != S.current.get_verify_code) {
      return;
    }
    //手机号为空，提示
    if (phone.text.trim().isEmpty) {
      errorDialog(context, content: S.current.login_hint_phone);
      return;
    }
    //请求接口获取验证码
    getVerifyCode(context, phone.text.trim(), sendSuccess: () {
      _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
        setState(() {
          countTimer++;
          if (countTimer == 60) {
            _timer.cancel();
            countTimer = 0;
            buttonName = S.current.get_verify_code;
          } else {
            buttonName = (60 - countTimer).toString();
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        width: 340.0,
        height: 270.0,
        child: Card(
            // color: const Color.fromARGB(255, 213, 41, 42),
            // color: const Color(0xFF242A38),
            color: Colors.blueAccent,
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: phone,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: S.current.login_hint_phone,
                        hintStyle: const TextStyle(color: Colors.white),
                        counterStyle: const TextStyle(color: Colors.white),
                        prefixIcon:
                            const Icon(Icons.phone, color: Colors.white),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            phone.clear();
                          },
                        ),
                      ),
                      maxLength: 11,
                    ),
                    TextField(
                      obscureText: true,
                      controller: password,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: S.current.login_hint_password,
                        hintStyle: const TextStyle(color: Colors.white),
                        counterStyle: const TextStyle(color: Colors.white),
                        prefixIcon:
                            const Icon(Icons.lock_outline, color: Colors.white),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            password.clear();
                          },
                        ),
                      ),
                      maxLength: 10,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextField(
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                            controller: verificationCode,
                            decoration: InputDecoration(
                              hintText: S.current.login_hint_verify_code,
                              hintStyle: const TextStyle(color: Colors.white),
                              counterStyle:
                                  const TextStyle(color: Colors.white),
                              prefixIcon: const Icon(Icons.email_outlined,
                                  color: Colors.white),
                            ),
                            maxLength: 6,
                          ),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  buttonName == S.current.get_verify_code
                                      ? Colors.white
                                      : Colors.grey.shade400,
                            ),
                            onPressed: () => _verifyCode(),
                            child: Text(buttonName,
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 213, 41, 42))))
                      ],
                    )
                  ],
                ))),
      ),
      const SizedBox(height: 20),
      LoginButton(onPressed: () {
        phoneLogin(context, phone.text, password.text, verificationCode.text,
            back: (dynamic) {});
      })
    ]);
  }
}
