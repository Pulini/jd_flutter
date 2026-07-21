import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData;
import 'package:jd_flutter/utils/app_init.dart';
import 'package:jd_flutter/utils/dio_manager.dart';
import 'package:jd_flutter/utils/printer/online_print_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:webview_flutter/webview_flutter.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
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

  void checkAuthorize() {
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

  void applyAuthorization(String reason) {
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

  void addInstructionsLog(String fileItemId) {
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

  void runTask() {

    var dio = Dio()
      ..interceptors.add(DioManager.simpleInterceptors);

    loadingShow('正在生成物料清单预览...');
    ready.value = false;
    dio.post(
      isTestUrl()
          ? 'http://192.168.99.103:9095/m'
          : 'https://erp.goldemperor.com:9051/m',
      queryParameters: {
        'xwl': 'public/interfaces/app/getPalletListHTML',
        'palletNumber': widget.palletTaskList
            .map((v) => v.last.toString())
            .toList()
            .toString(),
        'userName':userInfo?.name,
      },
    ).then((response) {
      loadingDismiss();
      if (jsonDecode(response.data)['successed']) {
        var bytes = jsonDecode(response.data)['blob'];
        Uint8List uint8List = Uint8List.fromList(bytes.cast<int>());
        a4PaperByteList.add(uint8List);
        ready.value = true;
        webViewController.loadHtmlString(jsonDecode(response.data)['data']);
      } else {
        errorDialog(content: response.data['message']);
      }
    });
/*
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
*/
  }

  @override
  void initState() {
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
      child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: const Text('打印清单预览'),
              actions: [
                Obx(() => ready.value
                    ? IconButton(
                        onPressed: () => onLinePrintDialog(
                          a4PaperByteList,
                          PrintType.pdf,
                        ),
                        icon: const Icon(Icons.print, color: Colors.blueAccent),
                      )
                    : const CircularProgressIndicator(),
                ),
              ],
            ),
            body: GetPlatform.isAndroid || GetPlatform.isIOS
                ? WebViewWidget(controller: webViewController)
                : null,
          ),
    );
  }
}

class PdfPrintReview extends StatelessWidget {
  const PdfPrintReview({
    super.key,
    required this.paperList,
  });

  final List<Widget> paperList;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: backgroundColor(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('A4打印预览'),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: paperList.length,
          itemBuilder: (c, i) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: paperList[i],
          ),
        ),
      ),
    );
  }
}




/// 将API返回的HTML内容包裹在完整的文档模板中。
/// 最小注入：仅overflow-y:scroll和viewport meta，不碰宽度/高度/边距等布局属性。
String _buildCompleteHtml(String html) {
  // 最小化：只设overflow-y:scroll强制启用滚动，不干扰原布局
  const scrollCss = 'html,body{overflow-y:scroll!important;overflow-x:hidden!important}';
  const viewportMeta =
      '<meta name="viewport" content="width=device-width,initial-scale=1.0,maximum-scale=5.0,user-scalable=yes">';

  if (html.contains('<html') && html.contains('<head') && html.contains('<body')) {
    // 强制使用我们的viewport：先删除API自带的viewport(其width=980/1200会导致布局视口过宽、内容超出控件)，
    // 再把我们的viewport+样式插到</head>前，使其成为“最后一个viewport”，浏览器以其为准
    html = html.replaceAll(
        RegExp(r'<meta[^>]*viewport[^>]*>', caseSensitive: false), '');
    html = html.replaceFirst(
        '</head>', '$viewportMeta<style>$scrollCss</style></head>');
    return html;
  }
  return '''
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
$viewportMeta
<style>$scrollCss</style>
</head>
<body>
$html
</body>
</html>''';
}

/// 本地HTTP Server，用于向WebView提供HTML内容。
/// file:// 在Android上被安全策略拦截(ERR_ACCESS_DENIED)，
/// data: URI 在鸿蒙hwbr_engine上布局异常(ShouldDoAdaptiveRelayout returns 0)，
/// 通过127.0.0.1 HTTP服务可同时绕过两类限制。
class _LocalHtmlServer {
  static _LocalHtmlServer? _instance;
  HttpServer? _server;
  int _port = 0;
  String _html = '';

  static _LocalHtmlServer get instance => _instance ??= _LocalHtmlServer._();

  _LocalHtmlServer._();

  bool get isRunning => _server != null;

  Future<String> serve(String html) async {
    _html = html;
    if (_server != null) return 'http://127.0.0.1:$_port/';
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _port = _server!.port;
    _server!.listen((request) {
      debugPrint('_LocalHtmlServer request: ${request.uri}');
      if (request.uri.path == '/' || request.uri.path.isEmpty) {
        final bytes = utf8.encode(_html);
        request.response
          ..statusCode = 200
          ..headers.set('Content-Type', 'text/html; charset=utf-8')
          ..headers.set('Content-Length', bytes.length.toString())
          ..headers.set('Cache-Control', 'no-cache, no-store, must-revalidate')
          ..headers.set('Pragma', 'no-cache')
          ..headers.set('Expires', '0')
          ..headers.set('Connection', 'close')
          ..add(bytes);
      } else {
        request.response.statusCode = 404;
      }
      request.response.close();
    });
    return 'http://127.0.0.1:$_port/';
  }

  void update(String html) {
    _html = html;
  }

  void close() {
    _server?.close();
    _server = null;
    _instance = null;
  }
}

/// 通过本地HTTP Server加载HTML到WebView。
/// loadRequest + http://127.0.0.1:PORT/ 在hwbr_engine下能正常渲染；
/// loadHtmlString则触发"url has no host"导致空白。
Future<void> _loadHtmlViaServer(WebViewController controller, String html) async {
  final completeHtml = _buildCompleteHtml(html);
  debugPrint(
    '_loadHtmlViaServer: rawLen=${html.length}, completeLen=${completeHtml.length}, '
        'preview=${completeHtml.substring(0, completeHtml.length < 200 ? completeHtml.length : 200)}',
  );
  final url = await _LocalHtmlServer.instance.serve(completeHtml);
  controller.loadRequest(Uri.parse(url));
}

/// 鸿蒙2.0 hwbr_engine兼容：本地HTTP Server加载HTML
void loadFixedHtml(WebViewController controller, String html) {
  _loadHtmlViaServer(controller, html);
}
