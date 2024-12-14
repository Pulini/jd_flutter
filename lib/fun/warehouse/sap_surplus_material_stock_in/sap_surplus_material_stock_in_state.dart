import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../bean/http/response/base_data.dart';
import '../../../bean/http/response/sap_surplus_material_info.dart';
import '../../../utils/web_api.dart';

const surplusMaterialType = <String>[
  '生产',
  '研发',
  '底厂报废',
  '鞋厂报废',
  '扫地料',
  '补产',
  '车间退料',
];

class SapSurplusMaterialStockInState {
  var dispatchOrderNumber = ''.obs;
  var weight = (0.0).obs;
  var materialList = <SurplusMaterialLabelInfo>[].obs;
  var historyList = <List<SurplusMaterialHistoryInfo>>[].obs;
  var interceptorText = '';
  var weighbridgeStateText = ''.obs;
  var weighbridgeStateTextColor = Colors.black.obs;

  SapSurplusMaterialStockInState() {}

  getSurplusMaterialHistory({
    required String startDate,
    required String endDate,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在查询历史记录...',
      method: webApiSapSurplusMaterialHistory,
      body: {
        'DATEF': startDate,
        'DATET': endDate,
        'I_WERKS': '1500',
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        compute(
          parseJsonToList<SurplusMaterialHistoryInfo>,
          ParseJsonParams<SurplusMaterialHistoryInfo>(
            response.data,
            SurplusMaterialHistoryInfo.fromJson,
          ),
        ).then((list) {
          var history = <List<SurplusMaterialHistoryInfo>>[];
          groupBy(list, (v) => v.surplusMaterialCode).forEach((k, v) {
            history.add(v);
          });
          historyList.value = history;
        });
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  getMaterialInfoByCode({
    required String dispatchNumber,
    required String code,
    required Function(MaterialDetailInfo) success,
    required Function(String) error,
  }) {
    httpGet(
      loading: '正在获取料头信息...',
      method: webApiMesGetMaterialInfo,
      params: {'Code': code},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        dispatchOrderNumber.value = dispatchNumber;
        success.call([
          for (var json in response.data) MaterialDetailInfo.fromJson(json)
        ][0]);
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  submitSurplusMaterialStockIn({
    required String surplusMaterialType,
    required Function(String) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在查询历史记录...',
      method: webApiSapPostingSurplusMaterial,
      body: {
        'I_LTTYPE': surplusMaterialType,
        'I_DISPATCH_NO': dispatchOrderNumber.value,
        'I_LT1': materialList[0].number,
        'I_LT2': materialList.length == 2 ? materialList[1].number : '',
        'I_LT3': materialList.length == 3 ? materialList[2].number : '',
        'I_MENGE1': materialList[0].editQty,
        'I_MENGE2': materialList.length == 2 ? materialList[1].editQty : '',
        'I_MENGE3': materialList.length == 3 ? materialList[2].editQty : '',
        'I_BUDAT': '',
        'I_WERKS': '1500',
        'I_LGORT': '',
        'I_STOKZ': '',
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
