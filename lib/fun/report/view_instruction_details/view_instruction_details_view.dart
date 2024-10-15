import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../widget/custom_widget.dart';
import '../../../widget/edit_text_widget.dart';
import '../../../widget/picker/picker_view.dart';
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



  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      queryWidgets: [
        EditText(hint: 'view_instruction_details_query_hint'.tr, onChanged: (v) => state.tetInstruction = v),
        OptionsPicker(pickerController: logic.pickerControllerProcessFlow),
      ],
      query: () => logic.queryPDF(),
      body: GetPlatform.isAndroid || GetPlatform.isIOS
          ? WebViewWidget(controller: logic.webViewController)
          : null,
    );
  }

  @override
  void dispose() {
    Get.delete<ViewInstructionDetailsLogic>();
    super.dispose();
  }
}
