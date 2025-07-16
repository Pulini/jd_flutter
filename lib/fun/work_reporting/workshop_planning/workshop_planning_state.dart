import 'dart:convert';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/workshop_planning_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class WorkshopPlanningState {
  var submitButtonName = ''.obs;
  var planList = <WorkshopPlanningInfo>[].obs;
  var workTypeList = <WorkshopPlanningWorkTypeInfo>[].obs;
  WorkshopPlanningInfo? planInfo;
  var reportWorkerList = <WorkshopPlanningWorkerInfo>[].obs;
  var workerList = <WorkshopPlanningWorkerInfo>[].obs;
  var workerListSelectedIndex = (-1).obs;
  WorkshopPlanningWorkerInfo? worker;
  var reportQuantity = (0.0).obs;
  var reportDate = '';
  var price = 0.0;
  var departmentID = '';
  var groupName = '';
  var groupPayInterID = -1;
  var isDayShift = true.obs;
  var minCoefficient = (0.0).obs;
  var maxCoefficient = (0.0).obs;
  var reportList = <WorkshopPlanningReportInfo>[].obs;
  var hasDelete = false;
  WorkshopPlanningReportDetailInfo? reportDetailInfo;

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
    required String date,
    required Function() refresh,
    required Function(String) error,
  }) {
    httpGet(
      loading: '正在获取部门信息...',
      method: webApiGetDepartmentWorkerInfo,
      params: {
        // 'OrganizeID': userInfo?.organizeID,
        // 'ProcessFlowID': processFlowID,
        // 'DepartmentID':  departmentID,
        // 'Date': date,
        'OrganizeID': 40,
        'ProcessFlowID': 35,
        'DepartmentID': 585370,
        'Date': '2025-07-07',
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        reportDate = date;
        workerList.value = [
          for (var json in response.data)
            WorkshopPlanningWorkerInfo.fromJson(json)
        ];
      } else {
        workerList.value = [];
        error.call(response.message ?? 'query_default_error'.tr);
      }
      reportWorkerList.value = workerList;
      refresh.call();
    });
  }

  getWorkTypeListByProcess({
    required Function() success,
    required Function(String) error,
  }) {
    httpGet(
      loading: '正在获取工种列表...',
      method: webApiGetTypeOfWorkListByProcess,
      params: {
        'OrganizeID': userInfo?.organizeID,
        'ProcessFlowID': planInfo!.flowProcessID ?? '',
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
    required String number,
    required Function(WorkshopPlanningWorkerInfo) success,
    required Function(String) error,
  }) {
    httpGet(
      loading: '正在获取工种列表...',
      method: webApiGetEmpBaseByNumber,
      params: {
        'FlowProcessID': planInfo!.flowProcessID ?? '',
        'Number': number,
        'Date': reportDate,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var worker = WorkshopPlanningWorkerInfo.fromJson(response.data[0]);
        var index = workerList.indexWhere((v) => v.number == worker.number);
        if (index == -1) {
          workerList.add(worker);
          success.call(workerList.last);
        } else {
          success.call(workerList[index]);
        }
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  getGroupPayList({
    Function()? success,
    required Function(String) error,
  }) {
    httpGet(
      loading: '正在获取报工列表...',
      method: webApiGetGroupPayList,
      params: {
        'ID': planInfo!.id ?? '',
        'DepartmentID': departmentID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        reportList.value = [
          for (var item in response.data)
            WorkshopPlanningReportInfo.fromJson(item)
        ];
        success?.call();
      } else {
        reportList.value = [];
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  getGroupPayDetail({
    required int groupPayInterID,
    required Function() success,
    required Function(String) error,
  }) {
    httpGet(
      loading: '正在获取报工明细...',
      method: webApiGetGroupPayDetail,
      params: {
        'GroupPayInterID': groupPayInterID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        reportDetailInfo =
            WorkshopPlanningReportDetailInfo.fromJson(response.data);
        this.groupPayInterID = groupPayInterID;
        success.call();
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  deleteGroupPay({
    required int groupPayInterID,
    required Function(String) success,
    required Function(String) error,
  }) {
    httpPost(
      loading: '正在删除报工...',
      method: webApiDeleteGroupPay,
      params: {
        'GroupPayInterID': groupPayInterID,
        'UserID': userInfo?.empID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        hasDelete = true;
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  submitGroupPay({
    required Function(String ) success,
    required Function(String ) error,
  }) {
    httpPost(
      loading: '正在提交报工...',
      method: webApiSubmitGroupPay,
      body: {
        'ID': planInfo!.id,
        'IsGroupWork': planInfo!.isGroupWork,
        'AllowEdit': planInfo!.allowEdit,
        'DepartmentID': departmentID,
        'WorkShift': isDayShift.value ? 0 : 1,
        'CreatorID': userInfo?.userID,
        'Date': reportDate,
        'GroupPayInterID': groupPayInterID,
        'SizeLists': [
          for (var item in planInfo!.sizeLists!)
            {
              'ID': '',
              'Size': item.size,
              'Qty': item.qty,
            }
        ],
        'EmpInfoReqList': [
          for (var item in reportWorkerList)
            {
              'Base': item.base,
              'DayWorkTime': item.dayWorkTime,
              'EmpID': item.empID,
              'Money': item.money.value,
              'Price': price,
              'TypeOfWork': item.typeOfWork,
            }
        ],
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        WorkshopPlanningWorkersCache(
            group:departmentID,
            day:getDateYMD(),
            data:jsonEncode(reportWorkerList.map((v) => v.toJson()).toList()),
        ).save();
        success.call(response.message??'');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
