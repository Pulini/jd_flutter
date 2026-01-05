import 'package:get/get.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'part_production_dispatch_state.dart';

class PartProductionDispatchLogic extends GetxController {
  final PartProductionDispatchState state = PartProductionDispatchState();

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

  void queryOrders({
    required String startTime,
    required String endTime,
    required String instruction,
  }) {
    state.getPartProductionDispatchOrderList(
      startTime: startTime,
      endTime: endTime,
      instruction: instruction,
      error: (msg) => errorDialog(content: msg),
    );
  }

  void changeClosedStatus(bool isSelect) {
    state.isSelectedClosed.value = isSelect;
    spSave('${Get.currentRoute}/isSelectedClosed', isSelect);
  }
}
