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
    required String produceOrderNo,
    required String deliNo,
    required String workCenterID,
    required Function() goTo,
  }) {
    error(String msg) => errorDialog(content: msg);
    state.factoryNumber = factoryNumber;
    if (isCheckOrder) {
      if (isExempt) {
        state.getDeliveryOrdersDetails(
          produceOrderNo: produceOrderNo,
          deliNo: deliNo,
          line: workCenterID,
          success: goTo,
          error: error,
        );
      } else {
        state.getTemporaryDetail(
          zno: deliNo,
          success: () => state.getDeliveryOrdersDetails(
            produceOrderNo: produceOrderNo,
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
        produceOrderNo: produceOrderNo,
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
  _initLabelList(List<DeliveryOrderLabelInfo>list){
    state.materialList.forEach((k, v) {
      for (var label in list) {
        if (label.materialCode == k || label.isOutBoxLabel()) {
          if (!state.orderLabelList
              .any((v2) => v2.labelNumber == label.labelNumber)) {
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
    required Function() refresh,
  }) {
    state.materialList.clear();
    groupBy(group, (v) => v.materialCode ?? '').forEach((k, v) {
      state.materialList[k] =
          v.map((v2) => v2.deliveryBaseQty()).reduce((a, b) => a.add(b));
    });
    state.orderItemInfo = group;
    state.getSupplierLabelInfo(
      factoryNumber: group[0].factoryNO ?? '',
      supplierNumber: group[0].supplierCode ?? '',
      deliveryOrderNumber: group[0].deliNo ?? '',
      success: (list) {
        _initLabelList(list);
        Get.to(() => const DeliveryOrderLabelBindingPage())?.then((v) {
          state.scannedLabelList.clear();
          if (v != null && v) {
            refresh.call();
          }
        });
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  getLabelBindingStaging() {
    state.getLabelBindingStaging(
      success: (list) =>_initLabelList(list),
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

  _addLabels({required List<DeliveryOrderLabelInfo> labels}) {
    if (labels.isEmpty) {
      errorDialog(content: 'delivery_order_label_check_order_not_have_this_label'.tr);
      return;
    }

    if (labels.every((v) => state.scannedLabelList.contains(v))) {
      if (labels.every((v) => v.isChecked.value)) {
        errorDialog(content: 'delivery_order_label_check_label_scanned'.tr);
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
          errorDialog(content: 'delivery_order_label_check_label_qty_exceed'.tr);
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

 double getMaterialsTotal() {
    var max=0.0;
    for (var v in state.materialList.values) {
      max=max.add(v);
    }
    return max;
  }


 double getScanProgress() {
    var progress = 0.0;
    for (var v in state.scannedLabelList) {
      progress = progress.add(v.baseQty??0);
    }
    return progress;
  }
}
