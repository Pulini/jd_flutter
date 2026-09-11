import 'package:get/get.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'confirm_packing_method_state.dart';

class ConfirmPackingMethodLogic extends GetxController {
  final ConfirmPackingMethodState state = ConfirmPackingMethodState();

  void queryDispatchOrderInfo({
    required String barCode,
    Function()? success,
  }) {
    state.getPartDispatchConfirmInfo(
      barCode: barCode,
      success: success,
      error: (msg) => errorDialog(content: msg),
    );
  }

  void getOrderInfoFromArguments() {
    state.needBack = true;
    state.getPartDispatchConfirmInfo(
      barCode: Get.arguments['BarCode'],
      error: (msg) => errorDialog(content: msg),
    );
  }

  void modifyOrderPackProfile({
    required int packProfileID,
    required double capacityQty,
  }) {
    state.modifyOrderPackProfile(
      packProfileID: packProfileID,
      capacityQty: capacityQty,
      success: (msg) => state.needBack
          ? successDialog(content: msg, back: () => Get.back(result: true))
          : askDialog(
              content: msg,
              title: 'part_dispatch_confirm_packing_method_modify_success'.tr,
              confirmText: 'part_dispatch_confirm_packing_method_to_pack_order_list'.tr,
              confirm: () => Get.offAndToNamed(
                RouteConfig.packOrderList.name,
                arguments: {'barCode': state.barCode},
              ),
              cancel: () => queryDispatchOrderInfo(
                barCode: state.barCode,
              ),
            ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  void refreshPartInfo(Function() finishRefresh) {
    queryDispatchOrderInfo(barCode: state.barCode, success: finishRefresh);
  }
}
