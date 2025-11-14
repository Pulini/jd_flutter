import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'sap_production_picking_state.dart';

class SapProductionPickingLogic extends GetxController {
  final SapProductionPickingState state = SapProductionPickingState();

  void queryOrder({
    required String noticeNo,
    required String startDate,
    required String endDate,
    required String workCenter,
    required String factory,
    required String warehouse,
    required bool isSupplementOrder,
  }) {
    if (workCenter.contains('PQCJ')) {
      msgDialog(
          content: 'sap_production_picking_use_sap_print_picking_tips'.tr,
          back: () {
            Get.back();
            //跳转至sap喷漆领料
          });
      return;
    }
    state.getMaterialPickingOrderList(
      noticeNo: noticeNo,
      orderType: isSupplementOrder ? 0 : 1,
      startDate: startDate,
      endDate: endDate,
      workCenter: workCenter,
      warehouse: warehouse,
      error: (msg) => errorDialog(content: msg),
    );
  }

  void checkPickingSelected(Function(bool) picking) {
    var select = state.pickOrderList.where((v) => v.select);
    if (groupBy(select, (v) => v.location ?? '').length > 1) {
      errorDialog(
          content:
              'sap_production_picking_different_warehouses_cannot_pick_together_tips'
                  .tr);
    } else {
      askDialog(
        content:
            'sap_production_picking_has_label_material_use_scan_picking_tips'
                .tr,
        confirmText: 'sap_production_picking_scan_picking'.tr,
        confirmColor: Colors.green,
        confirm: () => picking.call(true),
        cancelText: 'sap_production_picking_artificial_picking'.tr,
        cancelColor: Colors.blueAccent,
        cancel: () => picking.call(false),
      );
    }
  }

  void getOrderDetail(bool isScan) {
    state.getMaterialPickingOrderDetail(
      isScan: isScan,
      error: (msg) => errorDialog(content: msg),
    );
  }

  void getBarCodeList() {
    state.getProductionPickingBarCodeList(
      loading: 'sap_production_picking_getting_barcode_list_tips'.tr,
      error: (msg) => errorDialog(content: msg),
    );
  }

  bool hasSubmitSelect() {
    for (var item in state.pickDetailList) {
      for (var j = 0; j < item.materialList.length; ++j) {
        if (item.materialList[j].select && item.canPicking(j)) {
          return true;
        }
      }
    }
    return false;
  }

  void submitPicking({
    required String pickerNumber,
    required ByteData pickerSignature,
    required String userNumber,
    required ByteData userSignature,
    required bool isPrint,
    required bool isScan,
  }) {
    state.submitMaterialPrintPicking(
      pickerNumber: pickerNumber,
      pickerSignature: pickerSignature,
      userNumber: userNumber,
      userSignature: userSignature,
      isPrint: isPrint,
      isScan: isScan,
      success: (msg) => successDialog(
        content: msg,
        back: () => getOrderDetail(isScan),
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  void checkMixCode(String code) {
    if (state.barCodeList.isEmpty) {
      errorDialog(content: 'sap_production_picking_label_info_error_tips'.tr);
      return;
    }
    if (!state.barCodeList.any((v) => v.barCode == code)) {
      errorDialog(
          content:
              'sap_production_picking_this_label_not_belong_pick_order_tips'
                  .tr);
      return;
    }
    if (state.barCodeList.any((v) => v.barCode == code && v.scanned)) {
      errorDialog(content: 'sap_production_picking_label_scanned'.tr);
      return;
    }
    showScanTips();
    var label = state.barCodeList.firstWhere((v) => v.barCode == code);
    label.scanned = true;
    double surplus = label.qty ?? 0;
    for (var item in state.pickDetailList) {
      for (var i = 0; i < item.materialList.length; ++i) {
        var mtl = item.materialList[i];
        if (mtl.materialNumber == label.materialNumber &&
            item.remainderList[i].sub(item.pickQtyList[i]) > 0) {
          if (surplus > 0) {
            var available = item.remainderList[i].sub(item.pickQtyList[i]);
            if (surplus > available) {
              item.pickQtyList[i] = item.pickQtyList[i].add(available);
              surplus = surplus.sub(available);
            } else {
              item.pickQtyList[i] = item.pickQtyList[i].add(surplus);
              surplus = 0.0;
            }
          }
        }
      }
    }
    state.pickDetailList.refresh();
  }
}
