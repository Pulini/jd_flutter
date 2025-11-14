import 'package:get/get.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'worker_production_detail_state.dart';

class WorkerProductionDetailLogic extends GetxController {
  final WorkerProductionDetailState state = WorkerProductionDetailState();

  void query({
    required String worker,
    required String beginDate,
    required String endDate,
    required String itemID,
    required String reportType,
  }) {
    state.getProductionReport(
      worker: worker,
      beginDate: beginDate,
      endDate: endDate,
      itemID: itemID,
      reportType: reportType,
      error: (msg) => errorDialog(content: msg),
    );
  }
}
