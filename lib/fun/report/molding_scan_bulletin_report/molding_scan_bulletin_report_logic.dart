import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils.dart';

import '../../../constant.dart';
import '../../../http/request/molding_scan_bulletin_sort.dart';
import '../../../http/response/molding_scan_bulletin_report_info.dart';
import '../../../http/web_api.dart';
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
      loading: '正在查询报表...',
      query: {'departmentID': userInfo?.departmentID},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var jsonList = jsonDecode(response.data);
        var list = <MoldingScanBulletinReportInfo>[];
        for (var i = 0; i < jsonList.length; ++i) {
          list.add(MoldingScanBulletinReportInfo.fromJson(jsonList[i])
                ..itemColor =
                    i == 0 ? Colors.greenAccent.shade400 : Colors.lime.shade100
              // i.isOdd ? Colors.lime.shade100 : Colors.deepPurple.shade100,
              );
        }
        state.reportInfo.value = list;
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
      query: {'departmentID': userInfo?.departmentID},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var jsonList = jsonDecode(response.data);
        var list = <MoldingScanBulletinReportInfo>[];
        for (var i = 0; i < jsonList.length; ++i) {
          list.add(MoldingScanBulletinReportInfo.fromJson(jsonList[i])
            ..itemColor = i == 0 ? Colors.greenAccent : Colors.lime.shade100);
        }
        state.reportInfo.value = list;
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
      loading: '正在提交排序...',
      body: json.encode(body),
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
