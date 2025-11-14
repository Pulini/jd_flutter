import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/sap_scan_code_inventory_info.dart';
import 'package:jd_flutter/utils/web_api.dart';

class SapScanCodeInventoryState {
  var orderType = ''.obs;
  var palletList = <RxList<InventoryPalletInfo>>[].obs;
  var materialList = <InventoryPalletInfo>[].obs;


  void getInventoryPalletList({
    required bool isScan,
    required String factory,
    required String warehouse,
    required String area,
    required Function(String message) error,
  }) {
    sapPost(
      loading: 'sap_inventory_getting_inventory_detail'.tr,
      method: webApiSapGetInventoryPalletList,
      body: {
        'WERKS': factory,
        'LGORT': warehouse,
        'ZLOCAL': isScan?area:'',
        'ZTYPE': orderType.value,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        compute(
          parseJsonToList<InventoryPalletInfo>,
          ParseJsonParams(
            response.data,
            InventoryPalletInfo.fromJson,
          ),
        ).then((list) {
          if(isScan){
            var group = <RxList<InventoryPalletInfo>>[];
            groupBy(list, (v) => v.palletNumber).forEach((k, v) {
              group.add([...v].obs);
            });
            palletList.value = group;
          }else{
            materialList.value=list;
          }
        });
      } else {
        palletList.value = [];
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void submitInventory({
    required bool isScan,
    required ByteData signature,
    required String signatureNumber,
    required Function(String) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'sap_inventory_submitting_inventory_result'.tr,
      method: webApiSapSubmitInventory,
      body: {
        'ZTYPE': orderType.value,
        'PICTURE': [
          {
            'ZZKEYWORD': signatureNumber,
            'ZZITEMNO': 2,
            'ZZDATA': base64Encode(signature.buffer.asUint8List())
          }
        ],
        'ITEM': [
          for (var g in palletList)
            for (var item in g.where((v) => v.isSelected.value))
              item.toSubmitJson(isScan, signatureNumber, orderType.value)
        ]
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message??'');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
