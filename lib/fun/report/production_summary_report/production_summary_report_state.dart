import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/production_summary_info.dart';
import 'package:jd_flutter/utils/web_api.dart';

class ProductionSummaryReportState {
  var tableData = <ProductionSummaryInfo>[].obs;

  void getPrdShopDayReport({
    required String date,
    required int workShopID,
    required Function(String msg) error,
  }) {
    httpGet(
      loading: 'page_production_summary_report_querying'.tr,
      method: webApiGetPrdShopDayReport,
      params: {
        'ExecTodayDateTime': date,
        'ExecWhere': 'where t.FWorkShopID = $workShopID',
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        tableData.value = [
          for (var item in response.data) ProductionSummaryInfo.fromJson(item)
        ];
      } else {
        error.call( response.message ?? 'query_default_error'.tr);
      }
    });
  }


}
