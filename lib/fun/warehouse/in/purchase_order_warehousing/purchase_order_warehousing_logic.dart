import 'package:get/get.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'purchase_order_warehousing_state.dart';

class PurchaseOrderWarehousingLogic extends GetxController {
  final PurchaseOrderWarehousingState state = PurchaseOrderWarehousingState();

  query({
    required String startDate,
    required String endDate,
    required String supplierNumber,
    required String factory,
    required String warehouse,
  }) {
    state.getPurchaseOrder(
      startDate: startDate,
      endDate: endDate,
      supplierNumber: supplierNumber,
      factory: factory,
      warehouse: warehouse,
      error: (msg) => errorDialog(content: msg),
    );
  }

  double refreshQty() {
    var qty = 0.0;
    var orderQty = 0.0;
    var receivedQty = 0.0;
    for (var v in state.orderList) {
      v.details!.where((v2) => v2.isSelected.value).forEach((v3) {
        orderQty = orderQty.add(v3.orderQty.toDoubleTry());
        receivedQty = receivedQty.add(v3.receivedQty.toDoubleTry());
        qty = qty.add(v3.qty.value);
      });
    }
    state.receivedQty.value = receivedQty;
    state.orderQty.value = orderQty;
    return qty;
  }

  selectAll(bool v) {
    for (var item in state.orderList) {
      item.selectAll(v);
    }
  }

  distribution({required double qty, required Function() refresh}) {
    var total = qty;
    for (var v in state.orderList) {
      v.details!.where((v2) => v2.isSelected.value).forEach((v3) {
        var need = v3.underNum.toDoubleTry();
        if (total >= need) {
          v3.qty.value = need;
          total = total.sub(need);
        } else {
          v3.qty.value = total;
          total = 0;
        }
      });
    }
    refresh.call();
  }
}
