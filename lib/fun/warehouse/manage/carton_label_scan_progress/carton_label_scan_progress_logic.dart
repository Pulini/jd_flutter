import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/carton_label_scan_progress_info.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'carton_label_scan_progress_detail_view.dart';
import 'carton_label_scan_progress_state.dart';

class CartonLabelScanProgressLogic extends GetxController {
  final CartonLabelScanProgressState state = CartonLabelScanProgressState();

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

  queryScanHistory(String orderNo) {
    state.getCartonLabelScanHistory(
      orderNo: orderNo,
      error: (msg) => errorDialog(content: msg),
    );
  }

  getProgressDetail(CartonLabelScanProgressInfo data) {
    state.getCartonLabelScanHistoryDetail(
      id: data.interID ?? 0,
      success: () => Get.to(() => const CartonLabelScanProgressDetailView()),
      error: (msg) => errorDialog(content: msg),
    );
  }
}
