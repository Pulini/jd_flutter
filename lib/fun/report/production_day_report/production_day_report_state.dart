import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

import '../../../http/response/production_day_report_info.dart';
import '../../../http/web_api.dart';

class ProductionDayReportState {
  List<ProductionDayReportInfo> tableData = <ProductionDayReportInfo>[];
  RxList<DataRow> tableDataRows = <DataRow>[].obs;
  List<DataColumn> tableDataColumn = const <DataColumn>[
    DataColumn(label: Text('page_production_day_report_table_title_hint1')),
    DataColumn(label: Text('page_production_day_report_table_title_hint2')),
    DataColumn(
      label: Text('page_production_day_report_table_title_hint3'),
      numeric: true,
    ),
    DataColumn(
      label: Text('page_production_day_report_table_title_hint4'),
      numeric: true,
    ),
    DataColumn(
      label: Text('page_production_day_report_table_title_hint5'),
      numeric: true,
    ),
    DataColumn(
      label: Text('page_production_day_report_table_title_hint6'),
      numeric: true,
    ),
    DataColumn(
      label: Text('page_production_day_report_table_title_hint7'),
      numeric: true,
    ),
    DataColumn(
      label: Text('page_production_day_report_table_title_hint8'),
      numeric: true,
    ),
    DataColumn(
      label: Text('page_production_day_report_table_title_hint9'),
      numeric: true,
    ),
    DataColumn(
      label: Text('page_production_day_report_table_title_hint10'),
      numeric: true,
    ),
    DataColumn(
      label: Text('page_production_day_report_table_title_hint11'),
      numeric: true,
    ),
    DataColumn(
      label: Text('page_production_day_report_table_title_hint12'),
      numeric: true,
    ),
    DataColumn(label: Text('page_production_day_report_table_title_hint13')),
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
