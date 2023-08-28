import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/widget/update_dialog.dart';

import '../constant.dart';
import '../http/response/version_info.dart';
import '../http/web_api.dart';
import '../login/login_logic.dart';
import '../login/login_view.dart';

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

downloadDialog(String url, Function(String) completed) {
  showDialog<String>(
    barrierDismissible: false,
    context: Get.overlayContext!,
    builder: (BuildContext context) => WillPopScope(
      onWillPop: () async => false,
      child: ProgressDialog(
        url: url,
        completed: (path) {
          completed.call(path);
        },
      ),
    ),
  );
}

///下载器
class ProgressDialog extends StatefulWidget {
  const ProgressDialog({
    Key? key,
    required this.url,
    required this.completed,
  }) : super(key: key);
  final String url;
  final Function(dynamic) completed;

  @override
  State<ProgressDialog> createState() => _ProgressDialogState();
}

class _ProgressDialogState extends State<ProgressDialog> {
  var _progress = 0.0;
  var _text = '0%';
  final cancelToken = CancelToken();

  downloading() {
    download(
      widget.url,
      cancel: cancelToken,
      progress: (count, total) {
        setState(() {
          _progress = (count / total);
          _text = '${((_progress * 1000).ceil() / 10)}%';
        });
      },
      completed: (path) {
        Get.back();
        widget.completed.call(path);
      },
      error: (msg) {
        Get.back();
        errorDialog(content: msg);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    downloading();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: Colors.white,
        child: SizedBox(
          width: 200,
          height: 160,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                    '正在下载<${widget.url.substring(widget.url.lastIndexOf('/') + 1)}>...'),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.blue.shade200,
                          color: Colors.greenAccent,
                          value: _progress,
                        )),
                    const SizedBox(width: 10),
                    Text(_text),
                  ],
                ),
                TextButton(
                    onPressed: () {
                      cancelToken.cancel();
                      Get.back();
                    },
                    child: const Text('取消')),
              ],
            ),
          ),
        ));
  }
}

doUpdate( VersionInfo version, {Function()? ignore}) {
  UpdateDialog.showUpdate(
    Get.overlayContext!,
    title: '发现新版本',
    updateContent: version.description!,
    isForce: true,
    updateButtonText: '升级',
    ignoreButtonText: '忽略此版本',
    enableIgnore: version.force! ? false : true,
    onIgnore: ignore,
    onUpdate: () {
      if (GetPlatform.isAndroid) {
        logger.f('Android_Update');
        Get.back();
        downloadDialog(
          version.url!,
          (path) => const MethodChannel(channelFlutterSend)
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
    },
  );
}

reLoginDialog() {
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
  var dialog = UnconstrainedBox(
    child: SizedBox(
      width: 380,
      height: 460,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
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
              width: 500,
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
      ),
    ),
  );

  showDialog<String>(
    barrierDismissible: false,
    context: Get.overlayContext!,
    builder: (BuildContext context) => dialog,
  );
}
