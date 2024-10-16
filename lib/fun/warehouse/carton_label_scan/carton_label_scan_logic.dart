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
    state.cartonInsideLabelList.value = [];
    state.cartonLabel.value = '';
    state.cartonLabelInfo = null;
    refresh.call();
  }

  cleanScanned() {
    for (var v in state.cartonInsideLabelList) {
      v.scanned = 0;
    }
    state.cartonInsideLabelList.refresh();
  }

  scan({
    required String code,
    required Function(String) outsideCode,
    required Function(String) insideCode,
  }) {
    if (state.cartonLabel.value.isEmpty) {
      outsideCode.call(code);
      queryCartonLabelInfo(code);
    } else {
      try {
        var exist = state.cartonInsideLabelList.singleWhere(
          (v) => v.priceBarCode == code,
        );
        if (exist.scanned < exist.labelCount!) {
          insideCode.call(code);
          exist.scanned++;
          state.cartonInsideLabelList.refresh();
        } else {
          errorDialog(content: '条码[$code]已扫满，请确认是否放错或重复扫码。');
        }
      } catch (e) {
        errorDialog(content: '条码[$code]不是外箱对应数据，请检查是否放错。');
      }
    }
  }

  submit(Function refresh) {
    state.submitScannedCartonLabel(
      success: (msg) {
        successDialog(content: msg,back: (){
          cleanAll(refresh);
        });
      },
      error: (msg) => errorDialog(content: msg),
    );
  }
}
