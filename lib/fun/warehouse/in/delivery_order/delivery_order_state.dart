import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/delivery_order_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class DeliveryOrderState {
  var stockType = 0.obs;
  var orderType = 1.obs;
  var deliveryOrderList = <List<DeliveryOrderInfo>>[].obs;

  DeliveryOrderState() {
    ///Initialize variables
  }

  getDeliveryOrders({
    required String startDate,
    required String endDate,
    required String typeBody,
    required String instruction,
    required String supplier,
    required String purchaseOrder,
    required String materialCode,
    required String company,
    required String workerNumber,
    required String workCenter,
    required String warehouse,
    required String factory,
    required Function(String) success,
    required Function(String) error,
  }) {
    httpGet(
      loading: '正在查询送货单列表...',
      method: webApiGetDeliveryOrders,
      params: {
        'beginDate': startDate,
        'endDate': endDate,
        'productName': typeBody,
        'scMONO': instruction,
        'supplyNo': supplier,
        'deliNO': purchaseOrder,
        'materialNo': materialCode,
        'finishType': orderType.value.toString(),
        'factoryArea': company,
        'character': userInfo?.sapRole,
        'empCode': workerNumber,
        'line': workCenter,
        'stockNo': warehouse,
        'finishStock': stockType.value == 1
            ? 'NotInStorage'
            : stockType.value == 2
                ? 'InStorageNoOut'
                : stockType.value == 3
                    ? 'OutOfStock'
                    : 'All',
        'factoryNo': factory,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        compute(
          parseJsonToList<DeliveryOrderInfo>,
          ParseJsonParams(
            response.data,
            DeliveryOrderInfo.fromJson,
          ),
        ).then((list) {
          var newList=<List<DeliveryOrderInfo>>[];
          groupBy(list, (v)=>v.deliNo??'').forEach((k,v){
            newList.add(v);
          });
          deliveryOrderList.value=newList;
        });
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
