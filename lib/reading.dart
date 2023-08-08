import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get_utils/src/platform/platform.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/update_dialog.dart';

import 'constant.dart';
import 'home/home.dart';
import 'http/do_http.dart';
import 'http/response/user_info.dart';
import 'http/web_api.dart';
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

class _LoadingState extends State<Loading> {
  _goNextWidget() {
    if (userController.user.value!.token != null) {
      Get.off(const Home());
    } else {
      Get.to(const Login());
    }
  }

  _checkVersion() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => checkVersion(
        context,
        false,
        noUpdate: _goNextWidget,
        needUpdate: (version) {
          UpdateDialog.showUpdate(
            context,
            title: "发现新版本",
            updateContent: version.description!,
            isForce: true,
            updateButtonText: '升级',
            ignoreButtonText: '忽略此版本',
            enableIgnore: version.force! ? false : true,
            onIgnore: _goNextWidget,
            onUpdate: () {
              if (GetPlatform.isAndroid) {
                logger.f("Android_Update");
                downloadDialog(
                  context,
                  version.url!,
                  (path) => const MethodChannel(channelFlutterSend)
                      .invokeMethod('OpenFile', path),
                );
                return;
              }
              if (GetPlatform.isIOS) {
                logger.f("IOS_Update");
                return;
              }
              if (GetPlatform.isWeb) {
                logger.f("Web_Update");
                return;
              }
              if (GetPlatform.isWindows) {
                logger.f("Windows_Update");
                return;
              }
              if (GetPlatform.isLinux) {
                logger.f("Linux_Update");
                return;
              }
              if (GetPlatform.isMacOS) {
                logger.f("MacOS_Update");
                return;
              }
              if (GetPlatform.isFuchsia) {
                logger.f("Fuchsia_Update");
                return;
              }
            },
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkVersion();
  }

  @override
  Widget build(BuildContext context) {
    logger.f("build--------------");
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
