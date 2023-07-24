import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/generated/l10n.dart';
import 'package:jd_flutter/http/web_api.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:permission_handler/permission_handler.dart';

import '../home/home.dart';
import '../http/do_http.dart';
import '../utils.dart';
import '../widget/number_text_field.dart';

class FaceLogin extends StatefulWidget {
  const FaceLogin({Key? key}) : super(key: key);

  static const faceVerifySuccess = 1;
  static const faceVerifyFailNotLive = 2;
  static const faceVerifyFailNotMe = 3;
  static const faceVerifyFailError = 4;

  @override
  State<FaceLogin> createState() => _FaceLoginState();
}

class _FaceLoginState extends State<FaceLogin> {
  TextEditingController phone = TextEditingController();

  static const platform = MethodChannel(androidPackageName);
  double progress = 0.0;

  _face(String filePath) async {
    try {
      Permission.camera.request().isGranted.then((value) async {
        if (value) {
          await platform.invokeMethod('startDetect', filePath).then((value) {
            logger.i(value);
            faceLogin(context, phone.text, back: (userInfo) {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const Home(),
                ),
              );
            });
          }).catchError((e) {
            logger.i(e);
          });
        } else {
          errorDialog(context,
              content: S.current.face_login_no_camera_permission);
        }
      });
    } on PlatformException {
      errorDialog(context, content: S.current.face_login_failed);
    }
  }

  @override
  void initState() {
    super.initState();
    spGet(spSaveLoginFace).then((value) {
      phone.text = value ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 340.0,
          height: 120.0,
          child: Card(
            color: Colors.blueAccent,
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    NumberTextField(
                        numberController: phone,
                        maxLength: 11,
                        textStyle: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: S.current.login_hint_phone,
                          hintStyle: const TextStyle(color: Colors.white),
                          counterStyle: const TextStyle(color: Colors.white),
                          prefixIcon: const Icon(Icons.phone_android,
                              color: Colors.white),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              phone.clear();
                            },
                          ),
                        ))
                  ],
                )),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(320, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25))),
            onPressed: () =>
                getUserPhotoPath(context, phone.text.trim(), (url) {
                  downloadDialog(context, url, (filePath) {
                    _face(filePath);
                  });
                }),
            child: Text(S.current.login, style: const TextStyle(fontSize: 20)))
      ],
    );
  }
}
