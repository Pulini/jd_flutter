import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/delivery_order_info.dart';
import 'package:jd_flutter/bean/http/response/purchase_order_warehousing_info.dart';
import 'package:jd_flutter/fun/warehouse/in/purchase_order_warehousing/purchase_order_warehousing_binding_label_detail_view.dart';
import 'package:jd_flutter/fun/warehouse/in/purchase_order_warehousing/purchase_order_warehousing_binding_label_view.dart';
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
      supplier: supplierNumber,
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

  checkOrderIsNeedScan({
    required Function(List<PurchaseOrderDetailsInfo>) stockIn,
  }) {
    var selectOrder = state.orderList
        .where((v) => v.details!.any((v2) => v2.isSelected.value));
    var select = <PurchaseOrderDetailsInfo>[];
    for (var v in selectOrder) {
      for (var v2 in v.details!) {
        if (v2.qty.value > 0 && v2.isSelected.value) select.add(v2);
      }
    }
    if (select.isEmpty) {
      errorDialog(
          content: 'purchase_order_warehousing_dialog_not_select_order'.tr);
      return;
    }
    if (groupBy(selectOrder, (v) => v.isScanPieces).length > 1) {
      errorDialog(content: 'purchase_order_warehousing_different_order_tips'.tr);
      return;
    }
    if (groupBy(selectOrder, (v) => v.supplier).length > 1) {
      errorDialog(content: 'purchase_order_warehousing_different_supplier_tips'.tr);
      return;
    }

    if (selectOrder.any((v) => v.isScanPieces == 'X')) {
      state.getSupplierLabelInfo(
        success: (labels) {
          state.materialList.clear();
          state.orderLabelList.clear();
          groupBy(selectOrder, (v) => v.materialCode).forEach((k, v) {
            var total = 0.0;
            for (var v2 in v) {
              v2.details!.where((v3) => v3.isSelected.value).forEach((v4) {
                total = total.add(v4.qty.value);
              });
            }
            state.materialList[k ?? ''] = total;
          });
          state.materialList.forEach((k, v) {
            for (var label in labels) {
              if (label.materialCode == k &&
                  !state.orderLabelList
                      .any((v2) => v2.labelNumber == label.labelNumber)) {
                state.orderLabelList.add(label);
              }
            }
          });
          Get.to(() => const PurchaseOrderWarehousingBindingLabelPage())
              ?.then((scanFinish) {
            if (scanFinish) stockIn.call(select);
          });
        },
        error: (msg) => errorDialog(content: msg),
      );
    } else {
      stockIn.call(select);
    }
  }

  addPiece({required String pieceNo}) {
    DeliveryOrderLabelInfo? outBox;
    try {
      outBox = state.orderLabelList
          .firstWhere((v) => v.pieceNo == pieceNo && v.isOutBoxLabel());
    } on StateError catch (_) {}
    var labels = <DeliveryOrderLabelInfo>[];
    if (outBox == null) {
      labels = state.orderLabelList.where((v) => v.pieceNo == pieceNo).toList();
    } else {
      labels = state.orderLabelList
          .where((v) => v.outBoxLabelNumber == outBox!.labelNumber)
          .toList();
    }
    _addLabels(labels: labels);
  }

  scanLabel(String code) {
    DeliveryOrderLabelInfo? outBox;
    try {
      outBox = state.orderLabelList
          .firstWhere((v) => v.labelNumber == code && v.isOutBoxLabel());
    } on StateError catch (_) {}
    var labels = <DeliveryOrderLabelInfo>[];
    if (outBox == null) {
      labels =
          state.orderLabelList.where((v) => v.labelNumber == code).toList();
    } else {
      labels = state.orderLabelList
          .where((v) => v.outBoxLabelNumber == code)
          .toList();
    }
    _addLabels(labels: labels);
  }

  _addLabels({required List<DeliveryOrderLabelInfo> labels}) {
    if (labels.isEmpty) {
      errorDialog(content: 'purchase_order_warehousing_order_not_have_this_label'.tr);
      return;
    }

    if (labels.every((v) => state.scannedLabelList.contains(v))) {
      if (labels.every((v) => v.isChecked.value)) {
        errorDialog(content: 'purchase_order_warehousing_label_scanned'.tr);
      } else {
        for (var v in labels) {
          v.isChecked.value = true;
        }
      }
      return;
    }

    var labelData =<DeliveryOrderLabelInfo>[
      for (var label in labels)
        if (!state.scannedLabelList.contains(label)) label
    ];
    var materialNumberList = <String>[];
    state.materialList.forEach((k, v) {
      materialNumberList.add(k);
    });
    var labelMaterialList = <String>[];
    for (var v in labelData) {
      labelMaterialList.add(v.materialCode ?? '');
    }
    if (materialNumberList.toSet().containsAll(labelMaterialList.toSet())) {
      for (var label in labelData) {
        double max = state.materialList[label.materialCode] ?? 0;
        double total = 0.0;
        if (state.scannedLabelList.isNotEmpty) {
          for (var v in state.scannedLabelList
              .where((v) => v.materialCode == label.materialCode)) {
            total = total.add(v.baseQty ?? 0);
          }
        }
        double quantity = 0;
        for (var v
        in labelData.where((v) => v.materialCode == label.materialCode)) {
          quantity = quantity.add(v.baseQty ?? 0);
        }

        if (total.add(quantity) > max) {
          errorDialog(content: 'purchase_order_warehousing_label_qty_exceed'.tr);
        } else {
          state.scannedLabelList.add(label..isChecked.value = true);
        }
      }
    } else {
      errorDialog(content: 'purchase_order_warehousing_has_other_material'.tr);
    }
  }
  deletePiece({required DeliveryOrderLabelInfo pieceInfo}) {
    state.scannedLabelList.removeWhere((v) => v.pieceNo == pieceInfo.pieceNo);
  }

  List<List<String>> getScannedMaterialsInfo() {
    var returnList = <List<String>>[];
    groupBy(state.scannedLabelList,
        (v) => '(${v.materialCode})${v.materialName}').forEach((k, v) {
      returnList.add([
        k,
        v
                .map((v) => v.commonQty ?? 0)
                .reduce((a, b) => a.add(b))
                .toShowString() +
            (v[0].commonUnit ?? ''),
      ]);
    });
    return returnList;
  }

  submitLabelBinding(Function() toDetail) {
    state.materialList.forEach((k, v) {
      var total = state.scannedLabelList
          .where((v2) => v2.materialCode == k)
          .map((v3) => v3.baseQty ?? 0)
          .reduce((a, b) => a.add(b));
      if (total > v) {
        errorDialog(content: 'purchase_order_warehousing_qty_exceed_tips'.tr);
        return;
      }
      if (total < v) {
        errorDialog(content: 'purchase_order_warehousing_qty_insufficient'.tr);
        return;
      }
    });
    Get.to(() => const PurchaseOrderWarehousingBindingLabelDetailPage())
        ?.then((v) {
      if (v) toDetail.call();
    });
  }
}
