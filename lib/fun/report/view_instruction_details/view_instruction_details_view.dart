import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'view_instruction_details_logic.dart';

class ViewInstructionDetailsPage extends StatefulWidget {
  const ViewInstructionDetailsPage({super.key});

  @override
  State<ViewInstructionDetailsPage> createState() =>
      _ViewInstructionDetailsPageState();
}

class _ViewInstructionDetailsPageState
    extends State<ViewInstructionDetailsPage> {
  final logic = Get.put(ViewInstructionDetailsLogic());
  final state = Get.find<ViewInstructionDetailsLogic>().state;
  var tecInstruction = TextEditingController();
  var pickerControllerProcessFlow = OptionsPickerController(
    PickerType.mesProcessFlow,
    saveKey:
        '${RouteConfig.viewInstructionDetails.name}${PickerType.mesProcessFlow}',
  );

  late WebViewController webViewController;

  @override
  void initState() {
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
              loadingDismiss();
            },
            onWebResourceError: (WebResourceError error) {
              loadingDismiss();
            },
          ),
        );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      queryWidgets: [
        EditText(
          hint: 'view_instruction_details_query_hint'.tr,
          controller: tecInstruction,
        ),
        OptionsPicker(pickerController: pickerControllerProcessFlow),
      ],
      query: () => logic.queryPDF(
        processFlowId: pickerControllerProcessFlow.selectedId.value,
        instruction: tecInstruction.text,
        loadUri: (uri) {
          webViewController.clearCache();
          webViewController.loadRequest(uri);
        },
      ),
      body: GetPlatform.isAndroid || GetPlatform.isIOS
          ? WebViewWidget(controller: webViewController)
          : Container(),
    );
  }

  @override
  void dispose() {
    if (GetPlatform.isAndroid || GetPlatform.isIOS) {
      webViewController.clearLocalStorage();
    }
    Get.delete<ViewInstructionDetailsLogic>();
    super.dispose();
  }
}
