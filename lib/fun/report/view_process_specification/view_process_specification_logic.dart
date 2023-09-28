import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../http/web_api.dart';
import '../../../widget/dialogs.dart';
import 'view_process_specification_state.dart';

class ViewProcessSpecificationLogic extends GetxController {
  final ViewProcessSpecificationState state = ViewProcessSpecificationState();
  var textControllerTypeBody = TextEditingController();

  var webViewController = WebViewController()
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
        onWebResourceError: (WebResourceError error) {
          logger.f(
              '${Get.isDialogOpen}  onWebResourceError------${error.toString()}');
          if (Get.isDialogOpen == true) Get.back();
        },
      ),
    );

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  queryProcessSpecification() {

  }
}
