import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/production_tasks_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';


class ProductionTasksState {
  var mqttServer = '192.168.99.229';
  var mqttPort = 1883;
  var mqttTopic = [
    'JJb_WorkLine/${userInfo?.departmentID}/sync/resp',
    'JJb_WorkLine/${userInfo?.departmentID}/rfid_record',
    'JJb_WorkLine/outbox_data',
  ];
  var mqttSend='JJb_WorkLine/${userInfo?.departmentID}/sync';

  var selected = (-1).obs;
  var orderList = <ProductionTasksSubInfo>[];

  var tableInfo = <WorkCardSizeInfos>[].obs;

  var todayTargetQty = (0.0).obs;
  var todayCompleteQty = (0.0).obs;
  var monthCompleteQty = (0.0).obs;

  var typeBody = ''.obs;
  var instructionNo = ''.obs;
  var customerPO = ''.obs;
  var shouldPackQty = (0.0).obs;
  var packagedQty = (0.0).obs;
  var packetWay=<String>[].obs;
  var specificRequirements=<String>[].obs;

  var detailTableInfo = <ProductionTasksDetailItemInfo>[].obs;
  var detailInstructionNo = ''.obs;
  var detailCustomerPO = ''.obs;
  var detailShouldPackQty = (0.0).obs;
  var detailPackagedQty = (0.0).obs;

  ProductionTasksState() {
    //Initialize variables
  }

  getProductionOrderSchedule({
    required Function() success,
    required Function(String msg) error,
  }) {
    httpGet(
        method: webApiGetProductionOrderSchedule,
        loading: '正在查询生产任务进度表...',
        params: {
          'departmentID': getUserInfo()!.departmentID ?? 0,
          // 'departmentID': 554744,
        }).then((response) {
      if (response.resultCode == resultSuccess) {
        var info = ProductionTasksInfo.fromJson(response.data);

        orderList = info.subInfo ?? [];
        todayTargetQty.value = info.toDayPlanQty ?? 0;
        todayCompleteQty.value = info.toDayFinishQty ?? 0;
        monthCompleteQty.value = info.toMonthFinishQty ?? 0;
        refreshUiData();
        success.call();
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  refreshUiData() {
    if (orderList.isNotEmpty) {
      typeBody.value = orderList[0].productName ?? '';
      instructionNo.value = orderList[0].mtoNo ?? '';
      customerPO.value = orderList[0].clientOrderNumber ?? '';
      shouldPackQty.value = orderList[0].shouldPackQty ?? 0;
      packagedQty.value = orderList[0].packagedQty ?? 0;
      tableInfo.value = [
        ...orderList[0].workCardSizeInfo ?? [],
      ];
      packetWay.value=orderList[0].packetWay??[];
      specificRequirements.value=orderList[0].specificRequirements??[];
    } else {
      todayTargetQty.value = 0.0;
      todayCompleteQty.value = 0.0;
      monthCompleteQty.value = 0.0;
      typeBody.value = '';
      instructionNo.value = '';
      customerPO.value = '';
      shouldPackQty.value = 0.0;
      packagedQty.value = 0.0;
      tableInfo.value = [];
      packetWay.value=[];
      specificRequirements.value=[];
    }
  }

  changeSort({
    required List<ProductionTasksSubInfo> newLine,
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    httpPost(
      method: webApiSubmitNewSort,
      loading: 'molding_scan_bulletin_report_submitting'.tr,
      body: [
        for (var i = 0; i < newLine.length; i++)
          {
            'workCardInterID': int.parse(newLine[i].workCardInterID ?? ''),
            'clientOrderNumber': newLine[i].clientOrderNumber,
            'priority': i + 1,
          }
      ],
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  getProductionOrderScheduleDetail({
    required String ins,
    required String po,
    required Function() success,
    required Function(String msg) error,
  }) {
    httpGet(
        method: webApiGetProductionOrderScheduleDetail,
        loading: '正在查询生产任务进度明细...',
        params: {
          'Bill': ins,
          'PO': po,
        }).then((response) {
      if (response.resultCode == resultSuccess) {
        var detail = ProductionTasksDetailInfo.fromJson(response.data);
        detailTableInfo.value = detail.scheduleInfos ?? [];
        detailInstructionNo.value = detail.billNo ?? '';
        detailCustomerPO.value = detail.clientOrderNumber ?? '';
        detailShouldPackQty.value = detail.total ?? 0;
        detailPackagedQty.value = detail.hasInstall ?? 0;
        success.call();
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
