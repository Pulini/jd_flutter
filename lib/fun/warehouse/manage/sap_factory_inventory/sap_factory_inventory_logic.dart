import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'sap_factory_inventory_state.dart';

class SapScanCodeInventoryLogic extends GetxController {
  final SapScanCodeInventoryState state = SapScanCodeInventoryState();


  queryInventoryOrder({
    required bool isScan,
    required String factory,
    required String warehouse,
  }) {
    state.getInventoryPalletList(
      isScan:isScan,
      factory: factory,
      warehouse: warehouse,
      error: (msg) => errorDialog(content: msg),
    );
  }


  scanCode(String code) {
    for (var v in state.palletList) {
      for (var v2 in v) {
        if (v2.labelId == code || v2.palletNumber == code) {
          v2.isSelected.value = true;
        }
      }
    }
    state.palletList.refresh();
  }

  submitScanInventory({
    required WorkerInfo workerInfo,
    required ByteData signature,
    required Function() finish,
  }) {
    state.submitInventory(
      isScan: true,
      signature: signature,
      signatureNumber: workerInfo.empCode ?? '',
      success: (msg) => successDialog(
        content: msg,
        back: () =>finish.call(),
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }
}
