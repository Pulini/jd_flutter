import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'sap_relocation_picking_state.dart';

class SapRelocationPickingLogic extends GetxController {
  final SapRelocationPickingState state = SapRelocationPickingState();

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
    if (code.isPallet()) {
      state.checkPalletOrLabel(
        pallet: code,
        label: '',
        error: (msg) => errorDialog(content: msg),
      );
      return;
    }
    if (code.isLabel()) {
      if (state.materialList.any((v) => v.labelCode == code)) {
        showSnackBar(title: '错误', message: '条码已扫', isWarning: true);
      } else {
        state.checkPalletOrLabel(
          pallet: '',
          label: code,
          error: (msg) => errorDialog(content: msg),
        );
      }
      return;
    }
  }

  submitPicking({
    required String pickerNumber,
    required ByteData pickerSignature,
    required String userNumber,
    required ByteData userSignature,
    required String warehouse,
  }) {
    state.relocationPicking(
      pickerNumber: pickerNumber,
      pickerSignature: pickerSignature,
      userNumber: userNumber,
      userSignature: userSignature,
      warehouse: warehouse,
      success: (msg)=>successDialog(content: msg),
      error: (msg) => errorDialog(content: msg),
    );
  }
}
