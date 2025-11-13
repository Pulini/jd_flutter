import 'dart:convert';
import 'dart:core';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData;
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/printer/online_print_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
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

class WebPrinter extends StatefulWidget {
  const WebPrinter({
    super.key,
    required this.palletTaskList,
  });

  final List<List> palletTaskList;

  @override
  State<WebPrinter> createState() => _WebPrinterState();
}

class _WebPrinterState extends State<WebPrinter> {
  final webViewController = WebViewController();
  var a4PaperByteList = <Uint8List>[];
  var ready = false.obs;

  runTask() {
    var dio = Dio()
      ..interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          options.print();
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (response.data is String) {
            logger.f('Response data: ${response.data}');
          } else {
            loggerF(response.data);
          }
          handler.next(response);
        },
        onError: (DioException e, handler) {
          logger.f('error: $e');
          handler.next(e);
        },
      ));

    loadingShow('正在生成物料清单预览...');
    dio.post(
      isTestUrl()
          ? 'https://mestest.goldemperor.com:9099/m'
          : 'https://wb.goldemperor.com:8096/m',
      queryParameters: {
        'xwl': 'public/interfaces/app/getPalletListHTML',
        'palletNumber': widget.palletTaskList
            .map((v) => v.last.toString())
            .toList()
            .toString(),
      },
    ).then((response) {
      loadingDismiss();
      webViewController.loadHtmlString(jsonDecode(response.data)['data']);
    });
    ready.value = false;

    for (var task in widget.palletTaskList) {
      (task.first as Future<List<pw.Widget>>).then((pdfWidgets) async {
        var pdf = pw.Document();
        for (var widget in pdfWidgets) {
          pdf.addPage(pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(0),
            build: (c) => widget,
          ));
        }
        a4PaperByteList.add(await pdf.save());
      });
    }
    ready.value = true;
  }

  @override
  void initState() {
    if (GetPlatform.isAndroid || GetPlatform.isIOS) {
      logger.f('------到这儿来2------');
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
      WidgetsBinding.instance.addPostFrameCallback((_) => runTask());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: backgroundColor(),
      child: Obx(() => Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Text('打印清单预览'),
              actions: [
                ready.value
                    ? IconButton(
                        onPressed: () => onLinePrintDialog(
                          a4PaperByteList,
                          PrintType.pdf,
                        ),
                        icon: const Icon(Icons.print, color: Colors.blueAccent),
                      )
                    : const CircularProgressIndicator(),
              ],
            ),
            body: GetPlatform.isAndroid || GetPlatform.isIOS
                ? WebViewWidget(controller: webViewController)
                : null,
          )),
    );
  }
}
