import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/delivery_order_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/fun/warehouse/in/delivery_order/binding_label_detail_view.dart';
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
          zno: produceOrderNo,
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

  getSupplierLabelInfo({
    required List<DeliveryOrderInfo> group,
    required Function() refresh,
  }) {
    groupBy(group, (v) => v.materialCode ?? '').forEach((k, v) {
      state.materialList[k] =
          v.map((v2) => v2.deliveryBaseQty()).reduce((a, b) => a.add(b));
    });
    state.orderItemInfo = group;
    state.getSupplierLabelInfo(
      factoryNumber: group[0].factoryNO ?? '',
      supplierNumber: group[0].supplierCode ?? '',
      success: () =>
          Get.to(() => const DeliveryOrderLabelBindingPage())?.then((v) {
        state.scannedLabel.clear();
        if (v != null && v) {
          refresh.call();
        }
      }),
      error: (msg) => errorDialog(content: msg),
    );
  }

  getLabelBindingStaging() {
    state.getLabelBindingStaging(error: (msg) => msgDialog(content: msg));
  }

  addPiece({required String pieceNo}) {
    if (state.scannedLabel.any((v) => v.pieceNo == pieceNo)) {
      errorDialog(content: '该件已添加');
    } else {
      try {
        _addLabel(
          labelData: state.orderPieceList.firstWhere(
            (v) => v.pieceNo == pieceNo,
          ),
        );
      } on StateError catch (_) {
        errorDialog(content: '该件不属于当前送货单！');
      }
    }
  }

  scanLabel(String code) {
    if (state.scannedLabel.any(
      (v) => v.labelList!.any((v2) => v2.labelNumber == code),
    )) {
      errorDialog(content: '该标签已扫');
    } else {
      try {
        _addLabel(
          labelData: state.orderPieceList.firstWhere(
            (v) => v.labelList!.any((v2) => v2.labelNumber == code),
          ),
        );
      } on StateError catch (_) {
        errorDialog(content: '该件不属于当前送货单！');
      }
    }
  }

  _addLabel({required DeliveryOrderPieceInfo labelData}) {
    var materialNumberList = <String>[];
    state.materialList.forEach((k, v) {
      materialNumberList.add(k);
    });
    var labelMaterialList = <String>[];
    for (var v in labelData.labelList!) {
      labelMaterialList.add(v.materialCode ?? '');
    }
    if (materialNumberList.toSet().containsAll(labelMaterialList.toSet())) {
      var scannedMaterialList = <DeliveryOrderLabelInfo>[];
      for (var v in state.scannedLabel) {
        scannedMaterialList.addAll(v.labelList ?? []);
      }
      for (var labelMaterial in labelData.labelList!) {
        double max = state.materialList[labelMaterial.materialCode] ?? 0;
        double total = 0.0;
        if (scannedMaterialList.isNotEmpty) {
          total = scannedMaterialList
              .where((v) => v.materialCode == labelMaterial.materialCode)
              .map((v) => v.quantity ?? 0)
              .reduce((a, b) => a.add(b));
        }
        double quantity = labelData.labelList!
            .where((v) => v.materialCode == labelMaterial.materialCode)
            .map((v) => v.quantity ?? 0)
            .reduce((a, b) => a.add(b));
        if ((total + quantity) > max) {
          errorDialog(content: '该标签数量超出了，请扫瞄数量更小的标签。');
          return;
        }
      }
      state.scannedLabel.add(labelData);
    } else {
      errorDialog(content: '该件获取内包含了其他工单待物料，请拆分拣货。');
    }
  }

  deletePiece({required DeliveryOrderPieceInfo pieceInfo}) {
    state.scannedLabel.removeWhere((v) => v.pieceNo == pieceInfo.pieceNo);
  }

  stagingLabelBinding() {
    state.stagingLabelBinding(
      success: (msg) => successDialog(content: msg),
      error: (msg) => errorDialog(content: msg),
    );
  }

  List<List<String>> getScannedMaterialsInfo() {
    var returnList = <List<String>>[];
    var material = <DeliveryOrderLabelInfo>[];
    for (var item in state.scannedLabel) {
      material.addAll(item.labelList ?? []);
    }
    groupBy(material, (v) => '(${v.materialCode})${v.materialName}')
        .forEach((k, v) {
      returnList.add([
        k,
        v.map((v) => v.quantity ?? 0).reduce((a, b) => a.add(b)).toShowString(),
      ]);
    });
    return returnList;
  }

  submitLabelBinding() {
     Get.to(() => const LabelDetailPage())?.then((v) {
       if (v != null) {
         state.submitLabelBinding(
           storageLocation:  v[0],
           inspectorNumber:  v[1],
           success: (msg) => successDialog(
             content: msg,
             back: () => Get.back(result: true),
           ),
           error: (msg) => errorDialog(content: msg),
         );
       }
     });
   }
}
