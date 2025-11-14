import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/delivery_order_info.dart';
import 'package:jd_flutter/bean/http/response/purchase_order_warehousing_info.dart';
import 'package:jd_flutter/fun/warehouse/in/purchase_order_warehousing/purchase_order_warehousing_binding_label_detail_view.dart';
import 'package:jd_flutter/fun/warehouse/in/purchase_order_warehousing/purchase_order_warehousing_binding_label_view.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'purchase_order_warehousing_state.dart';

class PurchaseOrderWarehousingLogic extends GetxController {
  final PurchaseOrderWarehousingState state = PurchaseOrderWarehousingState();

  void query({
    required String startDate,
    required String endDate,
    required String supplierNumber,
    required String factory,
    required String warehouse,
    required String typeBody,
    required String instruction,
    required String purchaseOrder,
    required String materielCode,
    required String customerPO,
    required String trackNo,
  }) {
    state.getPurchaseOrder(
      startDate: startDate,
      endDate: endDate,
      supplier: supplierNumber,
      factory: factory,
      warehouse: warehouse,
      typeBody: typeBody,
      instruction: instruction,
      purchaseOrder: purchaseOrder,
      materielCode: materielCode,
      customerPO: customerPO,
      trackNo: trackNo,
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

  void selectAll(bool v) {
    for (var item in state.orderList) {
      item.selectAll(v);
    }
  }

  void distribution({required double qty, required Function() refresh}) {
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

  void checkOrderIsNeedScan({
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
      errorDialog(
          content: 'purchase_order_warehousing_different_order_tips'.tr);
      return;
    }
    if (groupBy(selectOrder, (v) => v.supplier).length > 1) {
      errorDialog(
          content: 'purchase_order_warehousing_different_supplier_tips'.tr);
      return;
    }

    if (selectOrder.any((v) => v.isScanPieces == 'X')) {
      state.getSupplierLabelInfo(
        success: (labels) {
          state.materialList.clear();
          state.orderLabelList.clear();
          groupBy(selectOrder, (v) => v.materialCode ?? '').forEach((k, v) {
            var sizeList = <List>[];
            for (var v2 in v) {
              for (PurchaseOrderDetailsInfo v3 in (v2.details ?? [])) {
                try {
                  var has = sizeList.firstWhere((v) => v[0] == (v3.size ?? ''));
                  has[1] = (has[1] as double).add(v3.qty.value);
                } on StateError catch (_) {
                  sizeList.add([v3.size ?? '', v3.qty.value]);
                }
              }
            }
            state.materialList[k] = sizeList;
          });
          state.materialList.forEach((k, v) {
            for (var label in labels) {
              if (label.materialCode == k &&
                  !state.orderLabelList
                      .any((v2) => v2.labelId() == label.labelId())) {
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

  void addPiece({required String pieceNo}) {
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

  void scanLabel(String code) {
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

  void _addLabels({required List<DeliveryOrderLabelInfo> labels}) {
    if (labels.isEmpty) {
      errorDialog(
          content: 'purchase_order_warehousing_order_not_have_this_label'.tr);
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

    var labelData = <DeliveryOrderLabelInfo>[
      for (var label in labels)
        if (!state.scannedLabelList.contains(label)) label
    ];
    var materialNumberList = <String>[];
    state.materialList.forEach((k, v) {
      for (var v2 in v) {
        materialNumberList.add('$k${v2[0]}');
      }
    });
    var labelMaterialList = <String>[];
    for (var v in labelData) {
      labelMaterialList.add('${v.materialCode}${v.size}');
    }
    if (materialNumberList.toSet().containsAll(labelMaterialList.toSet())) {
      for (var label in labelData) {
        double sizeMax = state.materialList[label.materialCode]!
            .firstWhere((v) => v[0] == label.size)[1];
        double sizeTotal = 0.0;
        if (state.scannedLabelList.isNotEmpty) {
          for (var v in state.scannedLabelList
              .where((v) => v.sizeMaterial() == label.sizeMaterial())) {
            sizeTotal = sizeTotal.add(v.commonQty ?? 0);
          }
        }
        double quantity = 0;
        for (var v in labelData
            .where((v) => v.sizeMaterial() == label.sizeMaterial())) {
          quantity = quantity.add(v.commonQty ?? 0);
        }

        if (sizeTotal.add(quantity) > sizeMax) {
          errorDialog(
              content: 'purchase_order_warehousing_label_qty_exceed'.tr);
        } else {
          state.scannedLabelList.add(label..isChecked.value = true);
        }
      }
    } else {
      errorDialog(content: 'purchase_order_warehousing_has_other_material'.tr);
    }
  }

  void deletePiece({required DeliveryOrderLabelInfo pieceInfo}) {
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

  List<List> sizeMaterialList() {
    var sizeList = <List>[];
    state.materialList.forEach((k, v) {
      sizeList.addAll(
          v.where((v2) => v2[0] != null && v2[0].toString().isNotEmpty));
    });
    return sizeList;
  }

  double getMaterialsTotal() {
    var max = 0.0;
    for (var v in state.materialList.values) {
      max = max.add(v.map((v2) => v2[1]).reduce((a, b) => a.add(b)));
    }
    return max;
  }

  double getScanProgress() {
    var progress = 0.0;
    for (var v in state.scannedLabelList) {
      progress = progress.add(v.commonQty ?? 0);
    }
    return progress;
  }

  double getSizeScanProgress(String size) {
    var progress = 0.0;
    for (var v in state.scannedLabelList.where((v) => v.size == size)) {
      progress = progress.add(v.commonQty ?? 0);
    }
    return progress;
  }

  void submitLabelBinding(Function() toDetail) {
    for (var k in state.materialList.keys) {
      var v = state.materialList[k] ?? [];
      for (var s in v) {
        var total = state.scannedLabelList
            .where((v2) => v2.sizeMaterial() == '$k${s[0]}')
            .map((v3) => v3.commonQty ?? 0)
            .reduce((a, b) => a.add(b));
        if (total > (s[1] as double)) {
          errorDialog(content: 'purchase_order_warehousing_qty_exceed_tips'.tr);
          return;
        }

        if (total < (s[1] as double)) {
          errorDialog(
              content: 'purchase_order_warehousing_qty_insufficient'.tr);
          return;
        }
      }
    }

    Get.to(() => const PurchaseOrderWarehousingBindingLabelDetailPage())
        ?.then((v) {
      if (v) toDetail.call();
    });
  }
  ///有权限 要么都校验标签，要么都不校验标签  没有标签 提交时 都校验标签
  bool isCanSubmitBinding() => state.hasPassPermission
      ? state.scannedLabelList.isNotEmpty &&
      (state.scannedLabelList.every((v) => v.isChecked.value) ||
          state.scannedLabelList.every((v) => !v.isChecked.value))
      : state.scannedLabelList.isNotEmpty &&
      (state.scannedLabelList.every((v) => v.isChecked.value));
}
