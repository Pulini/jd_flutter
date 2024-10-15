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

  queryCartonLabelInfo() {
    state.queryCartonLabelInfo(
      error: (msg) => errorDialog(content: msg),
    );
  }
}
