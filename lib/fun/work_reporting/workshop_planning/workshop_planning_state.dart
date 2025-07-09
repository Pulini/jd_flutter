import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/workshop_planning_info.dart';
import 'package:jd_flutter/utils/web_api.dart';

class WorkshopPlanningState {
  var planList = <WorkshopPlanningInfo>[].obs;

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
}
