import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/version_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/login/login_view.dart';

import 'downloader.dart';


/// 提示弹窗
informationDialog({
  String title = '',
  required String? content,
  Function()? back,
}) {
  Get.dialog(
    PopScope(
      //拦截返回键
      canPop: false,
      child: AlertDialog(
        title: Text(
          title.isEmpty ? 'dialog_default_title_information'.tr : title,
          style: const TextStyle(color: Colors.orange),
        ),
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
    ),
    barrierDismissible: false, //拦截dialog外部点击
  );
}

///  咨询弹窗
askDialog({
  String title = '',
  required String? content,
  Function()? confirm,
  String? confirmText,
  Color? confirmColor,
  Function()? cancel,
  String? cancelText,
  Color? cancelColor,
}) {
  Get.dialog(
    PopScope(
      //拦截返回键
      canPop: false,
      child: AlertDialog(
        title: Text(title.isEmpty ? 'dialog_default_title'.tr : title,
            style: TextStyle(color: confirmColor ?? Colors.black)),
        content: Text(content ?? ''),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Get.back();
              confirm?.call();
            },
            child: Text(confirmText ?? 'dialog_default_confirm'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              cancel?.call();
            },
            child: Text(
              cancelText ?? 'dialog_default_cancel'.tr,
              style: TextStyle(color: cancelColor ?? Colors.grey),
            ),
          ),
        ],
      ),
    ),
    barrierDismissible: false, //拦截dialog外部点击
  );
}

/// 提示弹窗
successDialog({
  String title = '',
  required String? content,
  Function()? back,
}) {
  Get.dialog(
    PopScope(
      //拦截返回键
      canPop: false,
      child: AlertDialog(
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
    ),
    barrierDismissible: false, //拦截dialog外部点击
  );
}

///错误弹窗
errorDialog({
  String title = '',
  required String? content,
  Function()? back,
}) {
  Get.dialog(
    PopScope(
      //拦截返回键
      canPop: false,
      child: AlertDialog(
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
    ),
    barrierDismissible: false, //拦截dialog外部点击
  );
}

GlobalKey<NavigatorState> loadingKey = GlobalKey();

///加载中弹窗
loadingDialog(String? content) {
  Get.dialog(
    PopScope(
      canPop: false,
      child: Dialog(
        key: loadingKey,
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
    barrierDismissible: false, //拦截dialog外部点击
  );
}

loadingDismiss() {
  if (loadingKey.currentContext != null) {
    final routeDialog = ModalRoute.of(loadingKey.currentContext!);
    if (routeDialog != null) {
      Navigator.removeRoute(Get.overlayContext!, routeDialog);
    }
  }
}

doUpdate(VersionInfo version) {
  var height = MediaQuery.of(Get.overlayContext!).size.height;
  var width = MediaQuery.of(Get.overlayContext!).size.width;
  final double dialogWidth = min(height, width) * 0.618;
  update() {
    if (GetPlatform.isAndroid) {
      debugPrint('Android_Update');
      Downloader(
        url: version.url!,
        completed: (path) => const MethodChannel(channelUsbAndroidToFlutter)
            .invokeMethod('OpenFile', path),
      );
      return;
    }
    if (GetPlatform.isIOS) {
      debugPrint('IOS_Update');
      return;
    }
    if (GetPlatform.isWeb) {
      debugPrint('Web_Update');
      return;
    }
    if (GetPlatform.isWindows) {
      debugPrint('Windows_Update');
      return;
    }
    if (GetPlatform.isLinux) {
      debugPrint('Linux_Update');
      return;
    }
    if (GetPlatform.isMacOS) {
      debugPrint('MacOS_Update');
      return;
    }
    if (GetPlatform.isFuchsia) {
      debugPrint('Fuchsia_Update');
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
              'assets/images/bg_update_top.png',
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
                      textStyle: WidgetStateProperty.all(
                        const TextStyle(fontSize: 14),
                      ),
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      elevation: WidgetStateProperty.all(5),
                      backgroundColor: WidgetStateProperty.all(Colors.red),
                    ),
                    onPressed: update,
                    child: Text('update_dialog_confirm'.tr),
                  ),
                ),
                if ((version.force ?? false) == false)
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: FractionallySizedBox(
                      widthFactor: 1,
                      child: TextButton(
                        style: ButtonStyle(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: WidgetStateProperty.all(
                            const TextStyle(fontSize: 14),
                          ),
                          foregroundColor: WidgetStateProperty.all(
                            Colors.grey[600],
                          ),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        onPressed: () => Get.back(),
                        child: Text('update_dialog_cancel'.tr),
                      ),
                    ),
                  ),
              ],
            )),
          ),
        ],
      ),
    ),
  );
  Get.dialog(
    PopScope(
      //拦截返回键
      canPop: false,
      child: dialog,
    ),
    barrierDismissible: false, //拦截dialog外部点击
  );
}

bool reLoginDialogIsShowing = false;

reLoginPopup() {
  if (reLoginDialogIsShowing) return;
  reLoginDialogIsShowing = true;
  showCupertinoModalPopup(
    context: Get.overlayContext!,
    barrierDismissible: false,
    builder: (BuildContext context) => PopScope(
      //拦截返回键
      canPop: false,
      child: SingleChildScrollView(
        primary: true,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
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
              const Center(child: LoginPick(isReLogin: true)),
            ],
          ),
        ),
      ),
    ),
  );
}

reasonInputPopup({
  String? hintText,
  String? confirmText,
  bool isCanCancel = false,
  required List<Widget> title,
  required Function(String reason) confirm,
  Function()? cancel,
}) {
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
              hintText: hintText ?? 'dialog_reason_hint'.tr,
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
                  errorDialog(content: hintText ?? 'dialog_reason_hint'.tr);
                } else {
                  confirm.call(reason);
                }
              },
              child: Text(
                confirmText ?? 'dialog_default_confirm'.tr,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          if (isCanCancel) const SizedBox(height: 10),
          if (isCanCancel)
            FractionallySizedBox(
              widthFactor: 1,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () {
                  Get.back();
                  cancel?.call();
                },
                child: Text(
                  'dialog_default_cancel'.tr,
                  style: const TextStyle(fontSize: 20, color: Colors.grey),
                ),
              ),
            )
        ],
      ),
    ),
  );
  showCupertinoModalPopup(
    context: Get.overlayContext!,
    builder: (BuildContext context) => PopScope(
      //拦截返回键
      canPop: false,
      child: SingleChildScrollView(
        primary: true,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: popup,
      ),
    ),
  );
}
