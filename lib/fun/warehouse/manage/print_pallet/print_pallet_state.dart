import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_info.dart';
import 'package:jd_flutter/utils/web_api.dart';

class PrintPalletState {
  var palletNo = ''.obs;
  var factory = '';
  var palletList = <List<SapPalletDetailInfo>>[].obs;
  var selectedList = <RxBool>[].obs;

  getPalletInfo({
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
            'WERKS': factory,
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
}
