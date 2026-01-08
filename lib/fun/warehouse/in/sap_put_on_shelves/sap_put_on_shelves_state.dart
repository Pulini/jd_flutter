import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_info.dart';
import 'package:jd_flutter/bean/http/response/sap_put_on_shelves_info.dart';
import 'package:jd_flutter/utils/web_api.dart';

class SapPutOnShelvesState {
  var labelList = <List<List<PalletDetailItem1Info>>>[].obs;
  var scanLabelList = <PalletDetailItem1Info>[].obs;
  var palletNumber = ''.obs;



  void getPalletList({
    required String warehouse,
    required Function() refresh,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'sap_put_on_shelves_getting_wait_put_on_shelves_list'.tr,
      method: webApiSapGetPalletList,
      body: {
        'WERKS':  '2000',
        'LGORT': warehouse,
        'ZTRAY_CFM': '',
        'ITEM': [
          {
            'ZLOCAL': '9999',
            'ZFTRAYNO': '',
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
        compute(
          parseJsonToData<PalletDetailInfo>,
          ParseJsonParams(response.data, PalletDetailInfo.fromJson),
        ).then((list) {
          var pallet = <List<List<PalletDetailItem1Info>>>[];
          groupBy(list.item1 ?? <PalletDetailItem1Info>[],
              (v) => v.palletNumber).forEach((k, v) {
            var material = <List<PalletDetailItem1Info>>[];
            groupBy(v, (v2) => v2.materialNumber).forEach((k2, v2) {
              material.add(v2);
            });
            pallet.add(material);
          });
          labelList.value = pallet;
          refresh.call();
        });
      } else {
        labelList.value = [];
        refresh.call();
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  //    操作类型
  //    WM01	上架
  //    WM02	下架
  //    WM03	移仓
  //    WM04	盘点
  //    WM05	收货
  //    WM06	发货
  //    WM07	标签绑定
  //    WM08	并筐合标
  //    WM09	注塑换标出库
  //    WM10	喷漆换标入库
  void getRecommendLocation({
    required String factory,
    required String warehouse,
    required String palletNumber,
    required Function(String) location,
    required Function(String) error,
  }) {
    sapPost(
      loading:
          'sap_put_on_shelves_getting_recommended_storage_location_info'.tr,
      method: webApiSapGetRecommendLocation,
      body: {
        'ZCZLX_WMS': 'WM01',
        'ITEM': [
          {
            'WERKS': factory,
            'LGORT': warehouse,
            'ZFTRAYNO': palletNumber,
          }
        ]
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        location.call([
              for (var json in response.data)
                RecommendLocationInfo.fromJson(json)
            ][0]
                .location ??
            '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void puttingOnShelves({
    required String warehouse,
    required String location,
    required Function(String) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'sap_put_on_shelves_submitting_put_on_shelves'.tr,
      method: webApiSapPuttingOnShelves,
      body: {
        'ZCZLX_WMS': 'WM01',
        'WERKS':  '2000',
        'LGORT': warehouse,
        'ITEM': [
          {
            'ZSHKZG': '',
            'ZLOCAL_F': scanLabelList[0].location,
            'ZLOCAL_T': location,
            'ZFTRAYNO_F': scanLabelList[0].palletNumber,
            'ZFTRAYNO_T': scanLabelList[0].palletNumber,
            'BQID': '',
            'MATNR': '',
            'CHARG': '',
            'SOBKZ': '',
            'KDAUF': '',
            'KDPOS': '',
            'ZZVBELN': '',
            'ZZXTNO': '',
            'SIZE1': '',
            'MENGE': 0,
            'MEINS': '',
          }
        ]
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
