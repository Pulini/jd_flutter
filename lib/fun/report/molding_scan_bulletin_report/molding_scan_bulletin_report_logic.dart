import 'dart:async';

import 'package:get/get.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'molding_scan_bulletin_report_state.dart';

class MoldingScanBulletinReportLogic extends GetxController {
  final MoldingScanBulletinReportState state = MoldingScanBulletinReportState();

  Timer? timer;

  setRefresh(int duration) {
    state.refreshDuration.value = duration;
    spSave(spSaveMoldingScanBulletinReportTimeDuration, duration);
    refreshTable(true);
  }

  refreshTable(bool isRefresh) {
    timer?.cancel();
    timer = null;
    state.getMoldingScanBulletinReport(
      departmentID: userInfo?.departmentID ?? 0,
      isRefresh: isRefresh,
      isGetAllList: isRefresh
          ? Get.currentRoute == RouteConfig.moldingScanBulletinReport.name
          : true,
      error: (msg) => showSnackBar( message: msg, isWarning: true,),
      refreshTimer: () {
        if (state.refreshDuration.value > 0) {
          timer = Timer(
            Duration(seconds: state.refreshDuration.value),
            () => refreshTable(true),
          );
        }
      },
    );
  }

  changeSort({required int oldIndex, required int newIndex}) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    state.reportInfo.insert(newIndex, state.reportInfo.removeAt(oldIndex));
    timer?.cancel();
    timer = null;
    state.changeSort(
      success: (msg) => showSnackBar(
        title: 'molding_scan_bulletin_report_sort'.tr,
        message: msg,
      ),
      error: (msg) => errorDialog(content: msg),
      refreshTimer: () {
        timer = Timer(
          Duration(seconds: state.refreshDuration.value),
          () => refreshTable(true),
        );
      },
    );
  }

  @override
  void onReady() {
    super.onReady();
    refreshTable(false);
    state.refreshDuration.value =
        spGet(spSaveMoldingScanBulletinReportTimeDuration) ?? 10;
  }

  @override
  void onClose() {
    timer?.cancel();
    timer = null;
    super.onClose();
  }
}
