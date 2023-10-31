import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils.dart';

import '../../../http/request/molding_scan_bulletin_sort.dart';
import '../../../http/response/molding_scan_bulletin_report_info.dart';
import '../../../http/web_api.dart';
import '../../../widget/dialogs.dart';
import 'molding_scan_bulletin_report_state.dart';

class MoldingScanBulletinReportLogic extends GetxController {
  final MoldingScanBulletinReportState state = MoldingScanBulletinReportState();

  query() {
    httpGet(
      method: webApiGetMoldingScanBulletinReport,
      loading: '正在查询报表...',
      query: {'departmentID': userInfo?.departmentID},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var jsonList = jsonDecode(response.data);
        var list = <MoldingScanBulletinReportInfo>[];
        for (var i = 0; i < jsonList.length; ++i) {
          list.add(
            MoldingScanBulletinReportInfo.fromJson(jsonList[i])
              ..itemColor =
                  i.isOdd ? Colors.lime.shade100 : Colors.deepPurple.shade100,
          );
        }
        state.reportInfo.value = list;
      } else {
        errorDialog(content: response.message);
      }
    });
  }

  changeSort() {
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
    });
  }

  @override
  void onReady() {
    super.onReady();
    query();
  }
}
