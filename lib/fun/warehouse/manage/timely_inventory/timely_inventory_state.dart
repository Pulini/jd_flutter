import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/timely_inventory_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class TimelyInventoryState {
  var dataList = <TimelyInventoryInfo>[].obs;

  //获取及时库存
  getImmediateStockList({
    required String factoryNumber,
    required String stockId,
    required String instructionNumber,
    required String materialCode,
    required String batch,
    required Function(String s) error,
  }) {
    httpGet(
        method: webApiGetImmediateStockList,
        loading: 'timely_inventory_get_inventory_data'.tr,
        params: {
          'MtoNo': instructionNumber,
          'MaterialNumber': materialCode,
          'StockID': stockId,
          'FactoryNumber': factoryNumber,
          'Batch': batch,
        }).then((response) {
      if (response.resultCode == resultSuccess) {
        dataList.value = [
          for (var json in response.data) TimelyInventoryInfo.fromJson(json)
        ];
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  //修改库位
  modifyStorageLocation({
    required TimelyInventoryInfo data,
    required TimeItems item,
    required String newLocation,
    required Function(String) success,
    required Function(String s) error,
  }) {
    httpPost(
      method: webApiModifyStorageLocation,
      loading: 'timely_inventory_submitting_modifications'.tr,
      body: {
        'BatchNumber': item.batch,
        'StockID': data.stockID,
        'MaterialCode': data.materialNumber,
        'Factory': data.factoryNumber,
        'Location': newLocation,
        'Operator': userInfo?.userID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
