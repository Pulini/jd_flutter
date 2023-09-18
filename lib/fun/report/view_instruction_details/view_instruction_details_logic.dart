import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../http/web_api.dart';
import '../../../route.dart';

class ViewInstructionDetailsLogic extends GetxController {
  TextEditingController textControllerInstruction = TextEditingController();

  var pickerControllerProcessFlow = OptionsPickerController(
    PickerType.mesProcessFlow,
    saveKey:
        '${RouteConfig.viewInstructionDetails.name}${PickerType.mesProcessFlow}',
  );

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
  void onClose() {
    super.onClose();
    webViewController.clearLocalStorage();
  }

  queryPDF() {
    if (textControllerInstruction.text.trim().isEmpty) {
      errorDialog(content: '请输入指令单号');
      return;
    }
    httpGet(
      loading: '正在查询指令明细...',
      method: webApiGetInstructionDetailsFile,
      query: {
        'MoNo': textControllerInstruction.text,
        'ProcessFlowID': pickerControllerProcessFlow.selectedId.value,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        Get.back();
        webViewController.clearCache();
        webViewController.loadRequest(Uri.parse(response.data));
      } else {
        errorDialog(content: response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
