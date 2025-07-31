import 'package:get/get.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'purchase_order_reversal_state.dart';

class PurchaseOrderReversalLogic extends GetxController {
  final PurchaseOrderReversalState state = PurchaseOrderReversalState();

  query({
    required String startDate,
    required String endDate,
    required String supplierNumber,
    required String factory,
    required String warehouse,
    required String materialVoucher,
    required String typeBody,
    required String salesOrderNo,
    required String purchaseOrder,
    required String materielCode,
  }) {
    state.getReceiptVoucherList(
      startDate: startDate,
      endDate: endDate,
      supplierNumber: supplierNumber,
      factory: factory,
      warehouse: warehouse,
        materialVoucher:materialVoucher,
        typeBody:typeBody,
        salesOrderNo:salesOrderNo,
        purchaseOrder:purchaseOrder,
        materielCode:materielCode,
      error: (msg) => errorDialog(content: msg),
    );
  }

  reversal(Function(String) refresh) {
    var selectList = state.orderList.where((v) => v.isSelect.value).toList();
    if (selectList.isEmpty) {
      errorDialog(content: 'purchase_order_reversal_not_select_order'.tr);
      return;
    }
    state.reversal(
      submitList: selectList,
      success: refresh,
      error: (msg) => errorDialog(content: msg),
    );
  }
}
