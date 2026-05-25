import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:jd_flutter/bean/http/response/pack_order_list_info.dart';
import 'package:jd_flutter/utils/web_api.dart';

class PackOrderListState {
  var packOrderList = <OrderPackageInfo>[].obs;
  var packProfileList = <PackProfileInfo>[].obs;

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
      loading: 'part_dispatch_pack_order_no_input_tips'.tr,
      body: {
        'workCardNo': dispatchOrderNo,
        'productName': typeBody,
        'beginDate': startDate,
        'endDate': endDate,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var data = PackOrderInfo.fromJson(response.data);
        packOrderList.value = data.orderPackageList;
        packProfileList.value = data.packageProfileList;
        success.call();
      } else {
        packOrderList.value = [];
        packProfileList.value = [];
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
      method: webApiCleanLabelFormPackID,
      loading: 'part_dispatch_pack_order_delete_order_tips'.tr,
      params: {'InterID': id},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  void modifyOrderPackProfile({
    required int packOrderID,
    required int packProfileID,
    required double capacityQty,
    required void Function(String) success,
    required void Function(String) error,
  }) {
    httpPost(
      method: webApiModifyPackProfile,
      loading: 'part_dispatch_pack_order_no_delete_permission'.tr,
      params: {
        'PackOrderID': packOrderID,
        'PackProfileID': packProfileID,
        'CapacityQty': capacityQty,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? '');
      }
    });
  }
}
