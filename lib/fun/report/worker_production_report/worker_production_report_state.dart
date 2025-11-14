import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/worker_production_info.dart';
import 'package:jd_flutter/utils/web_api.dart';



class WorkerProductionReportState {
  RxList<WorkerProductionInfo> dataList = <WorkerProductionInfo>[].obs;

  void getWorkerProductionReport(
  {
    required String departmentID,
    required String date,
    required Function(String msg) error,
}
      ) {
    httpGet(
      loading: 'worker_production_report_querying'.tr,
      method: webApiGetWorkerProductionReport,
      params: {
        'DepartmentID':departmentID,
        'Date': date,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        dataList.value=[ for (var item in response.data) WorkerProductionInfo.fromJson(item)];
      } else {
        error.call( response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
