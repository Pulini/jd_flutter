import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/pack_order_list_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'pack_order_list_state.dart';

class PackOrderListLogic extends GetxController {
  final PackOrderListState state = PackOrderListState();

  void queryPackOrders({
    required String dispatchOrderNo,
    required String typeBody,
    required String startDate,
    required String endDate,
  }) {
    if (dispatchOrderNo.isEmpty && typeBody.isEmpty) {
      errorDialog(content: 'part_dispatch_pack_order_no_input_tips'.tr);
      return;
    }
    state.getPackOrderList(
      dispatchOrderNo: dispatchOrderNo,
      typeBody: typeBody,
      startDate: startDate,
      endDate: endDate,
      success: () {},
      error: (msg) => errorDialog(content: msg),
    );
  }

  void deletePackOrder({
    required OrderPackageInfo data,
    required Function() refresh,
  }) {
    if (checkUserPermission('601080103')) {
      askDialog(
        content: 'part_dispatch_pack_order_delete_order_tips'.tr,
        confirm: () => state.deletePackOrder(
          id: data.packageId!,
          success: (msg) => successDialog(content: msg, back: refresh),
          error: (msg) => errorDialog(content: msg),
        ),
      );
    } else {
      errorDialog(content: 'part_dispatch_pack_order_no_delete_permission'.tr);
    }
  }

  String getOrderPackProfile(int? orderPackProfileID) =>
      state.packProfileList
          .firstWhere((v) => v.packProfileID == orderPackProfileID)
          .packProfileName ??
      '';

  void modifyOrderPackProfile({
    required int packOrderID,
    required int packProfileID,
    required double capacityQty,
    required Function() refresh,
  }) {
    state.modifyOrderPackProfile(
      packOrderID: packOrderID,
      packProfileID: packProfileID,
      capacityQty: capacityQty,
      success: (msg) => successDialog(content: msg,back: refresh),
      error: (msg) => errorDialog(content: msg),
    );
  }
}
