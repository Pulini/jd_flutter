import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_surplus_material_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'sap_surplus_material_stock_in_state.dart';

class SapSurplusMaterialStockInLogic extends GetxController {
  final SapSurplusMaterialStockInState state = SapSurplusMaterialStockInState();

  setWeighbridgeState(String weighbridgeState) {
    state.weighbridgeStateText.value =
        getWeighbridgeStateText(weighbridgeState);
    state.weighbridgeStateTextColor.value =
        getWeighbridgeStateTextColor(weighbridgeState);
    if (weighbridgeState == 'WEIGHT_MSG_DEVICE_DETACHED' ||
        weighbridgeState == 'WEIGHT_MSG_DEVICE_NOT_CONNECTED' ||
        weighbridgeState == 'WEIGHT_MSG_OPEN_DEVICE_FAILED' ||
        weighbridgeState == 'WEIGHT_MSG_READ_ERROR') {
      state.weight.value = 0;
    }
  }

  String getWeighbridgeStateText(String weighbridgeState) {
    switch (weighbridgeState) {
      case 'WEIGHT_MSG_DEVICE_DETACHED':
        return 'sap_surplus_material_stock_in_weighbridge_disconnect'.tr;
      case 'WEIGHT_MSG_DEVICE_NOT_CONNECTED':
        return 'sap_surplus_material_stock_in_weighbridge_unconnected'.tr;
      case 'WEIGHT_MSG_OPEN_DEVICE_SUCCESS':
        return 'sap_surplus_material_stock_in_weighbridge_connected'.tr;
      case 'WEIGHT_MSG_OPEN_DEVICE_FAILED':
        return 'sap_surplus_material_stock_in_weighbridge_connect_failed'.tr;
      case 'WEIGHT_MSG_READ_ERROR':
        return 'sap_surplus_material_stock_in_weighbridge_connect_error'.tr;
    }
    return '';
  }

  Color getWeighbridgeStateTextColor(String weighbridgeState) {
    switch (weighbridgeState) {
      case 'WEIGHT_MSG_DEVICE_DETACHED':
      case 'WEIGHT_MSG_DEVICE_NOT_CONNECTED':
      case 'WEIGHT_MSG_OPEN_DEVICE_FAILED':
        return Colors.red;
      case 'WEIGHT_MSG_OPEN_DEVICE_SUCCESS':
        return Colors.green;
      case 'WEIGHT_MSG_READ_ERROR':
        return Colors.orange;
    }
    return Colors.black;
  }

  Color getSurplusMaterialTypeColor(String type) {
    switch (type.toIntTry()) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.purple;
      case 5:
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  queryHistory({
    required String startDate,
    required String endDate,
  }) {
    state.getSurplusMaterialHistory(
      startDate: startDate,
      endDate: endDate,
      error: (msg) => errorDialog(content: msg),
    );
  }

  scanCode(String code) async {
    try {
      var codeData = SurplusMaterialLabelInfo.fromJson(jsonDecode(code));
      if (state.materialList.isNotEmpty &&
          state.materialList[0].dispatchNumber != codeData.dispatchNumber) {
        msgDialog(
          content:
              'sap_surplus_material_stock_in_scan_wrong_order_label_tips'.tr,
        );
        return;
      }
      if (state.materialList.any((v) => v.number == codeData.stubBar)) {
        msgDialog(
          content:
              'sap_surplus_material_stock_in_surplus_material_already_scanned'
                  .tr,
        );
        return;
      }
      if (state.materialList.length == 3) {
        msgDialog(
            content:
                'sap_surplus_material_stock_in_surplus_material_stock_in_tips！.tr,！');
        return;
      }
      if (await codeData.isExist()) {
        msgDialog(
          content: 'sap_surplus_material_stock_in_label_already_stock_in'.tr,
        );
        return;
      }
      state.getMaterialInfoByCode(
        dispatchNumber: codeData.dispatchNumber ?? '',
        code: codeData.stubBar ?? '',
        success: (mi) {
          state.materialList.add(codeData
            ..number = mi.number ?? ''
            ..name = mi.name ?? '');
        },
        error: (msg) => errorDialog(content: msg),
      );
    } catch (e) {
      errorDialog(
        content: 'sap_surplus_material_stock_in_analysis_label_failed'.tr,
      );
    }
  }

  bool checkSubmitData() {
    if (state.materialList.isEmpty) {
      msgDialog(
        content: 'sap_surplus_material_stock_in_no_data_submit'.tr,
      );
      return false;
    }
    if (state.materialList.any((v) => v.editQty <= 0)) {
      msgDialog(
        content:
            'sap_surplus_material_stock_in_input_surplus_material_weight_tips'
                .tr,
      );
      return false;
    }
    return true;
  }

  submitSurplusMaterial({required String type}) {
    state.submitSurplusMaterialStockIn(
      surplusMaterialType: type,
      success: (msg) {
        for (var v in state.materialList) {
          v.save();
        }
        state.materialList.value = [];
        state.dispatchOrderNumber.value = '';
        successDialog(content: msg);
      },
      error: (msg) => errorDialog(content: msg),
    );
  }
}
