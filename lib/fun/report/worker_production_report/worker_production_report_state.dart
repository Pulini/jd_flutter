import 'package:get/get.dart';

import '../../../bean/http/response/worker_production_info.dart';
import '../../../web_api.dart';


class WorkerProductionReportState {
  RxList<WorkerProductionInfo> dataList = <WorkerProductionInfo>[].obs;

  getWorkerProductionReport(
  {
    required String departmentID,
    required String date,
    required Function() success,
    required Function(String msg) error,
}
      ) {
    httpGet(
      loading: '正在查询计件产量...',
      method: webApiGetWorkerProductionReport,
      params: {
        'DepartmentID':departmentID,
        'Date': date,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        dataList.value=[ for (var item in response.data) WorkerProductionInfo.fromJson(item)];
        success.call();
      } else {
        error.call( response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
