import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:jd_flutter/fun/warehouse/out/material_label_scan/material_label_scan_state.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

class MaterialLabelScanLogic extends GetxController {
  final MaterialLabelScanState state = MaterialLabelScanState();

  void query({
    required String startDate,
    required String endDate,
  }) {
    state.getQueryList(
        startDate: startDate, endDate: endDate, error: (String s) {});
  }

  void queryDetail({
    required String workCardNo,
  }) {
    state.getQueryDetail(workCardNo: workCardNo);
  }

  void queryBarCodeDetail({
    required String barCode,
  }) {
    state.canScan =false;
    state.getQueryBarCodeDetail(
        barCode: barCode,
        success: () {
          showScanTips();
          state.canScan = true;
        },
        error: (String s) {
          showSnackBar(message: s);
          state.canScan = true;
        });
  }
}
