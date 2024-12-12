import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils/utils.dart';

import '../../../bean/http/response/sap_no_label_stock_in_info.dart';
import '../../../utils/web_api.dart';

class SapNoLabelStockInState {
  var orderList = <List<SapNoLabelStockInItemInfo>>[].obs;

  SapNoLabelStockInState() {
    ///Initialize variables
  }

  queryOrderList({
    required String reportStartDate,
    required String reportEndDate,
    required String dispatchNumber,
    required String materialCode,
    required String process,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在获取待入库列表...',
      method: webApiSapGetNoLabelStockInOrderList,
      body: {
        'ZZBGRQ_F': reportStartDate,
        'ZZBGRQ_T': reportEndDate,
        'DISPATCH_NO': dispatchNumber,
        'MATNR': materialCode,
        'KTSCH': process,
        'ERDAT_F': '',
        'ERDAT_T': '',
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <List<SapNoLabelStockInItemInfo>>[];
        groupBy(<SapNoLabelStockInInfo>[
          for (var json in response.data) SapNoLabelStockInInfo.fromJson(json)
        ], (v) => v.dispatchNumber).forEach((k, v) {
          var mList = <SapNoLabelStockInItemInfo>[];
          groupBy(v, (v) => v.materialCode).forEach((k1, v1) {
            mList.add(SapNoLabelStockInItemInfo.fromDataList(v1));
          });
          list.add(mList);
        });
        orderList.value = [...list];
      } else {
        orderList.value = [];
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  submitNoLabelStockIn({
    required String leaderNumber,
    required ByteData leaderSignature,
    required String userNumber,
    required ByteData userSignature,
    required String process,
    required String postingDate,
    required Function(String) success,
    required Function(String) error,
  }) {
    var mList = <SapNoLabelStockInInfo>[];
    orderList
        .where((v) => v.any((v2) => v2.select && v2.pickQty() > 0))
        .forEach(
      (v) {
        for (var v2 in v) {
          mList.addAll(v2.materialList);
        }
      },
    );

    sapPost(
      loading: '正在提交入库...',
      method: webApiSapSubmitNoLabelStockIn,
      body: {
        'KTSCH': process,
        'BUDAT': postingDate,
        'ITEM': [
          for (var item in mList)
            {
              'DISPATCH_NO': item.dispatchNumber,
              'DISPATCH_ITEM': item.dispatchLineNumber,
              'WEMNG': item.pickQty,
              'MENGE': '',
              'WERKS': item.factoryNo,
              'AUFNR': item.productionOrderNo,
              'LGORT': getWarehouseCode(process),
              'USNAM': userInfo?.number,
              'ZNAME_CN': userInfo?.name,
              'ZNAME_EN': '',
              'MEINS': item.basicUnit,
              'MATNR': item.materialCode,
              'ZFTRAYNO': '',
              'ZBQID': '',
              'ZLOCAL': '',
            }
        ],
        'PICTURE': [
          {
            'ZZKEYWORD': leaderNumber,
            'ZZITEMNO': 1,
            'ZZDATA': base64Encode(leaderSignature.buffer.asUint8List()),
          },
          {
            'ZZKEYWORD': userNumber,
            'ZZITEMNO': 2,
            'ZZDATA': base64Encode(userSignature.buffer.asUint8List()),
          },
        ],
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message??'');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
  String getWarehouseCode(String processId) {
    switch (processId) {
      case 'ZHUS':
        return '1101';
      case 'BL':
        return '1102';
      case 'YT':
        return '1103';
      case 'ZL':
        return '1105';
      default:
        return '';
    }
  }
}
