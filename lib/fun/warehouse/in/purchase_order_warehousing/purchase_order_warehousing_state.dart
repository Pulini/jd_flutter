import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/delivery_order_info.dart';
import 'package:jd_flutter/bean/http/response/purchase_order_warehousing_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class PurchaseOrderWarehousingState {
  var orderList = <PurchaseOrderInfo>[].obs;
  RxDouble orderQty = 0.0.obs;
  RxDouble receivedQty = 0.0.obs;
  var factoryNumber = '';
  var supplierNumber = '';
  var materialList = <String, List<List>>{};
  var orderLabelList = <DeliveryOrderLabelInfo>[];
  var scannedLabelList = <DeliveryOrderLabelInfo>[].obs;
  var canAddPiece = false.obs;
  var hasPassPermission=checkUserPermission('105180106');
  void getPurchaseOrder({
    required String startDate,
    required String endDate,
    required String supplier,
    required String factory,
    required String warehouse,
    required String typeBody,
    required String instruction,
    required String purchaseOrder,
    required String materielCode,
    required String customerPO,
    required String trackNo,
    required Function(String) error,
  }) {
    httpGet(
      loading: 'purchase_order_warehousing_getting_purchase_orders'.tr,
      method: webApiGetPurchaseOrder,
      params: {
        'StartDate': startDate,
        'EndDate': endDate,
        'FactoryType': typeBody,
        'SalesOrder': instruction,
        'SupplierNumber': supplier,
        'Type': '1',
        'PurchaseOrderNumber': purchaseOrder,
        'MaterialCode': materielCode,
        'FactoryCode': factory,
        'FactoryArea': warehouse,
        'customerPO': customerPO,
        'trackNo': trackNo,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        factoryNumber = factory;
        supplierNumber = supplier;
        compute(
          parseJsonToList<PurchaseOrderInfo>,
          ParseJsonParams(response.data, PurchaseOrderInfo.fromJson),
        ).then((list) {
          orderList.value = list;
        });
      } else {
        orderList.value = [];
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void getSupplierLabelInfo({
    required Function(List<DeliveryOrderLabelInfo>) success,
    required Function(String msg) error,
  }) {
    sapPost(
      loading: 'purchase_order_warehousing_getting_orders_scan_detail'.tr,
      method: webApiSapGetSupplierLabelInfo,
      body: {
        'WERKS': factoryNumber,
        'LIFNR': supplierNumber,
      },
    ).then((response) {
      orderLabelList.clear();
      if (response.resultCode == resultSuccess) {
        success.call([
          for (var json in response.data) DeliveryOrderLabelInfo.fromJson(json)
        ]);
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
