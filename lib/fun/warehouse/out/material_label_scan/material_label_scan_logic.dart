import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:jd_flutter/fun/warehouse/out/material_label_scan/material_label_scan_state.dart';

class MaterialLabelScanLogic extends GetxController {
  final MaterialLabelState state = MaterialLabelState();

  void query({
    required String startDate,
    required String endDate,
  }) {
    state.getQueryList(startDate: startDate, endDate: endDate, error: (String s) {});
  }
}
