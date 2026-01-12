import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/part_production_dispatch_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class PartProductionDispatchState {
  var isSelectedClosed = false.obs;
  var orderList = <PartProductionDispatchOrderInfo>[].obs;
  PartProductionDispatchOrderDetailInfo? detailInfo;
  List<List>instructionList=[];
  var sizeList=<PartProductionDispatchOrderDetailSizeInfo>[].obs;
  var created=false.obs;

  PartProductionDispatchState() {
    isSelectedClosed.value =
        spGet('${Get.currentRoute}/isSelectedClosed') ?? false;
  }

  void getPartProductionDispatchOrderList({
    required String startTime,
    required String endTime,
    required String instruction,
    required Function(String msg) error,
  }) {
    httpGet(
      method: webApiGetPartProductionDispatchOrderList,
      loading: 'material_dispatch_querying_order'.tr,
      params: {
        'startTime': startTime,
        'endTime': endTime,
        'moNo': instruction,
        'isClose': isSelectedClosed.value,
        'deptID': userInfo?.departmentID,
        'FDataType': '3',
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        orderList.value = [
          for (var json in response.data)
            PartProductionDispatchOrderInfo.fromJson(json)
        ];
      } else {
        orderList.value = [];
        error.call(response.message ?? '');
      }
    });
  }

  void getPartProductionDispatchOrdersDetail({
    required List<int> orders,
    required Function() success,
    required Function(String msg) error,
  }) {
    httpGet(
      method: webApiGetPartProductionDispatchOrdersDetail,
      loading: 'material_dispatch_querying_order'.tr,
      body: {'WorkCardIDs': orders},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        detailInfo =
            PartProductionDispatchOrderDetailInfo.fromJson(response.data);
        success.call();
      } else {
        detailInfo = null;
        error.call(response.message ?? '');
      }
    });
  }
}
