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

  SapSalesShipmentState() {
    //Initialize variables
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

  postingSalesShipment({
    required Function(String) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在提交销售出库...',
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

  checkPalletOrLabel({
    required String instructionNo,
    required Function(List<SapPalletDetailInfo>) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在获取托盘信息...',
      method: webApiSapGetPalletDetails,
      body: {
        'ZTYPE': '4',
        'ITEM': [
          {
            'ZFTRAYNO': '',
            'BQID': '',
            'ZZVBELN': instructionNo,
            'MATNR': '',
            'WERKS': '1500',
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
