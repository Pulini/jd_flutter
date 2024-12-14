import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/process_dispatch_register_info.dart';
import 'package:jd_flutter/fun/dispatching/process_dispatch_register/process_dispatch_register_print_label_view.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'process_dispatch_register_state.dart';

class ProcessDispatchRegisterLogic extends GetxController {
  final ProcessDispatchRegisterState state = ProcessDispatchRegisterState();

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

  queryOrder(String code) {
    if (code.isNotEmpty) {
      state.getProcessWorkCardByBarcode(
        barCode: code,
        error: (msg) => errorDialog(content: msg),
      );
    }
  }

  getLabelInfo(String code) {
    state.queryLabelData(code: code, error: (msg) => errorDialog(content: msg));
  }

  goPrintLabel() {
    if (checkUserPermission('1052501')) {
      Get.to(() => const PrintLabelPage());
    } else {
      informationDialog(content: '缺少贴标操作权限');
    }
  }

  modifyLabelWorker() {
    if (state.labelInfo == null) {
      errorDialog(content: '请先查询标签信息');
      return;
    }
    if (state.select.value < 0) {
      errorDialog(content: '请选择操作员');
    }
    state.modifyLabelWorker(
      success: (msg) => successDialog(content: msg),
      error: (msg) => errorDialog(content: msg),
    );
  }

  deleteLabel(Barcode data) {
    if (checkUserPermission('1052504')) {
      askDialog(
        content: '确定要删除该标签吗？',
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
      informationDialog(content: '缺少贴标删除权限');
    }
  }
}
