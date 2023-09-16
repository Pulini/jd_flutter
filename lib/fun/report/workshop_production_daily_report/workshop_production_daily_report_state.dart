import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WorkshopProductionDailyReportState {
  var isDetail = false.obs;
  var buttonName = '明细'.obs;
  RxList<DataRow> tableDataRows = <DataRow>[].obs;
  RxList<DataColumn> tableDataColumn = <DataColumn>[].obs;

  changeTable() {
    if (isDetail.value) {
      isDetail.value = false;
      buttonName.value = '明细';
      tableDataColumn.value = [
        DataColumn(label: Text('车间')),
        DataColumn(label: Text('区域')),
        DataColumn(label: Text('今日目标'), numeric: true),
        DataColumn(label: Text('时段目标'), numeric: true),
        DataColumn(label: Text('时段累计'), numeric: true),
        DataColumn(label: Text('时段差异'), numeric: true),
        DataColumn(label: Text('时段达成'), numeric: true),
        DataColumn(label: Text('原因分析'))
      ];
    } else {
      isDetail.value = true;
      buttonName.value = '汇总';
      tableDataColumn.value = [
        DataColumn(label: Text('车间')),
        DataColumn(label: Text('区域')),
        DataColumn(label: Text('所属课')),
        DataColumn(label: Text('组别')),
        DataColumn(label: Text('今日目标'), numeric: true),
        DataColumn(label: Text('时段目标'), numeric: true),
        DataColumn(label: Text('时段累计'), numeric: true),
        DataColumn(label: Text('时段差异'), numeric: true),
        DataColumn(label: Text('时段达成'), numeric: true),
        DataColumn(label: Text('原因分析'))
      ];
    }
  }

  WorkshopProductionDailyReportState() {
    changeTable();
  }
}
