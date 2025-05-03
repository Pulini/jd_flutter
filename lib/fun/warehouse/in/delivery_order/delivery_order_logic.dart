import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/delivery_order_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';

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
      workerNumber: workerNumber,
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
      errorDialog(content: 'delivery_order_selected_contains_exempt_and_not_exempt'.tr);
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
      reversalList:orderNoList,
      label: [
        for (var v in (labels??<ReversalLabelInfo>[])) v.pieceNo ?? '',
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
          if(v2.isPackingMaterials==false){
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
    if (notPackingMaterials> 0) {
      errorDialog(content: 'delivery_order_selected_contains_not_in_and_in'.tr);
      return;
    }
    if (exempt > 0 && notExempt > 0) {
      errorDialog(content: 'delivery_order_selected_contains_exempt_and_not_exempt'.tr);
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
}
