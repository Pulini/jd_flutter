import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jd_flutter/generated/l10n.dart';
import 'package:jd_flutter/http/web_api.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:permission_handler/permission_handler.dart';
import '../http/do_http.dart';
import '../widget/custom_widget.dart';

class FaceLogin extends StatefulWidget {
  const FaceLogin({Key? key}) : super(key: key);

  @override
  State<FaceLogin> createState() => _FaceLoginState();
}

class _FaceLoginState extends State<FaceLogin> {
  TextEditingController phone = TextEditingController();
  static const platform = MethodChannel('com.jd.pzx.jd_flutter');

  double progress = 0.0;

  _face(String filePath) async {
    try {
      Permission.camera.request().isGranted.then((value) async {
        if (value) {
          bool isMe = await platform.invokeMethod('startDetect', filePath);
          if(isMe){
            logger.d("人脸验证成功");
          }
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
                    TextField(
                      keyboardType: TextInputType.number,
                      controller: phone,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: S.current.login_hint_phone,
                        hintStyle: const TextStyle(color: Colors.white),
                        counterStyle: const TextStyle(color: Colors.white),
                        prefixIcon: const Icon(Icons.account_circle_outlined,
                            color: Colors.white),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            phone.clear();
                          },
                        ),
                      ),
                      maxLength: 11,
                    )
                  ],
                )),
          ),
        ),
        const SizedBox(height: 20),
        LoginButton(onPressed: () {
          getUserPhotoPath(context, phone.text.trim(), (url) {
            downloadDialog(context, url, (path) {
              _face(path);
            });
          });
        }),
      ],
    );
  }
}
