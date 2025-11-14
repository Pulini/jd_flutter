import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/molding_scan_bulletin_report_info.dart';
import 'package:jd_flutter/utils/web_api.dart';


class MoldingScanBulletinReportState {
  var reportInfo = <MoldingScanBulletinReportInfo>[].obs;

  var refreshDuration = 10.obs;

  void getMoldingScanBulletinReport({
    required int departmentID,
    required bool isRefresh,
    required bool isGetAllList,
    required Function(String msg) error,
    required Function() refreshTimer,
  }) {
    httpGet(
      method: webApiGetMoldingScanBulletinReport,
      loading: isRefresh?'':'molding_scan_bulletin_report_querying'.tr,
      params: {
        'departmentID': departmentID,
        'IsGetAllList': isGetAllList,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        if (isGetAllList) {
          reportInfo.value = [
            for (var json in response.data)
              MoldingScanBulletinReportInfo.fromJson(json)
          ];
        } else {
          reportInfo.value = [
            MoldingScanBulletinReportInfo.fromJson(response.data[0])
          ];
        }
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
      refreshTimer.call();
    });
  }

  void changeSort({
    required Function(String msg) success,
    required Function(String msg) error,
    required Function() refreshTimer,
  }) {
    httpPost(
      method: webApiSubmitNewSort,
      loading: 'molding_scan_bulletin_report_submitting'.tr,
      body: [
        for (var i = 0; i < reportInfo.length; ++i)
          {
            'workCardInterID': int.parse(reportInfo[i].workCardInterID ?? ''),
            'clientOrderNumber': reportInfo[i].clientOrderNumber,
            'priority': i + 1,
          }
      ],
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? '');
      }
      refreshTimer.call();
    });
  }

}
