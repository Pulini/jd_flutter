import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_purchase_stock_in_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';



class SapPurchaseStockInState {
  var warehoused = false.obs;
  var generated = false.obs;
  var orderList = <List<SapPurchaseStockInInfo>>[].obs;
  var selectedList = <bool>[].obs;
  var detailInfo = <SapPurchaseStockInDetailInfo>[].obs;

  SapPurchaseStockInState() {
    ///Initialize variables
  }

  getDeliveryList({
    required String deliNo,
    required String startDate,
    required String endDate,
    required String factory,
    required String warehouse,
    required String supplier,
    required String company,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在获取送货单列表...',
      method: webApiSapGetDeliveryList,
      body: {
        'ZDELINO': deliNo,
        'DATEF': startDate,
        'DATET': endDate,
        'PACKAGETYPE': warehoused.value ? 'InStorageNoOut' : 'NotInStorage',
        'TEMPORARYSTATUS': generated.value,
        'FACTORY': factory,
        'WAREHOUSE': warehouse,
        'LIFNR': supplier,
        'ZQY': company,
        'ZEMPCODE': userInfo?.number,
      },
    ).then((response) {
      orderList.value = [];
      selectedList.value = [];
      if (response.resultCode == resultSuccess) {
        groupBy(<SapPurchaseStockInInfo>[
          for (var json in response.data) SapPurchaseStockInInfo.fromJson(json)
        ], (v) => v.deliveryNumber).forEach((k, v) {
          orderList.add(v);
          selectedList.add(false);
        });
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  getDeliveryDetail({
    required String deliveryNumber,
    required Function() success,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在获取送货单明细...',
      method: webApiSapGetDeliveryDetail,
      body: {'ZDEILNO': deliveryNumber},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        detailInfo.value = [
          for (var json in response.data)
            SapPurchaseStockInDetailInfo.fromJson(json)
        ];
        success.call();
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  checkTemporaryOrder({
    required List<SapPurchaseStockInInfo> list,
    required Function() success,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在检查送货单...',
      method: webApiSapCheckTemporaryOrder,
      body: [
        for (var data in list)
          {
            'ZNO': data.deliveryNumber,
            'ZEMP': userInfo?.number,
          }
      ],
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call();
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  saveDeliveryCheck({
    required String location,
    required String inspector,
    required List<SapPurchaseStockInInfo> list,
    required Function(String) success,
    required Function(String) error,
  }) {
    sapPost(
      method: webApiSapSaveDeliveryCheck,
      body: [
        for (var data in list)
          {
            'ZDELINO': data.deliveryNumber,
            'ZDELIISEQ': data.deliveryOrderLineNumber,
            'ZLGORT': location,
            'ZVERIFYQTY': data.editQty.toShowString(),
            'ZINSPECTOR': inspector,
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
}
