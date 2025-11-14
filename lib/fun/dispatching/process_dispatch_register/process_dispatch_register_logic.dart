import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/process_dispatch_register_info.dart';
import 'package:jd_flutter/fun/dispatching/process_dispatch_register/process_dispatch_register_print_label_view.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'process_dispatch_register_state.dart';

class ProcessDispatchRegisterLogic extends GetxController {
  final ProcessDispatchRegisterState state = ProcessDispatchRegisterState();



  void queryOrder(String code) {
    if (code.isNotEmpty) {
      state.getProcessWorkCardByBarcode(
        barCode: code,
        error: (msg) => errorDialog(content: msg),
      );
    }
  }

  void getLabelInfo(String code) {
    state.queryLabelData(code: code, error: (msg) => errorDialog(content: msg));
  }

  void goPrintLabel() {
    if (checkUserPermission('1052501')) {
      Get.to(() => const PrintLabelPage());
    } else {
      msgDialog(content: 'process_dispatch_register_no_permission_tips'.tr);
    }
  }

  void modifyLabelWorker() {
    if (state.labelInfo == null) {
      errorDialog(content: 'process_dispatch_register_no_label_info_tips'.tr);
      return;
    }
    if (state.select.value < 0) {
      errorDialog(content: 'process_dispatch_register_select_operator_tips'.tr);
    }
    state.modifyLabelWorker(
      success: (msg) => successDialog(content: msg),
      error: (msg) => errorDialog(content: msg),
    );
  }

  void deleteLabel(Barcode data) {
    if (checkUserPermission('1052504')) {
      askDialog(
        content: 'process_dispatch_register_delete_tips'.tr,
        confirm: () => state.deleteLabel(
          barCode: data.barCode ?? '',
          success: (msg) {
            state.labelList.removeWhere((v) => v.barCode == data.barCode);
            successDialog(content: msg);
          },
          error: (msg) => errorDialog(content: msg),
        ),
      );
    } else {
      msgDialog(content: 'process_dispatch_register_no_delete_permission'.tr);
    }
  }
}
