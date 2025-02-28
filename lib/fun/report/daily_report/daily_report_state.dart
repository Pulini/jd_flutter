import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/daily_report_info.dart';
import 'package:jd_flutter/utils/web_api.dart';


class DailyReportState {
  //报表数据
  RxList<DailyReport> dataList = <DailyReport>[].obs;

  getDayOutput({
    required String departmentID,
    required String date,
    required Function(String msg) error,
  }) {
    httpGet(
      loading: 'page_daily_report_querying'.tr,
      method: webApiGetDayOutput,
      params: {
        'DepartmentID': departmentID,
        'Date': date,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        dataList.value = [
          for (var item in response.data) DailyReport.fromJson(item)
        ];
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
