import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

import '../../../http/response/production_day_report_info.dart';
import '../../../http/web_api.dart';

class ProductionDayReportState {
  List<ProductionDayReportInfo> tableData = <ProductionDayReportInfo>[];
  RxList<DataRow> tableDataRows = <DataRow>[].obs;
  List<DataColumn> tableDataColumn =  <DataColumn>[
    DataColumn(label: Text('page_production_day_report_table_title_hint1'.tr)),
    DataColumn(label: Text('page_production_day_report_table_title_hint2'.tr)),
    DataColumn(
      label: Text('page_production_day_report_table_title_hint3'.tr),
      numeric: true,
    ),
    DataColumn(
      label: Text('page_production_day_report_table_title_hint4'.tr),
      numeric: true,
    ),
    DataColumn(
      label: Text('page_production_day_report_table_title_hint5'.tr),
      numeric: true,
    ),
    DataColumn(
      label: Text('page_production_day_report_table_title_hint6'.tr),
      numeric: true,
    ),
    DataColumn(
      label: Text('page_production_day_report_table_title_hint7'.tr),
      numeric: true,
    ),
    DataColumn(
      label: Text('page_production_day_report_table_title_hint8'.tr),
      numeric: true,
    ),
    DataColumn(
      label: Text('page_production_day_report_table_title_hint9'.tr),
      numeric: true,
    ),
    DataColumn(
      label: Text('page_production_day_report_table_title_hint10'.tr),
      numeric: true,
    ),
    DataColumn(
      label: Text('page_production_day_report_table_title_hint11'.tr),
      numeric: true,
    ),
    DataColumn(
      label: Text('page_production_day_report_table_title_hint12'.tr),
      numeric: true,
    ),
    DataColumn(label: Text('page_production_day_report_table_title_hint13'.tr)),
  ];

  createDataRow(
      ProductionDayReportInfo data, Color color, Function modifyReason) {
    bool isParty = data.number == userController.user.value?.number;
    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          return color;
        },
      ),
      onSelectChanged: (selected) {
        if (isParty) {
          modifyReason.call();
        }
      },
      cells: [
        DataCell(Text(data.depName ?? '')),
        DataCell(Text(data.manager ?? '')),
        DataCell(Text((data.toDayMustQty ?? 0).toString())),
        DataCell(Text((data.toDayQty ?? 0).toString())),
        DataCell(Text(data.toDayFinishRate ?? '')),
        DataCell(Text((data.noToDayQty ?? 0).toString())),
        DataCell(Text((data.monthMustQty ?? 0).toString())),
        DataCell(Text((data.monthQty ?? 0).toString())),
        DataCell(Text(data.monthFinishRate ?? '')),
        DataCell(Text((data.noMonthQty ?? 0).toString())),
        DataCell(Text((data.mustPeopleCount ?? 0).toString())),
        DataCell(Text((data.peopleCount ?? 0).toString())),
        DataCell(
          Text(data.noDoingReason ?? ''),
          showEditIcon: isParty,
        ),
      ],
    );
  }
}
