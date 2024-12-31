import 'package:get/get.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'sap_wms_reprint_labels_state.dart';

class SapWmsReprintLabelsLogic extends GetxController {
  final SapWmsReprintLabelsState state = SapWmsReprintLabelsState();

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

  scanCode({
    required String warehouse,
    required String code,
  }) {
    if (code.isPallet()) {
      if (state.labelList.isEmpty ||
          state.labelList.every((v) => v.palletNumber != code)) {
        state.getLabels(
          warehouse: warehouse,
          palletNumber: code,
          error: (msg) => errorDialog(content: msg),
        );
      } else {
        var pallet = state.labelList.where((v) => v.palletNumber == code);
        var isAll = pallet.every((v) => v.select);
        for (var v in pallet) {
          v.select = !isAll;
        }
        state.labelList.refresh();
      }
      return;
    }
    if (code.isLabel()) {
      if (state.labelList.isEmpty) {
        state.getLabels(
          warehouse: warehouse,
          labelNumber: code,
          error: (msg) => errorDialog(content: msg),
        );
      } else {
        state.labelList
            .where((v) => v.labelNumber == code)
            .forEach((v) => v.select = !v.select);
        state.labelList.refresh();
      }
      return;
    }
    errorDialog(content: '请扫描正确的条码！');
  }

   clean() {
    state.labelList.clear();
    state.palletNumber.value='';
   }
}
