import 'package:get/get.dart';
import 'package:jd_flutter/utils/web_api.dart';

class SapSalesShipmentState {
  var orderList = <String>[].obs;

  SapSalesShipmentState() {
    ///Initialize variables
  }

  querySalesShipmentList({
    required String instructionNo,
    required String deliveryDate,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在查询待出货列表...',
      method: webApiSapGetSalesShipmentList,
      body: [
        {
          'ZVBELN_ORI': instructionNo,
          'EDATU': deliveryDate,
          'WERKS': '1500',
        }
      ],
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        // var list = <SapPalletDetailInfo>[
        //   for (var json in response.data) SapPalletDetailInfo.fromJson(json)
        // ];
        // for (var item in materialList) {
        //   list.removeWhere((v) => v.labelCode == item.labelCode);
        // }
        // materialList.addAll(list);
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
