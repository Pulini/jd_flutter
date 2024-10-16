import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/carton_label_scan_progress_info.dart';

import '../../../utils/web_api.dart';
import '../../../widget/dialogs.dart';
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

  getProgressDetail(
    CartonLabelScanProgressInfo data,
    Function(List<CartonLabelScanProgressDetailInfo>) detail,
  ) {
    state.getCartonLabelScanHistoryDetail(
      id: data.interID ?? 0,
      success: detail,
      error: (msg) => errorDialog(content: msg),
    );
  }
}
