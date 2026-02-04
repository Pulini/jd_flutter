import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:jd_flutter/bean/http/response/pack_order_list_info.dart';
import 'package:jd_flutter/utils/web_api.dart';

class PackOrderListState {
  var packOrderList = <PackOrderInfo>[].obs;


  void getPackOrderList({
    required String dispatchOrderNo,
    required String typeBody,
    required String startDate,
    required String endDate,
    required Function() success,
    required Function(String msg) error,
  }) {
    httpGet(
      method: webApiGetOrderPackageList,
      loading: '正在获取包装清单列表...',
      body: {
        'workCardNo': dispatchOrderNo,
        'productName': typeBody,
        'beginDate': startDate,
        'endDate': endDate,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        packOrderList.value = [
          for (var item in response.data) PackOrderInfo.fromJson(item)
        ];
        success.call();
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  void deletePackOrder({
    required int id,
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    httpPost(
      method: webApiCleanLabel,
      loading: '正在删除包装清单...',
      params: {'InterID': id},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? '');
      }
    });
  }


}
