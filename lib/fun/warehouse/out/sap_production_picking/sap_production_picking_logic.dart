import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'sap_production_picking_state.dart';

class SapProductionPickingLogic extends GetxController {
  final SapProductionPickingState state = SapProductionPickingState();

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  queryOrder({
    required String noticeNo,
    required String startDate,
    required String endDate,
    required String workCenter,
    required String factory,
    required String warehouse,
    required bool isSupplementOrder,
  }) {
    if (workCenter.contains('PQCJ')) {
      informationDialog(
          content: '喷漆物料领取请使用《SAP喷漆领料》功能操作！',
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

  checkPickingSelected(Function(bool) picking) {
    var select = state.pickOrderList.where((v) => v.select);
    if (groupBy(select, (v) => v.location ?? '').length > 1) {
      errorDialog(content: '请选不通仓库的物料不能一起领料！');
    } else {
      askDialog(
        content: '有贴标的货物请使用扫码领料！',
        confirmText: '扫码领料',
        confirmColor: Colors.green,
        confirm: () => picking.call(true),
        cancelText: '手动领料',
        cancelColor: Colors.blueAccent,
        cancel: () => picking.call(false),
      );
    }
  }

  getOrderDetail(bool isScan) {
    state.getMaterialPickingOrderDetail(
      isScan: isScan,
      error: (msg) => errorDialog(content: msg),
    );
  }

  getBarCodeList() {
    state.getProductionPickingBarCodeList(
      loading: '正在获取条码列表...',
      error: (msg) => errorDialog(content: msg),
    );
  }

  bool hasSubmitSelect() {
    for (var item in state.pickDetailList) {
      for (var j = 0; j < item.materialList.length; ++j) {
        if (item.materialList[j].select &&item.canPicking(j)) {
          return true;
        }
      }
    }
    return false;
  }

  submitPicking({
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

  checkMixCode(String code) {
    if(state.barCodeList.isEmpty){
      errorDialog(content: '标签数据为空，请刷新标签列表');
      return;
    }
    if (!state.barCodeList.any((v) => v.barCode == code)) {
      errorDialog(content: '此标签不在本次领料范围!!');
      return;
    }
    if (state.barCodeList.any((v) => v.barCode == code && v.scanned)) {
      errorDialog(content: '标签已扫!!');
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
