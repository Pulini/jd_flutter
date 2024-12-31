import 'package:get/get.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'sap_wms_split_label_state.dart';

class SapWmsSplitLabelLogic extends GetxController {
  final SapWmsSplitLabelState state = SapWmsSplitLabelState();

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

  scanCode(String code) {
    state.getLabels(
      labelNumber: code,
      error: (msg) => errorDialog(content: msg),
    );
  }
}
