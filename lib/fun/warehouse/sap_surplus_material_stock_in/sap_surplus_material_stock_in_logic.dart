import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import '../../../bean/http/response/sap_surplus_material_info.dart';
import '../../../utils/web_api.dart';
import 'sap_surplus_material_stock_in_state.dart';

class SapSurplusMaterialStockInLogic extends GetxController {
  final SapSurplusMaterialStockInState state = SapSurplusMaterialStockInState();

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
        return '地磅断开';
      case 'WEIGHT_MSG_DEVICE_NOT_CONNECTED':
        return '地磅未连接';
      case 'WEIGHT_MSG_OPEN_DEVICE_SUCCESS':
        return '地磅连接成功';
      case 'WEIGHT_MSG_OPEN_DEVICE_FAILED':
        return '地磅连接失败';
      case 'WEIGHT_MSG_READ_ERROR':
        return '地磅连接异常';
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
      logger.f(codeData.toJson());
      if (state.materialList.isNotEmpty &&
          state.materialList[0].dispatchNumber != codeData.dispatchNumber) {
        informationDialog(content: '请扫描同一派工单的料头贴标！！');
        return;
      }
      if (state.materialList.any((v) => v.number == codeData.stubBar)) {
        informationDialog(content: '此料头已扫！！');
        return;
      }
      if (state.materialList.length == 3) {
        informationDialog(content: '一次只能入库 3 种料头！！');
        return;
      }
      if (await codeData.isExist()) {
        informationDialog(content: '标签已入库！！');
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
      errorDialog(content: '解析标签失败！！');
    }
  }

  bool checkSubmitData() {
    if (state.materialList.isEmpty) {
      informationDialog(content: '无数据可提交！！');
      return false;
    }
    if (state.materialList.any((v) => v.editQty <= 0)) {
      informationDialog(content: '请填写料头重量！！');
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
        state.materialList.value=[];
        state.dispatchOrderNumber.value='';
        successDialog(content: msg);
      },
      error: (msg) => errorDialog(content: msg),
    );
  }
}
