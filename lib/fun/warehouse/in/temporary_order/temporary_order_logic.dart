import 'package:get/get.dart';
import 'package:jd_flutter/fun/warehouse/in/temporary_order/temporary_order_detail_view.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'temporary_order_state.dart';

class TemporaryOrderLogic extends GetxController {
  final TemporaryOrderState state = TemporaryOrderState();

  queryTemporaryOrders({
    required String startDate,
    required String endDate,
    required String temporaryNo,
    required String productionNumber,
    required String factoryType,
    required String supplierName,
    required String materialCode,
    required String factoryArea,
    required String factoryNo,
    required String userNumber,
    required String trackNo,
  }) {
    state.getTemporaryList(
      startDate: startDate,
      endDate: endDate,
      temporaryNo: temporaryNo,
      productionNumber: productionNumber,
      factoryType: factoryType,
      supplierName: supplierName,
      materialCode: materialCode,
      factoryArea: factoryArea,
      factoryNo: factoryNo,
      userNumber: userNumber,
      trackNo: trackNo,
      error: (msg) => errorDialog(content: msg),
    );
  }

  deleteTemporaryOrder({
    required String temporaryNo,
    required String reason,
    required Function(String) success,
  }) {
    state.deleteTemporaryOrder(
      reason: reason,
      temporaryNo: temporaryNo,
      success: success,
      error: (msg) => errorDialog(content: msg),
    );
  }

  viewTemporaryOrderDetail({
    required String temporaryNo,
    required String materialCode,
  }) {
    state.getTemporaryOrderDetail(
      temporaryNo: temporaryNo,
      materialCode: materialCode,
      success:()=>Get.to(()=>const TemporaryOrderDetailPage()),
      error: (msg) => errorDialog(content: msg),
    );
  }
}
