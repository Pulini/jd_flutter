import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../utils/utils.dart';
import '../utils/web_api.dart';
import 'custom_widget.dart';
import 'dialogs.dart';

class WebPage extends StatelessWidget {
  WebPage({super.key, required this.title, required this.url});

  final String url;
  final String title;

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



  @override
  Widget build(BuildContext context) {
    if (GetPlatform.isAndroid || GetPlatform.isIOS) {
      webViewController
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.transparent)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              logger.f('onPageStarted------$url');
              loadingDialog('加載中');
            },
            onPageFinished: (String url) {
              logger.f('${Get.isDialogOpen}  onPageFinished------$url');
              if (Get.isDialogOpen == true) Get.back();
            },
            onHttpError: (HttpResponseError error) {
              logger.f(
                  '${Get.isDialogOpen}  onHttpError------${error.response?.statusCode}');
              if (Get.isDialogOpen == true) Get.back();
            },
            onWebResourceError: (WebResourceError error) {
              logger.f(
                  '${Get.isDialogOpen}  onWebResourceError------${error.description}');
              if (Get.isDialogOpen == true) Get.back();
            },
          ),
        );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAuthorize();
    });
    return Container(
      decoration: backgroundColor,
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
