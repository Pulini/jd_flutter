import 'dart:io';

import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/workshop_planning_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class WorkshopPlanningState {
  var planList = <WorkshopPlanningInfo>[].obs;
  var reportWorkerList = <WorkshopPlanningWorkerInfo>[].obs;
  var workerList = <WorkshopPlanningWorkerInfo>[].obs;
  var workerListSelectedIndex = (-1).obs;
  var workTypeList = <WorkshopPlanningWorkTypeInfo>[].obs;
  WorkshopPlanningWorkerInfo? worker;
  var reportQuantity = (0.0).obs;
  var reportDate = ''.obs;
  var price = (0.0).obs;
  var departmentID = '';
  var groupName = '';
  var isDayShift = true.obs;
  var minCoefficient = (0.0).obs;
  var maxCoefficient = (0.0).obs;

  getProcessPlanInfo({
    String? workCardInterID,
    String? routeEntryID,
    String? productionOrderNo,
    String? processName,
    required Function() success,
    required Function(String) error,
  }) {
    httpGet(
      loading: '正在获取工序计划列表...',
      method: webApiProcessPlanningList,
      params: {
        // 'WorkCardInterID':workCardInterID,
        // 'RouteEntryID':routeEntryID,
        // 'ProductionOrderNo':productionOrderNo,
        // 'ProcessName':processName,

        'WorkCardInterID': 960177,
        'RouteEntryID': 2198435,
        'ProductionOrderNo': '',
        'ProcessName': '',
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        planList.value = [
          for (var json in response.data) WorkshopPlanningInfo.fromJson(json)
        ];
        success.call();
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  getDepartmentWorkerInfo({
    required String processFlowID,
    required String departmentID,
    required String date,
    required Function(String) error,
  }) {
    httpGet(
      loading: '正在获取部门信息...',
      method: webApiGetDepartmentWorkerInfo,
      params: {
        // 'OrganizeID': userInfo?.organizeID,
        // 'ProcessFlowID': processFlowID,
        // 'DepartmentID': departmentID,
        // 'Date': date,
        'OrganizeID': 40,
        'ProcessFlowID': 35,
        'DepartmentID': 585370,
        'Date': '2025-07-07',
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        reportDate.value = date;
        workerList.value = [
          for (var json in response.data)
            WorkshopPlanningWorkerInfo.fromJson(json)
        ];
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  getWorkTypeListByProcess({
    required String processFlowID,
    required Function() success,
    required Function(String) error,
  }) {
    httpGet(
      loading: '正在获取工种列表...',
      method: webApiGetTypeOfWorkListByProcess,
      params: {
        'OrganizeID': userInfo?.organizeID,
        'ProcessFlowID': processFlowID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        workTypeList.value = [
          for (var json in response.data)
            WorkshopPlanningWorkTypeInfo.fromJson(json)
        ];
        success.call();
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  getEmpBaseByNumber({
    required String processFlowID,
    required String number,
    required Function(WorkshopPlanningWorkerInfo) success,
    required Function(String) error,
  }) {
    httpGet(
      loading: '正在获取工种列表...',
      method: webApiGetEmpBaseByNumber,
      params: {
        'FlowProcessID': processFlowID,
        'Number': number,
        'Date': reportDate.value,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var worker = WorkshopPlanningWorkerInfo.fromJson(response.data[0]);
        var index = workerList.indexWhere((v) => v.number == worker.number);
        if (index == -1) {
          workerList.add(worker);
          success.call(workerList.last);
        }else{
          success.call(workerList[index]);
        }
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
