import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils/utils.dart';

import '../../../bean/http/response/sap_picking_info.dart';
import '../../../utils/web_api.dart';

class SapRelocationPickingState {
  var materialList = <SapPalletDetailInfo>[].obs;

  SapRelocationPickingState() {
    ///Initialize variables
  }

  checkPalletOrLabel({
    required String pallet,
    required String label,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在校验标签信息...',
      method: webApiSapGetPalletDetails,
      body: {
        'ZTYPE': '',
        'ITEM': [
          {
            'ZFTRAYNO': pallet,
            'BQID': label,
            'ZZVBELN': '',
            'MATNR': '',
            'WERKS': '1500',
          }
        ],
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <SapPalletDetailInfo>[
          for (var json in response.data) SapPalletDetailInfo.fromJson(json)
        ];
        for (var item in materialList) {
          list.removeWhere((v) => v.labelCode == item.labelCode);
        }
        materialList.addAll(list);
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  relocationPicking({
    required String pickerNumber,
    required ByteData pickerSignature,
    required String userNumber,
    required ByteData userSignature,
    required String warehouse,
    required Function(String) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在提交领料...',
      method: webApiSapRelocationPicking,
      body: {
        'WERKS': '1500',
        'LGORT': warehouse,
        'ZBILLER': userInfo?.number,
        'ZNAME_CN': userInfo?.name,
        'GT_REQITEMS': [
          for(var item in materialList)
          {
            'BQID': item.labelCode,
            'MENGE': item.pickQty,
          }
        ],
        'GT_PICTURE': [
          {
            'ZZKEYWORD': userNumber,
            'ZZITEMNO': 1,
            'ZZDATA': base64Encode(userSignature.buffer.asUint8List()),
          },
          {
            'ZZKEYWORD': pickerNumber,
            'ZZITEMNO': 2,
            'ZZDATA': base64Encode(pickerSignature.buffer.asUint8List()),
          }
        ],
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        materialList.clear();
        success.call(response.data.toString());
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
