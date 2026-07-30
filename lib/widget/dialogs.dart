import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/version_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/login/login_view.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

import 'downloader.dart';
import 'loading.dart';

// errorDialog是否处于显示状态(供外部判断是否正在展示错误弹窗)
bool _isErrorDialogShowing = false;

bool get isErrorDialogShowing => _isErrorDialogShowing;

// 提示弹窗
void msgDialog({
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

//  咨询弹窗
void askDialog({
  String title = '',
  required String? content,
  Color? contentColor,
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
            style: TextStyle(color: contentColor ?? Colors.black)),
        content: Text(content ?? ''),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Get.back();
              confirm?.call();
            },
            child: Text(
              confirmText ?? 'dialog_default_confirm'.tr,
              style: TextStyle(color: confirmColor ?? Colors.black87),
            ),
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

// 提示弹窗
void successDialog({
  String title = '',
  required String? content,
  Function()? back,
}) {
  loadingDismiss();
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

//错误弹窗
void errorDialog({
  String title = '',
  required String? content,
  Function()? back,
}) {
  loadingDismiss();
  _isErrorDialogShowing = true;
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
              _isErrorDialogShowing = false;
              Get.back();
              back?.call();
            },
            child: Text('dialog_default_got_it'.tr),
          ),
        ],
      ),
    ),
    barrierDismissible: false, //拦截dialog外部点击
  ).then((_) => _isErrorDialogShowing = false); // 兜底：被外部关闭时也复位
}

void doUpdate({
  required VersionInfo version,
  Function()? ignore,
}) {
  var height = MediaQuery.of(Get.overlayContext!).size.height;
  var width = MediaQuery.of(Get.overlayContext!).size.width;
  final double dialogWidth = min(height, width) * 0.618;

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
                    onPressed: () {
                      if (GetPlatform.isAndroid) {
                        debugPrint('Android_Update');
                        Get.back();
                        Downloader(
                          url: version.url!,
                          isShowCancel: !version.force!,
                          completed: (path) {
                            if (version.force ?? false) {
                              installDialog(
                                filePath: path,
                                isForcedUpdate: version.force ?? false,
                              );
                            }
                            const MethodChannel(channelOther)
                                .invokeMethod('OpenFile', path);
                          },
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
                    },
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
                        onPressed: () {
                          Get.back();
                          ignore?.call();
                        },
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

void installDialog({
  required String filePath,
  required bool isForcedUpdate,
}) {
  Get.dialog(
    PopScope(
      //拦截返回键
      canPop: false,
      child: AlertDialog(
        title: Text('open_file_dialog_title'.tr),
        content: Text('open_file_dialog_tips'.trArgs([getFileName(filePath)])),
        actions: <Widget>[
          TextButton(
            onPressed: () => const MethodChannel(channelOther)
                .invokeMethod('OpenFile', filePath),
            child: Text('open_file_dialog_open'.tr),
          ),
          TextButton(
            onPressed: () {
              if (isForcedUpdate) {
                exit(0);
              } else {
                Get.back();
              }
            },
            child: Text(
              isForcedUpdate
                  ? 'open_file_dialog_close_app'.tr
                  : 'dialog_default_cancel'.tr,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    ),
    barrierDismissible: false, //拦截dialog外部点击
  );
}

bool reLoginDialogIsShowing = false;

void reLoginPopup() {
  if (Get.currentRoute ==RouteConfig.login) return;
  if (reLoginDialogIsShowing ) return;
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
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            gradient: LinearGradient(
              colors: isTestUrl()
                  ? [Colors.lightBlueAccent, Colors.greenAccent]
                  : [Colors.lightBlueAccent, Colors.blueAccent],
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

void reasonInputPopup({
  String? hintText,
  String? tips,
  bool isCanCancel = false,
  required List<Widget> title,
  String? confirmText,
  required Function(String reason) confirm,
  Function()? cancel,
}) {
  TextEditingController reasonController = TextEditingController();
  var confirmButton = ElevatedButton(
    style: ElevatedButton.styleFrom(
      shape: isPad() && isCanCancel
          ? const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                bottomLeft: Radius.circular(25),
              ),
            )
          : RoundedRectangleBorder(
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
      style: const TextStyle(fontSize: 16),
    ),
  );
  Widget? cancelButton;
  if (isCanCancel) {
    cancelButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: isPad() && isCanCancel
            ? const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              )
            : RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
      ),
      onPressed: () {
        Get.back();
        cancel?.call();
      },
      child: Text(
        'dialog_default_cancel'.tr,
        style: const TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
  var children = <Widget>[
    ...title,
    const SizedBox(height: 10),
    TextField(
      maxLines: 4,
      controller: reasonController,
      decoration: InputDecoration(
        suffixIcon: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            reasonController.clear();
          },
        ),
        contentPadding: const EdgeInsets.all(10),
        labelText: hintText ?? 'dialog_reason_hint'.tr,
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    ),
    Text(
      tips ?? '',
      maxLines: 2,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    const SizedBox(height: 30),
    isCanCancel
        ? isPad()
            ? Row(
                children: [
                  Expanded(child: confirmButton),
                  const SizedBox(width: 2),
                  Expanded(child: cancelButton!)
                ],
              )
            : Column(
                children: [
                  FractionallySizedBox(
                    widthFactor: 1,
                    child: confirmButton,
                  ),
                  const SizedBox(height: 10),
                  FractionallySizedBox(
                    widthFactor: 1,
                    child: cancelButton,
                  )
                ],
              )
        : FractionallySizedBox(
            widthFactor: 1,
            child: confirmButton,
          ),
  ];

  var popup = Card(
    margin: const EdgeInsets.all(0),
    color: Colors.transparent,
    shadowColor: Colors.transparent,
    child: Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: isPad()
            ? const BorderRadius.all(Radius.circular(20))
            : const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
        gradient: const LinearGradient(
          colors: [Colors.lightBlueAccent, Colors.blueAccent],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: isPad()
          ? ListView(shrinkWrap: true, children: children)
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
    ),
  );
  if (isPad()) {
    Get.dialog(PopScope(
      canPop: false,
      child: AlertDialog(
        contentPadding: const EdgeInsets.all(0),
        content: SizedBox(
          width: 400,
          child: popup,
        ),
      ),
    ));
  } else {
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
}

void exitDialog({
  required String content,
  Function()? confirm,
  Function()? cancel,
}) {
  loadingDismiss();
  Get.dialog(PopScope(
    canPop: false,
    child: AlertDialog(
      title: Text('dialog_default_exit_title'.tr),
      content: Text(
        content,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.red,
          fontSize: 18,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back(closeOverlays: true);
            confirm?.call();
          },
          child: Text('dialog_default_confirm'.tr),
        ),
        TextButton(
          onPressed: () {
            Get.back();
            cancel?.call();
          },
          child: Text(
            'dialog_default_cancel'.tr,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    ),
  ));
}

//修改密码弹窗
void changePasswordDialog({
  required String account,
  required String oldPassword,
  required Function(String password) success,
}) {
  var newPassword = TextEditingController();
  showCupertinoModalPopup<void>(
    context: Get.overlayContext!,
    builder: (context) => AlertDialog(
      title: Text('change_password_dialog_title'.tr),
      content: SizedBox(
        height: 150,
        width: 200,
        child: ListView(
          children: [
            Text('change_password_dialog_tips'.tr),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              width: 200,
              child: TextField(
                controller: newPassword,
                style: const TextStyle(color: Colors.grey),
                decoration: InputDecoration(
                  hintText: 'change_password_dialog_new_password'.tr,
                  hintStyle: const TextStyle(color: Colors.grey),
                  counterStyle: const TextStyle(color: Colors.grey),
                  prefixIcon:
                      const Icon(Icons.lock_outline, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () {
                      newPassword.clear();
                    },
                  ),
                ),
                maxLength: 10,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => _changePassword(
            account: account,
            oldPassword: oldPassword,
            newPassword: newPassword.text,
            success: (msg) => successDialog(
              content: msg,
              back: () {
                Get.back();
                success.call(newPassword.text);
              },
            ),
            error: (msg) => errorDialog(content: msg),
          ),
          child: Text('change_password_dialog_submit'.tr),
        ),
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text(
            'dialog_default_cancel'.tr,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    ),
  );
}

void _changePassword({
  required String account,
  required String oldPassword,
  required String newPassword,
  required Function(String msg) success,
  required Function(String msg) error,
}) {
  if (newPassword.isEmpty) {
    errorDialog(content: 'change_password_dialog_new_password'.tr);
    return;
  }
  httpPost(
    loading: 'change_password_dialog_submitting'.tr,
    method: webApiChangePassword,
    params: {
      'OldPassWord': oldPassword,
      'NewPassWord': newPassword,
      'Account': account
    },
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      success.call(response.message ?? '');
    } else {
      error.call(response.message ?? '');
    }
  });
}

void loadingShow(String? content) {
  // LoadingSingleton().show(content);
  LoadingController().show(content);
}

void loadingDismiss() {
  // LoadingSingleton().dismiss();
  LoadingController().dismiss();
}
