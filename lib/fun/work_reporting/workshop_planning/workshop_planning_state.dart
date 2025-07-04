import 'package:get/get.dart';
import 'package:jd_flutter/utils/web_api.dart';

class WorkshopPlanningState {
  WorkshopPlanningState() {
    ///Initialize variables
  }

  getProcessPlanInfo({
    String? workCardInterID,
    String? routeEntryID,
    String? productionOrderNo,
    String? processName,
    required Function(String) error,
  }) {
    httpPost(
      loading: '正在获取工序计划列表...',
      method: webApiProcessPlanningList,
      params: {
        'WorkCardInterID':workCardInterID,
        'RouteEntryID':routeEntryID,
        'ProductionOrderNo':productionOrderNo,
        'ProcessName':processName,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {

      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
