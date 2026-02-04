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
      errorDialog(content: '请输入派工单号或型体');
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
    required PackOrderInfo data,
    required Function() refresh,
  }) {
    if (checkUserPermission('601080103')) {
      askDialog(
        content: '确定要删除此包装清单吗？',
        confirm: () => state.deletePackOrder(
          id: data.packageId!,
          success: (msg) => successDialog(content: msg, back: refresh),
          error: (msg) => errorDialog(content: msg),
        ),
      );
    } else {
      errorDialog(content: '没有包装清单删除权限！');
    }
  }
}
