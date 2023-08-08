import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'home/home.dart';
import 'http/do_http.dart';
import 'http/response/user_info.dart';
import 'login/login.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class UserController extends GetxController {
  Rx<UserInfo?> user = UserInfo().obs;

  init(UserInfo userInfo) {
    user = userInfo.obs;
    update();
  }
}

_goNextWidget() {
  if (userController.user.value!.token != null) {
    Get.off(() => const Home());
  } else {
    Get.to(() => const Login());
  }
}

class _LoadingState extends State<Loading> {
  @override
  void initState() {
    super.initState();
    getVersionInfo(
      context,
      false,
      noUpdate: _goNextWidget,
      needUpdate: (versionInfo) {
        doUpdate(context, versionInfo, _goNextWidget);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //设置背景
      decoration: const BoxDecoration(
          gradient: LinearGradient(
        // colors: [Color(0xFFf54b64), Color(0xFFf78361)],
        colors: [Colors.lightBlueAccent, Colors.blueAccent],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      )),
      child: const Hero(tag: "logo", child: Logo()),
    );
  }
}

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset("lib/res/images/ic_logo.png", width: 130, height: 130),
        const Text("Gold Emperor",
            style: TextStyle(
                fontSize: 40,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none))
      ],
    );
  }
}
