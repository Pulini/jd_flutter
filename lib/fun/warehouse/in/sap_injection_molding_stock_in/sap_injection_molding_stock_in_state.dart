import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/bar_code.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/sap_injection_molding_stock_in_info.dart';
import 'package:jd_flutter/bean/http/response/sap_label_info.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class SapInjectionMoldingStockInState {
  var barCodeList = <BarCodeInfo>[].obs;
  var usedList = <String>[];
  var palletNumber = ''.obs;
  PalletDetailItem2Info? pallet;
  var reportList = <List<SapInjectionMoldingStockInInfo>>[];

  SapInjectionMoldingStockInState() {
    BarCodeInfo.getSave(
      type: barCodeTypes[0],
      callback: (list) => barCodeList.value = list,
    );
  }

  checkPallet({
    required List<String> pallets,
    required Function(PalletDetailInfo) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'sap_injection_molding_stock_in_getting_pallet_info'.tr,
      method: webApiSapGetPalletList,
      body: {
        'WERKS': '1500',
        'LGORT': userInfo?.defaultStockNumber,
        'ZTRAY_CFM': 'X',
        'ITEM': [
          for (var pallet in pallets)
            {
              'ZLOCAL': '',
              'ZFTRAYNO': pallet,
              'BQID': '',
              'SATNR': '',
              'MATNR': '',
              'SIZE1': '',
              'ZVBELN_ORI': '',
              'KDAUF': '',
            }
        ]
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(PalletDetailInfo.fromJson(response.data));
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  getSapLabelList({
    required Function(String) error,
    required Function() refresh,
  }) {
    sapPost(
      loading: 'sap_injection_molding_stock_in_getting_label_status'.tr,
      method: webApiSapGetMaterialDispatchLabelList,
      body: [
        {
          'ZBQLX': '10', //10生产标签20销售标签（选填）
          'ZBQZT': '30', //10创建 20打印 30报工 40入库 50上架 60下架 70销售出库 80标签变更
          'DISPATCH_NO': '',
        }
      ],
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        compute(
          parseJsonToList<SapLabelInfo>,
          ParseJsonParams(response.data, SapLabelInfo.fromJson),
        ).then((list) {
          usedList = list.map((v) => v.labelID ?? '').toList();
          for (var v in barCodeList) {
            v.isUsed = usedList.contains(v.code);
          }
          barCodeList.refresh();
        });
      } else {
        usedList.clear();
        error.call(response.message ?? '');
      }
      refresh.call();
    });
  }

  getStockInReport({
    required List<BarCodeInfo> list,
    required Function() success,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'sap_injection_molding_stock_in_getting_summary_info'.tr,
      method: webApiSapGetStockInReport,
      body: [
        for (var v in list)
          {
            'DISPATCH_NO': '',
            'KTSCH': '',
            'ZFTRAYNO': palletNumber.value,
            'BQID': v.code,
            'ZZCM': '',
          }
      ],
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        groupBy([
          for (var json in response.data)
            SapInjectionMoldingStockInInfo.fromJson(json)
        ], (v) => '${v.dispatchNumber}${v.typeBody}${v.size}').forEach((k, v) {
          reportList.add(v);
        });
        success.call();
      } else {
        usedList.clear();
        error.call(response.message ?? '');
      }
    });
  }

  submitInjectionMoldingStockIn({
    required String leaderNumber,
    required ByteData leaderSignature,
    required String userNumber,
    required ByteData userSignature,
    required String postingDate,
    required Function(String) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'sap_injection_molding_stock_in_submitting_stock_in'.tr,
      method: webApiSapInjectionMoldingStockIn,
      body: {
        'KTSCH': 'ZHUS',
        'BUDAT': postingDate,
        'ITEM': [
          for (var item in reportList)
            {
              'DISPATCH_NO': item[0].dispatchNumber,
              'DISPATCH_ITEM': item[0].dispatchLineNumber,
              'WEMNG': item
                  .map((v) => v.dispatchQty ?? 0)
                  .reduce((a, b) => a.add(b)),
              'MENGE': item
                  .map((v) => v.dispatchQty ?? 0)
                  .reduce((a, b) => a.add(b)),
              'WERKS': item[0].factoryNo,
              'AUFNR': item[0].productionOrderNo,
              'LGORT': '1101',
              'USNAM': userInfo?.number,
              'ZNAME_CN': userInfo?.name,
              'ZNAME_EN': '',
              'MEINS': item[0].basicUnit,
              'MATNR': item[0].materialCode,
              'ZFTRAYNO': item[0].palletNumber,
              'ZBQID': item[0].labelNumber,
              'ZLOCAL': '9999',
            }
        ],
        'PICTURE': [
          {
            'ZZKEYWORD': userNumber,
            'ZZITEMNO': 1,
            'ZZDATA': base64Encode(userSignature.buffer.asUint8List()),
          },
          {
            'ZZKEYWORD': leaderNumber,
            'ZZITEMNO': 2,
            'ZZDATA': base64Encode(leaderSignature.buffer.asUint8List()),
          },
        ]
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        reportList.clear();
        palletNumber.value = '';
        pallet = null;
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? '');
      }
    });
  }
}
