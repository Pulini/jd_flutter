import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'custom_widget.dart';
import 'dialogs.dart';

class WebPage extends StatelessWidget {
  WebPage({
    super.key,
    this.title = '',
    this.fileId = '',
    this.needCheckAuthorize = false,
    required this.url,
  });

  final String url;
  final String title;
  final String fileId;
  final bool needCheckAuthorize;

  final webViewController = WebViewController();

  checkAuthorize() {
    httpPost(
      loading: '正在查询授权信息...',
      method: webApiCheckAuthorize,
      params: {'androidID': getDeviceID()},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        if (GetPlatform.isAndroid || GetPlatform.isIOS) {
          webViewController.clearCache();
          webViewController.loadRequest(Uri.parse(url));
        } else {
          Get.back();
          goLaunch(Uri.parse(url));
        }
      } else {
        if (response.data == '0') {
          reasonInputPopup(
            title: [
              const Center(
                child: Text(
                  '授权申请',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              )
            ],
            hintText: '请填写授权申请',
            isCanCancel: true,
            confirm: applyAuthorization,
            cancel: () => Get.back(),
          );
        } else {
          errorDialog(
              content: response.message ?? '查询失败', back: () => Get.back());
        }
      }
    });
  }

  applyAuthorization(String reason) {
    httpPost(
      loading: '正在提交授权申请...',
      method: webApiAuthorizedApplication,
      body: {
        'Reason': reason,
        'RequestUser': userInfo?.userID,
        'EmpNumber': userInfo?.number,
        'EmpName': userInfo?.name,
        'Code': getDeviceID(),
        'RequestMachineName': getDeviceName(),
        'RequestNotes': '',
      },
    ).then(
      (response) {
        if (response.resultCode == resultSuccess) {
          successDialog(content: response.message, back: () => Get.back());
        } else {
          errorDialog(content: response.message ?? '授权失败');
        }
      },
    );
  }

  addInstructionsLog(String fileItemId) {
    if (fileItemId.isEmpty) return;
    httpPost(
      method: webApiInstructionsLog,
      params: {
        'ItemID': fileItemId,
        'UserID': userInfo?.userID,
      },
    ).then((response) {
      showSnackBar(
        message: response.message ?? '',
        isWarning: response.resultCode == resultError,
      );
    });
  }

  // 直接加载URL，保持原始URL不变
  void _loadUrl(String urlString) {
    // 对于包含%u的特殊URL，使用特殊方式加载以避免WebView自动编码
    if (urlString.contains('%u')) {
      // 使用HTML和JavaScript直接加载，避免WebView对URL进行编码
      webViewController.loadHtmlString(_generateHtmlForUrl(urlString));
    } else {
      // 普通URL直接加载
      webViewController.loadRequest(Uri.parse(urlString));
    }
  }

  String _generateHtmlForUrl(String urlString) {
    // 使用iframe加载URL
    return '''
  <!DOCTYPE html>
  <html>
  <head>
      <meta charset="UTF-8">
      <style>
        body, html {
          margin: 0;
          padding: 0;
          height: 100%;
          overflow: hidden;
        }
        iframe {
          border: none;
          width: 100%;
          height: 100%;
        }
      </style>
  </head>
  <body>
      <iframe src="$urlString"></iframe>
  </body>
  </html>
  ''';
  }

  @override
  Widget build(BuildContext context) {
    if (GetPlatform.isAndroid || GetPlatform.isIOS) {
      webViewController
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.transparent)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              debugPrint('onPageStarted------$url');
              loadingShow('加载中');
            },
            onPageFinished: (String url) {
              debugPrint('onPageFinished------$url');
              loadingDismiss();
              addInstructionsLog(fileId);
            },
            onHttpError: (HttpResponseError error) {
              debugPrint('onHttpError------${error.response?.statusCode}');
              debugPrint('onHttpError URL------${error.response?.uri}');
              loadingDismiss();
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint('onWebResourceError------${error.description}');
              debugPrint('onWebResourceError Type------${error.errorType}');
              debugPrint('onWebResourceError URL------${error.url}');
              loadingDismiss();
            },
          ),
        );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (needCheckAuthorize) {
        checkAuthorize();
      } else {
        webViewController.clearCache().then((_) => _loadUrl(url));
      }
    });
    return Container(
      decoration: backgroundColor(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(title),
        ),
        body: GetPlatform.isAndroid || GetPlatform.isIOS
            ? WebViewWidget(controller: webViewController)
            : null,
      ),
    );
  }
}
