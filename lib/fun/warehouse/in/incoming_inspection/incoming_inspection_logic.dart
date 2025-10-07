import 'dart:io';
import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/incoming_inspection_info.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'incoming_inspection_state.dart';

class IncomingInspectionLogic extends GetxController {
  final IncomingInspectionState state = IncomingInspectionState();

  scanOrder({
    required String code,
    required String deliveryNo,
    required String materialCode,
    required Function() success,
  }) {
    state.queryIncomingInspectionList(
      barcode: code,
      deliveryNo: deliveryNo,
      materialCode: materialCode,
      success: success,
      error: (msg) => errorDialog(content: msg),
    );
  }

  query({
    required String area,
    required String factory,
    required String deliveryNo,
    required String materialCode,
    required Function() success,
    required String supplier,
  }) {
    state.queryIncomingInspectionList(
      area: area,
      factory: factory,
      supplier: supplier,
      deliveryNo: deliveryNo,
      materialCode: materialCode,
      success: success,
      error: (msg) => errorDialog(content: msg),
    );
  }

  double getItemQty(List<List<InspectionDeliveryInfo>> group) =>
      group.map((v) => getItemMaterialQty(v)).reduce((a, b) => a.add(b));

  double getItemMaterialQty(List<InspectionDeliveryInfo> item) =>
      item.map((v) => v.qty ?? 0).reduce((a, b) => a.add(b));

  deleteDeliveryOrder(List<List<InspectionDeliveryInfo>> order) {
    state.deliveryList.remove(order);
  }

  deleteDeliveryMaterialGroupOrder(List<InspectionDeliveryInfo> group) {
    var isLastGroup = false;
    for (var g in state.deliveryList) {
      if (g.contains(group)) {
        if (g.length == 1) {
          isLastGroup = true;
        } else {
          g.remove(group);
          state.deliveryList.refresh();
        }
      }
    }
    if (isLastGroup) {
      //工单中只剩一行物料数据的情况下，直接删除整个工单
      state.deliveryList.removeWhere((g) => g.length == 1 && g.contains(group));
    }
  }

  deleteDeliveryItem(InspectionDeliveryInfo item) {
    var isLastGroup = false;
    var isLastItem = false;
    for (var v in state.deliveryList) {
      for (var v2 in v) {
        if (v.length == 1) {
          isLastGroup = true;
        }
        if (v2.contains(item)) {
          if (v2.length == 1) {
            isLastItem = true;
          } else {
            v2.remove(item);
            state.deliveryList.refresh();
          }
        }
      }
    }
    if (isLastItem) {
      if (isLastGroup) {
        //工单中只剩一组物料且只有一行送货数据的情况下，直接删除整个工单
        state.deliveryList.removeWhere((v) => v[0][0] == item);
      } else {
        //物料组中只有一行送货数据的情况下，直接删除物料组
        for (var v in state.deliveryList) {
          v.removeWhere((v2) => v2[0] == item);
          state.deliveryList.refresh();
        }
      }
    }
  }

  deleteMaterialItem(InspectionDeliveryInfo item) {
    state.addMaterialList.remove(item);
  }

  addMaterialItem(InspectionDeliveryInfo item) {
    state.addMaterialList.add(item);
  }

  modifyMaterialItem() {
    state.addMaterialList.refresh();
  }

  modify() {
    state.deliveryList.refresh();
  }

  cleanDelivery() {
    state.deliveryList.clear();
    state.addMaterialList.clear();
  }

  applyInspection(WorkerInfo worker) {
    state.applyInspection(
      number: worker.empCode ?? '',
      success: (msg) => successDialog(content: msg),
      error: (msg) => errorDialog(content: msg),
    );
  }

  queryInspectionOrders({
    required String startDate,
    required String endDate,
    required String inspectionSuppler,
    Function()? success,
  }) {
    state.getInspectionOrders(
      startDate: startDate,
      endDate: endDate,
      inspectionSuppler: inspectionSuppler,
      success: success,
      error: (msg) => errorDialog(content: msg),
    );
  }

  getInspectionOrderDetail({
    required String interID,
    required Function() success,
  }) {
    state.getInspectionOrderDetails(
      interID: interID,
      success: success,
      error: (msg) => errorDialog(content: msg),
    );
  }

  deleteInspectionPhoto(File photo) {
    state.inspectionPhotoList.remove(photo);
  }

  submitInspection({required String inspector, required String results}) {
    state.submitInspection(
      inspector: inspector,
      results: results,
      success: (msg) =>
          successDialog(content: msg, back: () => Get.back(result: true)),
      error: (msg) => errorDialog(content: msg),
    );
  }

  signOrder() {
    state.signOrder(
      success: (msg) => successDialog(content: msg, back: () => Get.back()),
      error: (msg) => errorDialog(content: msg),
    );
  }

  reportException({required String exceptionInfo}) {
    state.reportException(
      exceptionInfo: exceptionInfo,
      success: (msg) => successDialog(content: msg, back: () => Get.back()),
      error: (msg) => errorDialog(content: msg),
    );
  }

  exceptionHandling({required String handlingResult}) {
    state.exceptionHandling(
      handlingResult: handlingResult,
      success: (msg) => successDialog(content: msg, back: () => Get.back()),
      error: (msg) => errorDialog(content: msg),
    );
  }

  submitCloseOrder() {
    state.submitCloseOrder(
      success: (msg) => successDialog(content: msg, back: () => Get.back()),
      error: (msg) => errorDialog(content: msg),
    );
  }

  String getNumPageTotal() {
    var total = 0;
    if (state.inspectionDetail == null) return '0';
    groupBy(state.inspectionDetail!.materielList!, (v) => v.billNo ?? '')
        .forEach((k, v) => total += v.first.numPage ?? 0);
    return total.toString();
  }
}
