import 'package:get/get.dart';

import '../../../../widget/dialogs.dart';
import 'carton_label_scan_state.dart';

class CartonLabelScanLogic extends GetxController {
  final CartonLabelScanState state = CartonLabelScanState();

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

  queryCartonLabelInfo(String code) {
    state.queryCartonLabelInfo(
      code: code,
      error: (msg) => errorDialog(content: msg),
    );
  }

  int labelTotal() {
    return state.cartonInsideLabelList
        .fold(0, (total, next) => total + next.labelCount!);
  }

  int scannedLabelTotal() {
    return state.cartonInsideLabelList
        .fold(0, (total, next) => total + next.scanned);
  }

  cleanAll(Function refresh) {
    state.cartonInsideLabelList.value=[];
    state.cartonLabel.value='';
    state.cartonLabelInfo=null;
    refresh.call();
  }

  cleanScanned() {
    for (var v in state.cartonInsideLabelList.value) {
      v.scanned=0;
    }
    state.cartonInsideLabelList.refresh();
  }
}
