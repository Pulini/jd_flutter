import 'dart:async';
import 'package:get/get.dart';
import 'package:jd_flutter/utils.dart';

import '../../../bean/http/request/molding_scan_bulletin_sort.dart';
import '../../../bean/http/response/molding_scan_bulletin_report_info.dart';
import '../../../constant.dart';
import '../../../web_api.dart';
import '../../../route.dart';
import '../../../widget/custom_widget.dart';
import '../../../widget/dialogs.dart';
import 'molding_scan_bulletin_report_state.dart';

class MoldingScanBulletinReportLogic extends GetxController {
  final MoldingScanBulletinReportState state = MoldingScanBulletinReportState();

  Timer? timer;
  var refreshDuration = 10.obs;

  query() {
    timer?.cancel();
    timer = null;
    httpGet(
      method: webApiGetMoldingScanBulletinReport,
      loading: 'molding_scan_bulletin_report_querying'.tr,
      params: {'departmentID': userInfo?.departmentID, 'IsGetAllList': true},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        state.reportInfo.value = [
          for (var i = 0; i < response.data.length; ++i)
            MoldingScanBulletinReportInfo.fromJson(response.data[i])
        ];
      } else {
        errorDialog(content: response.message);
      }
      timer = Timer(
        Duration(seconds: refreshDuration.value),
        () => refreshTable(),
      );
    });
  }

  setRefresh(int duration) {
    refreshDuration.value = duration;
    spSave(spSaveMoldingScanBulletinReportTimeDuration, duration);
  }

  refreshTable() {
    timer?.cancel();
    timer = null;
    httpGet(
      method: webApiGetMoldingScanBulletinReport,
      params: {
        'departmentID': userInfo?.departmentID,
        'IsGetAllList':
            Get.currentRoute == RouteConfig.moldingScanBulletinReportPage.name
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        if (Get.currentRoute ==
            RouteConfig.moldingScanBulletinReportPage.name) {
          state.reportInfo.value = [
            for (var i = 0; i < response.data.length; ++i)
              MoldingScanBulletinReportInfo.fromJson(response.data[i])
          ];
        } else {
          var json = response.data[0];
          var data = MoldingScanBulletinReportInfo.fromJson(json);
          state.reportInfo[0] = data;
        }
      } else {
        showSnackBar(title: "", message: response.message!);
      }
      timer = Timer(
        Duration(seconds: refreshDuration.value),
        () => refreshTable(),
      );
    });
  }

  changeSort() {
    timer?.cancel();
    timer = null;
    var body = <MoldingScanBulletinSort>[];
    for (var i = 0; i < state.reportInfo.length; ++i) {
      body.add(MoldingScanBulletinSort(
        workCardInterID: int.parse(state.reportInfo[i].workCardInterID ?? ''),
        clientOrderNumber: state.reportInfo[i].clientOrderNumber,
        priority: i + 1,
      ));
    }

    httpPost(
      method: webApiSubmitNewSort,
      loading: 'molding_scan_bulletin_report_submitting'.tr,
      body: body,
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        showSnackBar(
            title: 'molding_scan_bulletin_report_sort'.tr,
            message: response.message ?? '');
      } else {
        errorDialog(content: response.message);
      }
      timer = Timer(
        Duration(seconds: refreshDuration.value),
        () => refreshTable(),
      );
    });
  }

  @override
  void onReady() {
    super.onReady();
    query();
    refreshDuration.value =
        spGet(spSaveMoldingScanBulletinReportTimeDuration) ?? 10;
  }

  @override
  void onClose() {
    timer?.cancel();
    timer = null;
    super.onClose();
  }
}
