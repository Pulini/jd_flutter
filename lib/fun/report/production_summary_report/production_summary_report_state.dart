import 'package:get/get.dart';

import '../../../bean/http/response/production_summary_info.dart';
import '../../../web_api.dart';

class ProductionSummaryReportState {
  var tableData = <ProductionSummaryInfo>[];

  getPrdShopDayReport({
    required String date,
    required int workShopID,
    required Function() success,
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
        tableData = [
          for (var item in response.data) ProductionSummaryInfo.fromJson(item)
        ];
        success.call();
        Get.back();
      } else {
        error.call( response.message ?? 'query_default_error'.tr);
      }
    });
  }


}
