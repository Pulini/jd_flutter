import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_info.dart';
import 'package:jd_flutter/bean/http/response/sap_sales_shipment_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class SapSalesShipmentState {
  var orderList = <SapSalesShipmentPalletInfo>[].obs;
  var palletList = <List<SapPalletDetailInfo>>[].obs;


  void querySalesShipmentList({
    required String instructionNo,
    required String deliveryDate,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'sap_sales_shipment_querying_wait_stock_out_list_tips'.tr,
      method: webApiSapGetSalesShipmentList,
      body: [
        {
          'ZVBELN_ORI': instructionNo,
          'EDATU': deliveryDate,
          'WERKS':  '2000',
        }
      ],
    ).then((response) {
      orderList.clear();
      if (response.resultCode == resultSuccess) {
        compute(
          parseJsonToList<SapSalesShipmentInfo>,
          ParseJsonParams(
            response.data,
            SapSalesShipmentInfo.fromJson,
          ),
        ).then((list) {
          groupBy(list, (v) => v.instructionNo).forEach((k, v) {
            orderList.add(SapSalesShipmentPalletInfo()..instructionList = v);
          });
        });
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void postingSalesShipment({
    required Function(String) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'sap_sales_shipment_submitting_sales_stock_out_tips'.tr,
      method: webApiSapPostingSalesShipment,
      body: [
        for (var order in orderList)
          for (var label in order.palletList.where((v) => v.pickQty > 0))
            {
              'BQID': label.labelCode,
              'USNAM': userInfo?.number,
              'ZNAME_CN': userInfo?.name,
            }
      ],
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void checkPalletOrLabel({
    required String instructionNo,
    required Function(List<SapPalletDetailInfo>) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'sap_sales_shipment_getting_pallet_info_tips'.tr,
      method: webApiSapGetPalletDetails,
      body: {
        'ZTYPE': '4',
        'ITEM': [
          {
            'ZFTRAYNO': '',
            'BQID': '',
            'ZZVBELN': instructionNo,
            'MATNR': '',
            'WERKS':  '2000',
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
