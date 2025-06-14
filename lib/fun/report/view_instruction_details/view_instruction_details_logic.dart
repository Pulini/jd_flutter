import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/report/view_instruction_details/view_instruction_details_state.dart';
import 'package:jd_flutter/route.dart';

import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';


class ViewInstructionDetailsLogic extends GetxController {
  final ViewInstructionDetailsState state = ViewInstructionDetailsState();

  var pickerControllerProcessFlow = OptionsPickerController(
    PickerType.mesProcessFlow,
    saveKey:
        '${RouteConfig.viewInstructionDetails.name}${PickerType.mesProcessFlow}',
  );

  late WebViewController webViewController;

  @override
  onInit() {
    if (GetPlatform.isAndroid || GetPlatform.isIOS) {
      webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.transparent)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              loadingShow('view_instruction_details_reading'.tr);
            },
            onPageFinished: (String url) {
              if (Get.isDialogOpen == true) Get.back();
            },
            onWebResourceError: (WebResourceError error) {
              if (Get.isDialogOpen == true) Get.back();
            },
          ),
        );
    }
    super.onInit();
  }

  @override
  onClose() {
    if (GetPlatform.isAndroid || GetPlatform.isIOS) {
      webViewController.clearLocalStorage();
    }
  }

  queryPDF() {
    if (state.tetInstruction.isEmpty) {
      errorDialog(content: 'view_instruction_details_query_hint'.tr);
      return;
    }
    state.getInstructionDetailsFile(
      processFlowID: pickerControllerProcessFlow.selectedId.value,
      success: (uri) {
        if (GetPlatform.isAndroid || GetPlatform.isIOS) {
          webViewController.clearCache();
          webViewController.loadRequest(uri);
        } else {
          goLaunch(uri);
        }
      },
      error: (msg) => errorDialog(content: msg),
    );
  }
}
