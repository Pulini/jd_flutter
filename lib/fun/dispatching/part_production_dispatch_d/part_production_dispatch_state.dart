import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/part_production_dispatch_info.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class PartProductionDispatchState {
  var isSelectedClosed = false.obs;
  var orderList = <PartProductionDispatchOrderInfo>[].obs;
  PartProductionDispatchOrderDetailInfo? detailInfo;
  var instructionList = <String>[].obs;
  var instructionSelect = 0.obs;
  var sizeList = <CreateLabelInfo>[].obs;
  var isSingleInstruction = true.obs;
  var isSingleSize = true.obs;
  var checkSizeQty = true.obs;
  var createLastLabel = false.obs;
  WorkerInfo? worker;
  var createCount = 0.obs;
  var createCountMax = 0.obs;
  var errorMsg = ''.obs;
  var workerName = ''.obs;
  var created = false.obs;
  var labelList = <PartProductionDispatchLabelInfo>[].obs;
  var deleted = false.obs;

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

  void createLabel({
    required int count,
    required List<Map> sizeMapList,
    required Function(String) success,
    required Function(String) error,
  }) {

    httpPost(
      method: webApiCreatePartProductionDispatchLabels,
      loading: '正在创建贴标...',
      body: {
        'EmpID': worker!.empID,
        'CreateCount': count,
        'SeOrderType': isSingleInstruction.value ? '1' : '2',
        'PackageType': isSingleSize.value ? '478' : '479',
        'IsCreateTailLabel': createLastLabel.value,
        'SizeList': sizeMapList,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        created.value = true;
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  void getPartProductionDispatchLabelList({
    required List<int> orders,
    required Function() success,
    required Function(String msg) error,
  }) {
    httpGet(
      method: webApiGetPartProductionDispatchLabelList,
      loading: '正常查询贴标列表...',
      body: {'WorkCardIDs': orders},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        labelList.value = [
          for (var json in response.data)
            PartProductionDispatchLabelInfo.fromJson(json)
        ];
        success.call();
      } else {
        labelList.value = [];
        error.call(response.message ?? '');
      }
    });
  }

  void deleteLabelList({
    required List<String> labelList,
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    httpGet(
      method: webApiDeletePartProductionDispatchLabels,
      loading: '正在删除贴标...',
      body: {'CardNos': labelList},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        deleted.value = true;

        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? '');
      }
    });
  }
}
