import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class PrintPalletState {
  var palletNo = ''.obs;
  var palletList = <List<SapPalletDetailInfo>>[].obs;
  var selectedList = <RxBool>[].obs;

  void getPalletInfo({
    required String pallet,
    required Function(List<SapPalletDetailInfo>) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'sap_sales_shipment_getting_pallet_info_tips'.tr,
      method: webApiSapGetPalletInfo,
      body: {
        'ZTYPE': '',
        'ITEM': [
          {
            'ZFTRAYNO': pallet,
            'BQID': '',
            'ZZVBELN': '',
            'MATNR': '',
            'WERKS': '',
          }
        ],
      },
    ).then((response) async {
      if (response.resultCode == resultSuccess) {
        success.call(await compute(
          parseJsonToList,
          ParseJsonParams(response.data, SapPalletDetailInfo.fromJson),
        ));
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void deleteLabel({
    required List<List<String>> list,
    required Function(List<SapPalletDetailInfo>) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'sap_sales_shipment_delete_label'.tr,
      method: webApiSapDeleteLabelFormPallet,
      body: {
        "ZUSNAM": userInfo?.number,
        "ZNAME_CN": userInfo?.name,
        "GT_REQITEMS": [
          for(var label in list)
          {
            "ZFTRAYNO": label.first,//托盘单号
            "ZPIECE_NO": label.last,//件号-标签
          }
        ]
      },
    ).then((response) async {
      if (response.resultCode == resultSuccess) {
        success.call(await compute(
          parseJsonToList,
          ParseJsonParams(response.data, SapPalletDetailInfo.fromJson),
        ));
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
