import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:jd_flutter/bean/http/response/material_label_scan_info.dart';
import 'package:jd_flutter/fun/warehouse/out/material_label_scan/material_label_scan_state.dart';
import 'package:jd_flutter/utils/web_api.dart';

class MaterialLabelScanLogic extends GetxController {
  final MaterialLabelState state = MaterialLabelState();

  void query({
    required String startDate,
    required String endDate,
  }) {
    state.getQueryList(startDate: startDate, endDate: endDate, error: (String s) {});
  }
}
