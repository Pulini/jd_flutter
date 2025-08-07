import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/delivery_order_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/fun/warehouse/in/delivery_order/delivery_order_binding_label_detail_view.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'delivery_order_label_binding_view.dart';
import 'delivery_order_state.dart';

class DeliveryOrderLogic extends GetxController {
  final DeliveryOrderState state = DeliveryOrderState();

  queryDeliveryOrders({
    required String startDate,
    required String endDate,
    required String typeBody,
    required String instruction,
    required String supplier,
    required String purchaseOrder,
    required String materialCode,
    required String company,
    required String workerNumber,
    required String workCenter,
    required String warehouse,
    required String factory,
  }) {
    state.getDeliveryOrders(
      startDate: startDate,
      endDate: endDate,
      typeBody: typeBody,
      instruction: instruction,
      supplier: supplier,
      purchaseOrder: purchaseOrder,
      materialCode: materialCode,
      company: company,
      workerNumber: workerNumber.ifEmpty(userInfo?.number ?? ''),
      workCenter: workCenter,
      warehouse: warehouse,
      factory: factory,
      success: (msg) {},
      error: (msg) => errorDialog(content: msg),
    );
  }

  getOrderDetail({
    required bool isExempt,
    required bool isCheckOrder,
    required String factoryNumber,
    required String deliNo,
    required String workCenterID,
    required Function() goTo,
  }) {
    error(String msg) => errorDialog(content: msg);
    state.factoryNumber = factoryNumber;
    if (isCheckOrder) {
      if (isExempt) {
        state.getDeliveryOrdersDetails(
          deliNo: deliNo,
          line: workCenterID,
          success: goTo,
          error: error,
        );
      } else {
        state.getTemporaryDetail(
          zno: deliNo,
          success: () => state.getDeliveryOrdersDetails(
            deliNo: deliNo,
            line: workCenterID,
            success: goTo,
            error: error,
          ),
          error: error,
        );
      }
    } else {
      state.getDeliveryOrdersDetails(
        deliNo: deliNo,
        line: workCenterID,
        success: goTo,
        error: error,
      );
    }
  }

  checkWorkerNumber(String number) {
    if (number.trim().length >= 6) {
      getWorkerInfo(
        number: number,
        workers: (list) {
          state.inspectorName.value = list[0].empName ?? '';
          state.inspectorNumber.value = number;
          spSave(
              '$spSaveDeliveryOrderCheckInspectorNumber${state.detailInfo.division}',
              number);
        },
        error: (msg) {
          state.inspectorName.value = '';
          state.inspectorNumber.value = '';
        },
      );
    } else {
      state.inspectorName.value = '';
      state.inspectorNumber.value = '';
    }
  }

  cleanCheck() {
    state.locationList.value = [];
    state.locationName.value = '';
    state.locationId.value = '';
    state.inspectorName.value = '';
    state.inspectorNumber.value = '';
    state.factoryNumber = '';
  }

  saveCheck() {
    state.saveCheck(
      success: (msg) =>
          successDialog(content: msg, back: () => Get.back(result: true)),
      error: (msg) => errorDialog(content: msg),
    );
  }

  int getPickerInitIndex() {
    var index = state.locationList
        .indexWhere((v) => v.storageLocationNumber == state.locationId.value);
    return index == -1 ? 0 : index;
  }

  pickLocation(int index) {
    state.locationId.value =
        state.locationList[index].storageLocationNumber ?? '';
    state.locationName.value = state.locationList[index].name ?? '';
    spSave(spSaveDeliveryOrderCheckLocation, state.locationId.value);
  }

  List<DeliveryOrderInfo> getSelectedList() => [
        for (var v in state.deliveryOrderList)
          for (var v2 in v)
            if (v2.isSelected.value) v2
      ];

  checkReversalStockIn({
    required Function(List<ReversalLabelInfo>) reversalWithCode,
    required Function() reversal,
  }) {
    var exempt = 0;
    var notExempt = 0;
    var submitList = <DeliveryOrderInfo>[];
    for (var v in state.deliveryOrderList) {
      for (var v2 in v) {
        if (v2.isSelected.value) {
          submitList.add(v2);
          if (v2.isExempt == true) {
            exempt++;
          } else {
            notExempt++;
          }
        }
      }
    }
    if (exempt > 0 && notExempt > 0) {
      errorDialog(
          content: 'delivery_order_selected_contains_exempt_and_not_exempt'.tr);
      return;
    }
    var orderNoList = <DeliveryOrderInfo>[];
    for (var v in getSelectedList()) {
      if (!orderNoList.any((v2) => v2.deliNo == v.deliNo)) orderNoList.add(v);
    }
    state.checkReversalStockIn(
      reversalList: orderNoList,
      reversalWithCode: reversalWithCode,
      reversal: reversal,
    );
  }

  reversalStockIn({
    required String workCenterID,
    required String reason,
    List<ReversalLabelInfo>? labels,
    required Function() refresh,
  }) {
    var orderNoList = <DeliveryOrderInfo>[];
    for (var v in getSelectedList()) {
      if (!orderNoList.any((v2) => v2.deliNo == v.deliNo)) orderNoList.add(v);
    }
    state.reversalStockIn(
      workCenterID: workCenterID,
      reason: reason,
      reversalList: orderNoList,
      label: [
        for (var v in (labels ?? <ReversalLabelInfo>[])) v.pieceNo ?? '',
      ],
      success: (msg) => successDialog(content: msg, back: refresh),
      error: (msg) => errorDialog(content: msg),
    );
  }

  checkReversalStockOut({
    required Function() reversal,
  }) {
    var notPackingMaterials = 0;
    var exempt = 0;
    var notExempt = 0;
    var submitList = <DeliveryOrderInfo>[];
    for (var v in state.deliveryOrderList) {
      for (var v2 in v) {
        if (v2.isSelected.value) {
          submitList.add(v2);
          if (v2.isPackingMaterials == false) {
            notPackingMaterials++;
          }
          if (v2.isExempt == true) {
            exempt++;
          } else {
            notExempt++;
          }
        }
      }
    }
    if (notPackingMaterials > 0) {
      errorDialog(content: 'delivery_order_selected_contains_not_in_and_in'.tr);
      return;
    }
    if (exempt > 0 && notExempt > 0) {
      errorDialog(
          content: 'delivery_order_selected_contains_exempt_and_not_exempt'.tr);
      return;
    }
  }

  reversalStockOut({
    required String workCenterID,
    required String reason,
    required Function() refresh,
  }) {
    var orderNoList = <DeliveryOrderInfo>[];
    for (var v in getSelectedList()) {
      if (!orderNoList.any((v2) => v2.deliNo == v.deliNo)) orderNoList.add(v);
    }
    state.reversalStockOut(
      workCenterID: workCenterID,
      reason: reason,
      reversalList: orderNoList,
      success: (msg) => successDialog(content: msg, back: refresh),
      error: (msg) => errorDialog(content: msg),
    );
  }

  _initLabelList(List<DeliveryOrderLabelInfo> list) {
    state.materialList.forEach((k, v) {
      for (var label in list) {
        if (label.materialCode == k || label.isOutBoxLabel()) {
          if (!state.orderLabelList
              .any((v2) => v2.labelId() == label.labelId())) {
            state.orderLabelList.add(label);
          }
        }
      }
    });
    state.scannedLabelList.value = state.orderLabelList
        .where((v) => v.isBind && !v.isOutBoxLabel())
        .toList();
  }

  getSupplierLabelInfo({
    required List<DeliveryOrderInfo> group,
    required Function(bool) refresh,
  }) {
    state.materialList.clear();
    groupBy(group, (v) => v.materialCode ?? '').forEach((k, v) {
      var sizeList = <String, double>{};
      for (var v2 in v) {
        for (DeliveryOrderSizeInfo v3 in (v2.deliSize ?? [])) {
          if (sizeList.keys.contains(v3.size ?? '')) {
            sizeList[v3.size ?? ''] =
                sizeList[v3.size ?? ''].add(v3.qty.toDoubleTry());
          } else {
            sizeList[v3.size ?? ''] = v3.qty.toDoubleTry();
          }
        }
      }
      state.materialList[k] = sizeList;
    });
    state.orderItemInfo = group;
    state.orderLabelList.clear();
    state.getSupplierLabelInfo(
      factoryNumber: group[0].factoryNO ?? '',
      supplierNumber: group[0].supplierCode ?? '',
      deliveryOrderNumber: group[0].deliNo ?? '',
      success: (list) {
        _initLabelList(list);
        Get.to(() => const DeliveryOrderLabelBindingPage())?.then((v) {
          state.scannedLabelList.clear();
          refresh.call(v != null && v);
        });
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  getLabelBindingStaging() {
    state.getLabelBindingStaging(
      success: (list) => _initLabelList(list),
      error: (msg) => msgDialog(content: msg),
    );
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

  ///有权限
  ///有部分标签
  ///扫已绑定标签，标签变色
  ///扫未绑定标签，标签列表添加标签并变色
  ///没有标签
  ///扫未绑定标签，标签列表添加标签并变色
  ///提交时 要么都校验标签，要么都不校验标签

  ///没有权限
  ///有部分标签
  ///扫已绑定标签，标签变色
  ///扫未绑定标签，标签列表添加标签并变色
  ///没有标签
  ///扫未绑定标签，标签列表添加标签并变色
  _addLabels({required List<DeliveryOrderLabelInfo> labels}) {
    if (labels.isEmpty) {
      errorDialog(
          content: 'delivery_order_label_check_order_not_have_this_label'.tr);
      return;
    }
    if (labels.every((v) => state.scannedLabelList.contains(v))) {
      if (labels.every((v) => v.isChecked.value)) {
        errorDialog(content: 'delivery_order_label_check_label_scanned'.tr);
      } else {
        for (var v in labels) {
          v.isChecked.value = true; //标记为已查验
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
      for (var v2 in v.keys) {
        materialNumberList.add('$k$v2');
      }
    });
    var labelMaterialList = <String>[];
    for (var v in labelData) {
      labelMaterialList.add('${v.materialCode}${v.size}');
    }
    if (materialNumberList.toSet().containsAll(labelMaterialList.toSet())) {
      for (var label in labelData) {
        double sizeMax =
            state.materialList[label.materialCode]![label.size] ?? 0;
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
              content: 'delivery_order_label_check_label_qty_exceed'.tr);
        } else {
          state.scannedLabelList.add(label..isChecked.value = true);
        }
      }
    } else {
      errorDialog(content: 'delivery_order_label_check_has_other_material'.tr);
    }
  }

  deletePiece({required DeliveryOrderLabelInfo pieceInfo}) {
    state.scannedLabelList.removeWhere((v) => v.pieceNo == pieceInfo.pieceNo);
  }

  stagingLabelBinding() {
    state.stagingLabelBinding(
      success: (msg) => successDialog(content: msg),
      error: (msg) => errorDialog(content: msg),
    );
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

  submitLabelBinding() {
    for (var ml in state.materialList.entries) {
      var materialCode = ml.key;
      var sizeList = ml.value;
      for (var sl in sizeList.entries) {
        var size = sl.key;
        var qty = sl.value;
        var total = state.scannedLabelList
            .where((v2) => v2.sizeMaterial() == '$materialCode$size')
            .map((v3) => v3.commonQty ?? 0)
            .reduce((a, b) => a.add(b));
        if (total > qty) {
          errorDialog(content: 'delivery_order_label_check_qty_exceed_tips'.tr);
          return;
        }
        if (total < qty) {
          errorDialog(
              content: 'delivery_order_label_check_qty_insufficient'.tr);
          return;
        }
      }
    }
    Get.to(() => const LabelDetailPage())?.then((v) {
      if (v != null) {
        state.submitLabelBinding(
          storageLocation: v[0],
          inspectorNumber: v[1],
          success: (msg) => successDialog(
            content: msg,
            back: () => Get.back(result: true),
          ),
          error: (msg) => errorDialog(content: msg),
        );
      }
    });
  }

  double getMaterialsTotal(String materialCode) =>
      state.materialList[materialCode]?.values.reduce((a, b) => a.add(b)) ?? 0;

  double getScanProgress(String materialCode) {
    var progress = 0.0;
    for (var v in state.scannedLabelList
        .where((v) => v.materialCode == materialCode)) {
      progress = progress.add(v.commonQty ?? 0);
    }
    return progress;
  }

  double getSizeScanProgress(String materialCode, String size) {
    var progress = 0.0;
    for (var v in state.scannedLabelList
        .where((v) => v.materialCode == materialCode && v.size == size)) {
      progress = progress.add(v.commonQty ?? 0);
    }
    return progress;
  }

  List<Map<String, List<dynamic>>> getLabelList() {
    var labelList = <Map<String, List<dynamic>>>[];
    groupBy(state.scannedLabelList, (v) => v.materialCode ?? '')
        .forEach((materialCode, list) {
      var sizeList = [];
      groupBy(list, (v) => v.size ?? '').forEach((size, labels) {
        double sizeTotal = state.materialList[materialCode]![size]!;
        sizeList.add([size, sizeTotal, labels]);
      });
      labelList.add({materialCode: sizeList});
    });
    return labelList;
  }

  ///有权限 要么都校验标签，要么都不校验标签  没有标签 提交时 都校验标签
  isCanSubmitBinding() => state.hasPassPermission
      ? state.scannedLabelList.isNotEmpty &&
          (state.scannedLabelList.every((v) => v.isChecked.value) ||
              state.scannedLabelList.every((v) => !v.isChecked.value))
      : state.scannedLabelList.isNotEmpty &&
          (state.scannedLabelList.every((v) => v.isChecked.value));
}
