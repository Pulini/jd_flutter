import 'package:get/get.dart';

import '../../../bean/http/response/smart_delivery_info.dart';
import '../../../utils/web_api.dart';

class SmartDeliveryState {
  var pageIndex = 0.obs;
  var orderList = <SmartDeliveryOrderInfo>[].obs;

  SmartDeliveryState() {
    ///Initialize variables
  }

  querySmartDeliveryOrder({
    required bool showLoading,
    required String startTime,
    required String endTime,
    required String deptIDs,
    required Function() success,
    required Function(String) error,
  }) {
    httpGet(
      loading: showLoading ? '正在获取派工单数据...' : '',
      method: webApiSmartDeliveryGetWorkCardList,
      params: {
        'PageIndex': pageIndex.value,
        'PageSize': 10,
        'StartTime': startTime,
        'EndTime': endTime,
        'DeptIDs': deptIDs,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        orderList.value = [
          for (var json in response.data) SmartDeliveryOrderInfo.fromJson(json)
        ];
        success.call();
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
