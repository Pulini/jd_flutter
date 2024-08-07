import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils.dart';

import '../../../bean/http/response/production_summary_info.dart';


class ProductionSummaryReportState {
  List<ProductionSummaryInfo> tableData = <ProductionSummaryInfo>[];
  RxList<DataRow> tableDataRows = <DataRow>[].obs;
  List<DataColumn> tableDataColumn = <DataColumn>[
    DataColumn(label: Text('page_production_summary_report_table_title_hint1'.tr)),
    DataColumn(label: Text('page_production_summary_report_table_title_hint2'.tr)),
    DataColumn(label: Text('page_production_summary_report_table_title_hint3'.tr)),
    DataColumn(
      label: Text('page_production_summary_report_table_title_hint4'.tr),
      numeric: true,
    ),
    DataColumn(
      label: Text('page_production_summary_report_table_title_hint5'.tr),
      numeric: true,
    ),
    DataColumn(
      label: Text('page_production_summary_report_table_title_hint6'.tr),
      numeric: true,
    ),
    DataColumn(
      label: Text('page_production_summary_report_table_title_hint7'.tr),
      numeric: true,
    ),
    DataColumn(
      label: Text('page_production_summary_report_table_title_hint8'.tr),
      numeric: true,
    ),
    DataColumn(
      label: Text('page_production_summary_report_table_title_hint9'.tr),
      numeric: true,
    ),
    DataColumn(
      label: Text('page_production_summary_report_table_title_hint10'.tr),
      numeric: true,
    ),
  ];

  createDataRow(ProductionSummaryInfo data, Color color) {
    return DataRow(
      color: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          return color;
        },
      ),
      cells: [
        DataCell(Text(data.workshopLocation ?? '')),
        DataCell(Text(data.group ?? '')),
        DataCell(Text(data.lineLeader ?? '')),
        DataCell(Text(data.todayTargetProduction.toShowString())),
        DataCell(Text(data.todayProduction.toShowString())),
        DataCell(Text(data.completionRate ?? '')),
        DataCell(Text(data.monthlyTargetProduction.toShowString())),
        DataCell(Text(data.monthlyProduction.toShowString())),
        DataCell(Text(data.monthlyCompletionRate ?? '')),
        DataCell(Text((data.actualPeopleNumber ?? 0).toString())),
      ],
    );
  }
}
