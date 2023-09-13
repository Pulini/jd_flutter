import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constant.dart';
import '../http/response/version_info.dart';
import '../http/web_api.dart';
import '../login/login_logic.dart';
import '../login/login_view.dart';
import 'downloader.dart';

/// 提示弹窗
informationDialog({
  String title = '',
  required String? content,
  Function()? back,
}) {
  showDialog<String>(
    barrierDismissible: false,
    context: Get.overlayContext!,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title.isEmpty ? 'dialog_default_title_information'.tr : title,
          style: const TextStyle(color: Colors.orange)),
      content: Text(content ?? ''),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Get.back();
            back?.call();
          },
          child: Text('dialog_default_got_it'.tr),
        ),
      ],
    ),
  );
}

/// 提示弹窗
successDialog({
  String title = '',
  required String? content,
  Function()? back,
}) {
  showDialog<String>(
    barrierDismissible: false,
    context: Get.overlayContext!,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title.isEmpty ? 'dialog_default_title_success'.tr : title,
          style: const TextStyle(color: Colors.green)),
      content: Text(content ?? ''),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Get.back();
            back?.call();
          },
          child: Text('dialog_default_got_it'.tr),
        ),
      ],
    ),
  );
}

///错误弹窗
errorDialog({
  String title = '',
  required String? content,
  Function()? back,
}) {
  showDialog<String>(
    barrierDismissible: false,
    context: Get.overlayContext!,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title.isEmpty ? 'dialog_default_title_error'.tr : title,
          style: const TextStyle(color: Colors.red)),
      content: Text(content ?? ''),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Get.back();
            back?.call();
          },
          child: Text('dialog_default_got_it'.tr),
        ),
      ],
    ),
  );
}

///加载中弹窗
loadingDialog(String? content) {
  showDialog<String>(
    barrierDismissible: false,
    context: Get.overlayContext!,
    builder: (BuildContext context) => WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 15),
              Text(content ?? '')
            ],
          ),
        ),
      ),
    ),
  );
}

doUpdate(VersionInfo version) {
  var height = MediaQuery.of(Get.overlayContext!).size.height;
  var width = MediaQuery.of(Get.overlayContext!).size.width;
  final double dialogWidth = min(height, width) * 0.618;
  update() {
    if (GetPlatform.isAndroid) {
      logger.f('Android_Update');
      Downloader(
        url: version.url!,
        completed: (path) => const MethodChannel(channelFlutterSend)
            .invokeMethod('OpenFile', path),
      );
      return;
    }
    if (GetPlatform.isIOS) {
      logger.f('IOS_Update');
      return;
    }
    if (GetPlatform.isWeb) {
      logger.f('Web_Update');
      return;
    }
    if (GetPlatform.isWindows) {
      logger.f('Windows_Update');
      return;
    }
    if (GetPlatform.isLinux) {
      logger.f('Linux_Update');
      return;
    }
    if (GetPlatform.isMacOS) {
      logger.f('MacOS_Update');
      return;
    }
    if (GetPlatform.isFuchsia) {
      logger.f('Fuchsia_Update');
      return;
    }
  }

  var dialog = Material(
    type: MaterialType.transparency,
    child: SizedBox(
      width: dialogWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: dialogWidth,
            child: Image.asset(
              'lib/res/images/bg_update_top.png',
              fit: BoxFit.fill,
            ),
          ),
          Container(
            width: dialogWidth,
            alignment: Alignment.center,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            decoration: const ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
            ),
            child: SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'update_dialog_title'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    version.description ?? '',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: 1,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: MaterialStateProperty.all(
                        const TextStyle(fontSize: 14),
                      ),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      elevation: MaterialStateProperty.all(5),
                      backgroundColor: MaterialStateProperty.all(Colors.red),
                    ),
                    onPressed: update,
                    child: Text('update_dialog_confirm'.tr),
                  ),
                ),
                if ((version.force ?? false) == false)
                  FractionallySizedBox(
                    widthFactor: 1,
                    child: TextButton(
                      style: ButtonStyle(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: MaterialStateProperty.all(
                          const TextStyle(fontSize: 14),
                        ),
                        foregroundColor: MaterialStateProperty.all(
                          Colors.grey[600],
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      onPressed: () => Get.back(),
                      child: Text('update_dialog_cancel'.tr),
                    ),
                  )
              ],
            )),
          ),
        ],
      ),
    ),
  );

  showDialog<bool>(
    context: Get.overlayContext!,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () => Future<bool>.value(false),
        child: dialog,
      );
    },
  );
}

reLoginPopup() {
  var logic = Get.put(LoginLogic());
  var state = Get.find<LoginLogic>().state;
  var button = ElevatedButton(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(280, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
    ),
    onPressed: () => logic.reLogin(),
    child: Text(
      'login'.tr,
      style: const TextStyle(fontSize: 20),
    ),
  );
  var popup = Container(
    padding: const EdgeInsets.all(8.0),
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      gradient: LinearGradient(
        colors: [Colors.lightBlueAccent, Colors.blueAccent],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ),
    ),
    child: Wrap(
      alignment: WrapAlignment.center,
      children: [
        Center(
          child: Text(
            're_login'.tr,
            style: const TextStyle(
                fontSize: 22,
                color: Colors.white,
                decoration: TextDecoration.none),
          ),
        ),
        const SizedBox(height: 50),
        Container(
          width: 360,
          height: 330,
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: LoginInlet(logic: logic, state: state),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: button,
        )
      ],
    ),
  );
  showCupertinoModalPopup(
    context: Get.overlayContext!,
    barrierDismissible: false,
    builder: (BuildContext context) => SingleChildScrollView(
      primary: true,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: popup,
    ),
  );
}

reasonInputPopup(
    {required List<Widget> title, required Function(String reason) confirm}) {
  TextEditingController reasonController = TextEditingController();
  var popup = Card(
    margin: const EdgeInsets.all(0),
    color: Colors.transparent,
    shadowColor: Colors.transparent,
    child: Container(
      padding: const EdgeInsets.all(8.0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        gradient: LinearGradient(
          colors: [Colors.lightBlueAccent, Colors.blueAccent],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...title,
          const SizedBox(height: 10),
          TextField(
            maxLines: 3,
            controller: reasonController,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  reasonController.clear();
                },
              ),
              contentPadding: const EdgeInsets.all(10),
              hintText: 'dialog_reason_hint'.tr,
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          const SizedBox(height: 50),
          FractionallySizedBox(
            widthFactor: 1,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: () {
                var reason = reasonController.text;
                if (reason.trim().isEmpty) {
                  errorDialog(content:'dialog_reason_hint'.tr);
                } else {
                  confirm.call(reason);
                }
              },
              child: Text(
                'dialog_reason_submit'.tr,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          )
        ],
      ),
    ),
  );
  showCupertinoModalPopup(
    context: Get.overlayContext!,
    builder: (BuildContext context) => SingleChildScrollView(
      primary: true,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: popup,
    ),
  );
}
