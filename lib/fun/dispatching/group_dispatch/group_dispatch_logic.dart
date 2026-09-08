import 'package:get/get.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'group_dispatch_state.dart';

class GroupDispatchLogic extends GetxController {
  final GroupDispatchState state = GroupDispatchState();

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void queryOrder(String order) {
    state.getProcessWorkCardInfo(
      order,
      success: (data){
        state.titleInfo.value=data.processWorkCardInfo;
        state.partList.value=data.componentList;

      },
      error: (msg) => errorDialog(content: msg),
    );
  }
}
