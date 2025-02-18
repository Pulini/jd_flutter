import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/sap_forming_scan_label_info.dart';
import 'package:jd_flutter/utils/web_api.dart';


class SapProduceStockInState {
  var barCodeList = <SapProduceStockInLabelInfo>[].obs;
  var factoryId = ''.obs;

  SapProduceStockInState() {
    // barCodeList.add(SapProduceStockInLabelInfo(
    //   division: 'division',
    //   customerPO: 'customerPO',
    //   labelCode: '1234567890',
    //   packingMethod: 'packingMethod',
    //   labelTotalQty: 22,
    //   labelReceivedQty: 11,
    //   needCheck: '',
    //   deliveryOrder: 'deliveryOrder',
    // )..scanQty=1);
  }

  getOrderInfoFromCode({
    required String labelCode,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在读取条码信息...',
      method: webApiSapGetOrderInfoFromCode,
      body: {
        'ZBUSTYPE': '01',
        'WERKS': factoryId.value,
        'ZHGCCRQ': '',
        'ZCTNLABEL': labelCode,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        compute(
          parseJsonToList,
          ParseJsonParams(
            response.data,
            SapProduceStockInLabelInfo.fromJson,
          ),
        ).then((list) {
          for (SapProduceStockInLabelInfo i in list) {
            if (!barCodeList.any((v) => v.labelCode == i.labelCode)) {
              barCodeList.add(i..scanQty = 1);
            }
          }
        });
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
