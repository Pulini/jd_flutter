import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/production_day_report_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';


class ProductionDayReportState {
  var tableData = <ProductionDayReportInfo>[].obs;

  late DateTime today;
  late DateTime lastWeek;
  late DateTime yesterday;

  ProductionDayReportState(){
    today = DateTime.now();
    lastWeek = DateTime(today.year, today.month, today.day - 7);
    yesterday = DateTime(today.year, today.month, today.day - 1);
  }

  getPrdDayReport({
    required String date,
    required int workShopID,
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    httpGet(
      loading: 'page_production_day_report_querying'.tr,
      method: webApiGetPrdDayReport,
      params: {
        'Date': date,
        'WorkShopID': workShopID,
        'OrganizeID': userInfo!.organizeID ?? 0,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        tableData.value = [
          for (var item in response.data) ProductionDayReportInfo.fromJson(item)
        ];
        success.call(response.message??'');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  submitReason({
    required String date,
    required String reason,
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    httpPost(
      loading: 'page_production_day_report_reason_dialog_save'.tr,
      method: webApiSubmitDayReportReason,
      params: {
        'Date': date,
        'Value': reason,
        'DeptID': userInfo!.departmentID ?? 0,
        'Number': userInfo!.number ?? '',
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(
          response.message ??
              'page_production_day_report_reason_dialog_save_error'.tr,
        );
      }
    });
  }
}
