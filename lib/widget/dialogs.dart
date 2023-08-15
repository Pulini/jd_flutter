import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/widget/update_dialog.dart';

import '../constant.dart';
import '../http/response/version_info.dart';
import '../http/web_api.dart';

/// 提示弹窗
informationDialog(BuildContext context,
    {String title = "", required String? content, Function()? back}) {
  showDialog<String>(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title.isEmpty ? 'dialog_default_title_information'.tr : title,
          style: const TextStyle(color: Colors.orange)),
      content: Text(content ?? ""),
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
successDialog(BuildContext context,
    {String title = "", required String? content, Function()? back}) {
  showDialog<String>(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title.isEmpty ? 'dialog_default_title_success'.tr : title,
          style: const TextStyle(color: Colors.green)),
      content: Text(content ?? ""),
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
errorDialog(BuildContext context,
    {String title = "", required String? content, Function()? back}) {
  showDialog<String>(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title.isEmpty ? 'dialog_default_title_error'.tr : title,
          style: const TextStyle(color: Colors.red)),
      content: Text(content ?? ""),
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
loadingDialog(BuildContext context, String? content) {
  showDialog<String>(
    barrierDismissible: false,
    context: context,
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
              Text(content ?? "")
            ],
          ),
        ),
      ),
    ),
  );
}

downloadDialog(BuildContext context, String url, Function(String) completed) {
  showDialog<String>(
    barrierDismissible: false,
    context: context,
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
  var _text = "0%";
  final cancelToken = CancelToken();

  downloading() {
    download(
      widget.url,
      cancel: cancelToken,
      progress: (count, total) {
        setState(() {
          _progress = (count / total);
          _text = "${((_progress * 1000).ceil() / 10)}%";
        });
      },
      completed: (path) {
        Get.back();
        widget.completed.call(path);
      },
      error: (msg) {
        Get.back();
        errorDialog(context, content: msg);
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
                    "正在下载<${widget.url.substring(widget.url.lastIndexOf("/") + 1)}>..."),
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
                    child: const Text("取消")),
              ],
            ),
          ),
        ));
  }
}



doUpdate(BuildContext context, VersionInfo version,
    {Function()? ignore}) {
  UpdateDialog.showUpdate(
    context,
    title: "发现新版本",
    updateContent: version.description!,
    isForce: true,
    updateButtonText: '升级',
    ignoreButtonText: '忽略此版本',
    enableIgnore: version.force! ? false : true,
    onIgnore: ignore,
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
}
