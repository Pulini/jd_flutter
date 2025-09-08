import 'package:get/get.dart';
import 'package:jd_flutter/fun/report/view_instruction_details/view_instruction_details_state.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class ViewInstructionDetailsLogic extends GetxController {
  final ViewInstructionDetailsState state = ViewInstructionDetailsState();

  queryPDF({
    required String processFlowId,
    required String instruction,
    required Function(Uri) loadUri,
  }) {
    if (instruction.isEmpty) {
      errorDialog(content: 'view_instruction_details_query_hint'.tr);
      return;
    }
    state.getInstructionDetailsFile(
      processFlowID: processFlowId,
      instruction: instruction,
      success: (uri) {
        if (GetPlatform.isAndroid || GetPlatform.isIOS) {
          loadUri.call(uri);
        } else {
          goLaunch(uri);
        }
      },
      error: (msg) => errorDialog(content: msg),
    );
  }
}
