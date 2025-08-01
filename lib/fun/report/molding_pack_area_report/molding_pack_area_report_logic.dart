import 'package:get/get.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'molding_pack_area_detail_report_view.dart';
import 'molding_pack_area_report_state.dart';

class MoldingPackAreaReportPageLogic extends GetxController {
  final MoldingPackAreaReportPageState state = MoldingPackAreaReportPageState();

  query({
    required String startDate,
    required String endDate,
    required List<String> packAreaIDs,
    required String typeBody,
    required String instruction,
    required String orderNumber,
  }) {
    state.getMoldingPackAreaReport(
      startDate: startDate,
      endDate: endDate,
      packAreaIDs: packAreaIDs,
      typeBody: typeBody,
      instruction: instruction,
      orderNumber: orderNumber,
      error: (msg) => errorDialog(content: msg),
    );
  }

  getDetails(int interID, String clientOrderNumber) {
    state.getMoldingPackAreaReportDetail(
      interID: interID,
      clientOrderNumber: clientOrderNumber,
      success: () => Get.to(() => const MoldingPackAreaDetailReportPage()),
      error: (msg) => errorDialog(content: msg),
    );
  }
}
