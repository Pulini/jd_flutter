import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_receipt_reversal_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class SapPickingReceiptReversalState {
  var orderList = <PickingReceiptReversalInfo>[].obs;
  var select = -1.obs;


  void queryOrderList({
    required String order,
    required String materialCode,
    required int orderType,
    required String startDate,
    required String endDate,
    required String warehouse,
    required Function(String) error,
  }) {
    sapPost(
      loading: orderType == 1
          ? 'sap_picking_receipt_reversal_getting_picking_list'.tr
          : 'sap_picking_receipt_reversal_getting_take_list'.tr,
      method: webApiSapProductionReceipt,
      body: {
        'ZTYPE': orderType,
        'DISPATCH_NO': order,
        'DATEF': startDate,
        'DATET': endDate,
        'WERKS': '1500',
        'LGORT': warehouse,
        'MATNR': materialCode,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        compute(
          parseJsonToList<PickingReceiptReversalInfo>,
          ParseJsonParams(response.data, PickingReceiptReversalInfo.fromJson),
        ).then((list) => orderList.value = list);
      } else {
        orderList.value = [];
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void productionReceiptWriteOff({
    required String leaderNumber,
    required ByteData leaderSignature,
    required String userNumber,
    required ByteData userSignature,
    required String postingDate,
    required Function(String) success,
    required Function(String) error,
  }) {
    orderList[select].item?.forEach((v) => {});
    sapPost(
      loading: 'sap_picking_receipt_reversal_getting_take_list'.tr,
      method: webApiSapProductionReceipt,
      body: {
        'BUDAT': postingDate,
        'USNAM': userInfo?.number,
        'ZNAME_CN': userInfo?.name,
        'ZNAME_EN': '',
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
        'DATA': [
          for (var item in orderList[select].item!)
            {
              'ZTYPE': orderList[select].head?.type,
              'DATE': orderList[select].head?.date,
              'MBLNR': orderList[select].head?.materialVoucherNo,
              'DISPATCH_NO': item.order,
            }
        ],
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
