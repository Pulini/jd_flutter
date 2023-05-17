import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jd_flutter/utils.dart';
import 'package:jd_flutter/web_api.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:permission_handler/permission_handler.dart';

/// File Name : login
/// Created by : PanZX on 2023/02/27
/// Email : 644173944@qq.com
/// Github : https://github.com/Pulini
/// Remark：
class Login extends StatelessWidget {
  Login({Key? key}) : super(key: key);
  final TextEditingController _account = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _verificationCode = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          // colors: [Color(0xFFf54b64), Color(0xFFf78361)],
          colors: [Color(0xFF141629), Color(0xFF3B2948)],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        // image: DecorationImage(
        //   image: AssetImage("lib/res/images/bkg_login.jpg"),
        //   fit: BoxFit.cover,
        // ),
      ),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          PhoneLogin(
            account: _account,
            password: _password,
            verificationCode: _verificationCode,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(320, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30))),
              child: const Text('登录', style: TextStyle(fontSize: 20)),
              onPressed: () {
                hideKeyBoard();
                loadingDialog(context, "登录中...");
                Map<String, dynamic> loginQuery = {
                  "JiGuangID": "",
                  "Phone": _account.text,
                  "Password": _password.text,
                  "VCode": _verificationCode.text,
                  "Type": 0,
                  "FaceLogin": false,
                };
                DoHttp(webApiLogin, query: loginQuery).post(
                    back: (code, data, msg) {
                  Navigator.pop(context);
                  logger.e(msg);
                  if (code == resultSuccess) {
                    // var userInfo = UserInfoEntity.fromJson(jsonDecode(data));
                    // informationDialog(context, "登录成功",
                    //     "${userInfo.name} ${userInfo.departmentName} ${userInfo.position}");
                  } else {
                    errorDialog(context, "登录失败", msg ?? "登录失败");
                  }
                });
              }),
        ]),
      ),
    );
  }
}

class PhoneLogin extends StatefulWidget {
  const PhoneLogin(
      {Key? key,
      required this.account,
      required this.password,
      required this.verificationCode})
      : super(key: key);

  final TextEditingController account;

  final TextEditingController password;

  final TextEditingController verificationCode;

  @override
  State<PhoneLogin> createState() => _PhoneLoginState();
}

class _PhoneLoginState extends State<PhoneLogin> {
  var textStyle = const TextStyle(color: Colors.white);
  var buttonName = "获取验证码";
  late Timer _timer;
  var countTimer = 0;
  static const platform = MethodChannel('com.jd.pzx.jd_flutter');

  _face() async {
    String batteryLevel;
    try {
      if (await Permission.camera.request().isGranted) {
        batteryLevel = await platform.invokeMethod('startDetect');
      } else {
        batteryLevel = "没有相机权限";
      }
    } on PlatformException catch (e) {
      batteryLevel = "启动失败";
    }

    setState(() {
      buttonName = batteryLevel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Image.asset("lib/res/images/ic_logo.png", width: 200, height: 200),
      const SizedBox(height: 20),
      SizedBox(
        width: 340.0,
        height: 270.0,
        child: Card(
            // color: const Color.fromARGB(255, 213, 41, 42),
            color: const Color(0xFF242A38),
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: widget.account,
                      style: textStyle,
                      decoration: InputDecoration(
                        hintText: '请输入账号',
                        hintStyle: textStyle,
                        counterStyle: textStyle,
                        prefixIcon: const Icon(Icons.account_circle_outlined,
                            color: Colors.white),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            widget.account.clear();
                          },
                        ),
                      ),
                      maxLength: 11,
                    ),
                    TextField(
                      obscureText: true,
                      controller: widget.password,
                      style: textStyle,
                      decoration: InputDecoration(
                        hintText: '请输入密码',
                        hintStyle: textStyle,
                        counterStyle: textStyle,
                        prefixIcon:
                            const Icon(Icons.lock_outline, color: Colors.white),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            widget.password.clear();
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
                            style: textStyle,
                            keyboardType: TextInputType.number,
                            controller: widget.verificationCode,
                            decoration: InputDecoration(
                              hintText: '请输入验证码',
                              hintStyle: textStyle,
                              counterStyle: textStyle,
                              prefixIcon: const Icon(Icons.email_outlined,
                                  color: Colors.white),
                            ),
                            maxLength: 6,
                          ),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonName == "获取验证码"
                                  ? Colors.white
                                  : Colors.grey.shade400,
                            ),
                            onPressed: () {
                              // _face();

                              if (buttonName != "获取验证码") {
                                return;
                              }

                              if (widget.account.text.trim().isEmpty) {
                                errorDialog(context, "错误", "请输入账号");
                                return;
                              }

                              loadingDialog(context, "正在发送验证码...");

                              DoHttp(webApiVerificationCode, query: {
                                "phone": widget.account.text,
                              }).post(back: (code, data, msg) {
                                Navigator.pop(context);
                                informationDialog(context, "发送验证码", "验证码发送成功");
                                logger.e(msg);
                                if (code == resultSuccess) {
                                  _timer = Timer.periodic(
                                      const Duration(milliseconds: 1000),
                                      (timer) {
                                    countTimer++;
                                    setState(() {
                                      if (countTimer == 60) {
                                        _timer.cancel();
                                        countTimer = 0;
                                        buttonName = "获取验证码";
                                      } else {
                                        buttonName =
                                            (60 - countTimer).toString();
                                      }
                                    });
                                  });
                                } else {
                                  errorDialog(context, "发送验证码", msg ?? "发送失败");
                                }
                              });
                            },
                            child: Text(buttonName,
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 213, 41, 42))))
                      ],
                    )
                  ],
                ))),
      )
    ]);
  }
}
