import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/workshop_planning_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class WorkshopPlanningState {
  var submitButtonName = ''.obs;
  var planList = <WorkshopPlanningInfo>[].obs; //团件计工工单列表
  WorkshopPlanningInfo? planInfo;

  var workTypeList = <WorkshopPlanningWorkTypeInfo>[].obs; //工单工种列表
  var workerList = <WorkshopPlanningWorkerInfo>[].obs; //组员数据
  var workerListSelectedIndex = (-1).obs; //选择组员列表的下标
  var minCoefficient = (0.0).obs; //组员修改系数下限
  var maxCoefficient = (0.0).obs; //组员修改系数上限
  WorkshopPlanningWorkerInfo? worker; //当前所选组员数据
  var reportWorkerList = <WorkshopPlanningWorkerInfo>[].obs; //报工组员数据
  var reportQuantity = (0.0).obs; //当前报工总数
  var price = (0.0).obs; //当前报工价格
  var reportDate = ''; //当前报工日期
  var departmentID = ''; //部门ID
  var groupName = ''; //部门名称
  var groupPayInterID = -1;
  var isDayShift = true.obs; //班次 0昼1夜
  var reportList = <WorkshopPlanningReportInfo>[].obs; //报工列表
  WorkshopPlanningReportDetailInfo? reportDetailInfo; //报工明细数据
  var hasDelete = false; //报工列表是否进行过删除操作
  var workersCache = <WorkshopPlanningWorkersCache>[].obs; //工单报工状态本地缓存

  var lastProcessMaterialsData = <WorkshopPlanningMaterialInfo>[]; //末道工序物料数据
  var lastProcessMaterialList = <WorkshopPlanningMaterialInfo>[].obs; //末道工序报工物料
  var lastProcessProductionList =
      <WorkshopPlanningLastProcessInfo>[].obs; //末道工序报工进度表
  var lastProcessDate = ''; //末道工序报工日期
  var lastProcessFlowID = ''; //末道工序报工制程ID
  var lastProcessFlowName = ''; //末道工序报工制程名称
  var lastProcessGroupPayList = <LastProcessGroupPayInfo>[].obs; //末道工序报工列表
  LastProcessReportInfo? lastProcessReportDetail;
  var modifyReportMaterialList = <LastProcessReportMaterialInfo>[].obs;
  var modifyReportProductionList = <WorkshopPlanningLastProcessInfo>[].obs;
  var modifyReportReportWorkerList = <WorkshopPlanningWorkerInfo>[].obs;
  var modifyReportReportQuantity = (0.0).obs;
  var modifyReportPrice = (0.0).obs;

  void getProcessPlanInfo({
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
        'WorkCardInterID': workCardInterID,
        'RouteEntryID': routeEntryID,
        'ProductionOrderNo': productionOrderNo,
        'ProcessName': processName,
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

  getGroupInfo({
    required String processFlowID,
    required String date,
    Function(List<WorkshopPlanningWorkerInfo>)? success,
    Function(String)? error,
    Function()? finish,
  }) {
    httpGet(
      loading: '正在获取部门信息...',
      method: webApiGetDepartmentWorkerInfo,
      params: {
        'OrganizeID': userInfo?.organizeID,
        'ProcessFlowID': processFlowID,
        'DepartmentID': departmentID,
        'Date': date,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success?.call([
          for (var json in response.data)
            WorkshopPlanningWorkerInfo.fromJson(json)
        ]);
      } else {
        error?.call(response.message ?? 'query_default_error'.tr);
      }
      finish?.call();
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
    required String flowProcessID,
    required String number,
    required String date,
    required Function(WorkshopPlanningWorkerInfo) success,
    required Function(String) error,
  }) {
    httpGet(
      loading: '正在获取工种列表...',
      method: webApiGetEmpBaseByNumber,
      params: {
        'FlowProcessID': flowProcessID,
        'Number': number,
        'Date': date,
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
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  submitGroupPay({
    required Map body,
    required Function(String) success,
    required Function(String) error,
  }) {
    httpPost(
      loading: '正在提交报工...',
      method: webApiSubmitGroupPay,
      body: body,
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  getToDayItemInfo({
    required String date,
    required Function() success,
    required Function(String) error,
  }) {
    httpGet(
      loading: '正在获取物料信息...',
      method: webApiGetToDayItemInfo,
      params: {
        'DepartmentID': departmentID,
        'Date': date,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        lastProcessMaterialsData = [
          for (var json in response.data)
            WorkshopPlanningMaterialInfo.fromJson(json)
        ];
        success.call();
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  getEndingProcessInfo({
    required String date,
    required String processFlowID,
    required Function(List<WorkshopPlanningLastProcessInfo>) success,
    required Function(String) error,
  }) {
    httpPost(
      loading: '正在获取产量...',
      method: webApiGetEndingProcessQty,
      body: {
        'GroupPayInterID': 0, //新增0 修改从报工列表获取
        'ProcessFlowID': processFlowID,
        'DepartmentID': departmentID,
        'Date': date,
        'MaterialIDList':
            lastProcessMaterialList.map((v) => v.itemID ?? -1).toList(),
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call([
          for (var json in response.data)
            WorkshopPlanningLastProcessInfo.fromJson(json)
        ]);
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  getGroupPayEndingProcessList({
    required String date,
    required String processFlowID,
    Function()? success,
    required Function(String) error,
  }) {
    httpGet(
      loading: '正在获取报工列表...',
      method: webApiGetGroupPayEndingProcessList,
      params: {
        'Date': date,
        'DepartmentID': departmentID,
        'ProcessFlowID': processFlowID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        lastProcessGroupPayList.value = [
          for (var json in response.data) LastProcessGroupPayInfo.fromJson(json)
        ];
        success?.call();
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  getGroupPayEndingDetail({
    required int groupPayInterID,
    required Function(LastProcessReportInfo) success,
    required Function(String) error,
  }) {
    httpGet(
      loading: '正在获取报工列表...',
      method: webApiGetGroupPayEndingDetail,
      params: {
        'GroupPayInterID': groupPayInterID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(LastProcessReportInfo.fromJson(response.data));
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
