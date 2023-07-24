import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jd_flutter/generated/l10n.dart';
import 'package:jd_flutter/utils.dart';

import '../http/do_http.dart';
import '../http/web_api.dart';

/// 提示弹窗
informationDialog(BuildContext context,
    {String title = "", required String? content, Function()? back}) {
  showDialog<String>(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(
          title.isEmpty ? S.current.dialog_default_title_information : title,
          style: const TextStyle(color: Colors.green)),
      content: Text(content ?? ""),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            back?.call();
          },
          child: Text(S.current.dialog_default_got_it),
        ),
      ],
    ),
  );
}

///错误弹窗
errorDialog(BuildContext context,
    {String title = "", required String? content}) {
  showDialog<String>(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title.isEmpty ? S.current.dialog_default_title_error : title,
          style: const TextStyle(color: Colors.red)),
      content: Text(content ?? ""),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(S.current.dialog_default_got_it),
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
      builder: (BuildContext context) => Dialog(
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
          ));
}

downloadDialog(BuildContext context, String url, Function(String) completed) {
  showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(
          url: url,
          completed: (path) {
            completed.call(path);
          }));
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
        Navigator.pop(context);
        widget.completed.call(path);
      },
      error: (msg) {
        Navigator.pop(context);
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
                      Navigator.pop(context);
                    },
                    child: const Text("取消")),
              ],
            ),
          ),
        ));
  }
}

///修改密码弹窗
void changePasswordDialog(BuildContext context) {
  userInfo().then((user) {
    TextEditingController oldPassword = TextEditingController();
    TextEditingController newPassword = TextEditingController();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(S.current.change_password_dialog_title),
        content: SizedBox(
          height: 150,
          child: Column(
            children: [
              TextField(
                controller: oldPassword,
                style: const TextStyle(color: Colors.grey),
                decoration: InputDecoration(
                  hintText: S.current.change_password_dialog_old_password,
                  hintStyle: const TextStyle(color: Colors.grey),
                  counterStyle: const TextStyle(color: Colors.grey),
                  prefixIcon:
                      const Icon(Icons.lock_outline, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () {
                      oldPassword.clear();
                    },
                  ),
                ),
                maxLength: 10,
              ),
              TextField(
                controller: newPassword,
                style: const TextStyle(color: Colors.grey),
                decoration: InputDecoration(
                  hintText: S.current.change_password_dialog_new_password,
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(S.current.dialog_default_cancel),
          ),
          TextButton(
            onPressed: () {
              if (oldPassword.text.isEmpty) {
                errorDialog(context,
                    content: S.current.change_password_dialog_old_password);
                return;
              }
              if (newPassword.text.isEmpty) {
                errorDialog(context,
                    content: S.current.change_password_dialog_new_password);
                return;
              }
              changePassword(context, oldPassword.text, newPassword.text,
                  back: (msg) {
                informationDialog(context, content: msg, back: () {
                  Navigator.pop(context);
                });
              });
            },
            child: Text(S.current.change_password_dialog_submit),
          ),
        ],
      ),
    );
  });
}
