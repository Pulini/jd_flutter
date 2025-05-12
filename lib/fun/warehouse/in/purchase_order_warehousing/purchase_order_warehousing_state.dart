import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/purchase_order_warehousing_info.dart';
import 'package:jd_flutter/utils/web_api.dart';

class PurchaseOrderWarehousingState {
  var typeBody = ''.obs;
  var instruction = ''.obs;
  var purchaseOrder = ''.obs;
  var materielCode = ''.obs;
  var customerPO = ''.obs;
  var trackNo = ''.obs;
  var orderList = <PurchaseOrderInfo>[].obs;
  RxDouble orderQty = 0.0.obs;
  RxDouble receivedQty = 0.0.obs;
  var factoryNumber = '';

  getPurchaseOrder({
    required String startDate,
    required String endDate,
    required String supplierNumber,
    required String factory,
    required String warehouse,
    required Function(String) error,
  }) {
    httpGet(
      loading: 'purchase_order_warehousing_getting_purchase_orders'.tr,
      method: webApiGetPurchaseOrder,
      params: {
        'StartDate': startDate,
        'EndDate': endDate,
        'FactoryType': typeBody.value,
        'SalesOrder': instruction.value,
        'SupplierNumber': supplierNumber,
        'Type': '1',
        'PurchaseOrderNumber': purchaseOrder.value,
        'MaterialCode': materielCode.value,
        'FactoryCode': factory,
        'FactoryArea': warehouse,
        'customerPO': customerPO.value,
        'trackNo': trackNo.value,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        factoryNumber = factory;
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
}
