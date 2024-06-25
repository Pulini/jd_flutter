import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils.dart';

import '../../../bean/http/response/workshop_production_daily_report_info.dart';
import '../../../web_api.dart';
import '../../../widget/dialogs.dart';
import 'workshop_production_daily_report_state.dart';

class WorkshopProductionDailyReportLogic extends GetxController
    with GetSingleTickerProviderStateMixin {
  final WorkshopProductionDailyReportState state =
      WorkshopProductionDailyReportState();

  ///tab控制器
  late TabController tabController = TabController(length: 2, vsync: this);

  changeTable() {
    state.changeTable();
    refreshData();
  }

  refreshData() {
    if (state.isDetail.value) {
      getDetail();
    } else {
      getSummary();
    }
  }

  getSummary() {
    var now = DateTime.now();
    httpGet(
      loading: '正在获取车间生产日报表汇总数据...',
      method: webApiGetWorkshopProductionDailySummary,
      params: {'Date': '${now.year}-${now.month}-${now.day}'},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <DataRow>[];
        var index = 0;
        for (var item in jsonDecode(response.data)) {
          var data = WorkshopProductionDailyReportSummaryInfo.fromJson(item);
          list.add(DataRow(
            color: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                return index.isEven ? Colors.transparent : Colors.grey.shade100;
              },
            ),
            cells: [
              DataCell(Text(data.workShopName ?? '')),
              DataCell(Text(data.organizeName ?? '')),
              DataCell(Text(data.toDayMustQty.toShowString())),
              DataCell(Text(data.toDayQty.toShowString())),
              DataCell(Text(data.noToDayQty.toShowString())),
              DataCell(Text(data.toDayFinishRate ?? '')),
              DataCell(Text(data.lJQty.toShowString())),
              DataCell(Text(data.noDoingReason ?? '')),
            ],
          ));
        }
      } else {
        errorDialog(content: response.message ?? 'query_default_error'.tr);
      }
    });
  }

  getDetail() {
    var now = DateTime.now();
    httpGet(
      loading: '正在获取车间生产日报表明细数据...',
      method: webApiGetWorkshopProductionDailyDetail,
      params: {'Date': '${now.year}-${now.month}-${now.day}'},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        // var list = <DataRow>[];
        // for (var item in jsonDecode(response.data)) {
        //   var data = WorkshopProductionDailyReportDetailInfo.fromJson(item);
        // }
      } else {
        errorDialog(content: response.message ?? 'query_default_error'.tr);
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    refreshData();
  }

}
