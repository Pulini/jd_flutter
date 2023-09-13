import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../http/response/production_summary_info.dart';

class ProductionSummaryTableState {

  List<ProductionSummaryInfo> tableData = <ProductionSummaryInfo>[];
  RxList<DataRow> tableDataRows = <DataRow>[].obs;
  List<DataColumn> tableDataColumn = const <DataColumn>[
    DataColumn(label: Text('车间地点')),
    DataColumn(label: Text('组别')),
    DataColumn(label: Text('带线干部')),
    DataColumn(label: Text('今日目标产量'), numeric: true),
    DataColumn(label: Text('今日产量'), numeric: true),
    DataColumn(label: Text('完成率'), numeric: true),
    DataColumn(label: Text('月累计目标产量'), numeric: true),
    DataColumn(label: Text('月累计产量'), numeric: true),
    DataColumn(label: Text('月完成率'), numeric: true),
    DataColumn(label: Text('实际人数'), numeric: true),
  ];

  createDataRow(ProductionSummaryInfo data, Color color) {
    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          return color;
        },
      ),
      cells: [
        DataCell(Text(data.workshopLocation ?? '')),
        DataCell(Text(data.group ?? '')),
        DataCell(Text(data.lineLeader ?? '')),
        DataCell(Text((data.todayTargetProduction ?? 0).toString())),
        DataCell(Text((data.todayProduction ?? 0).toString())),
        DataCell(Text(data.completionRate ?? '')),
        DataCell(Text((data.monthlyTargetProduction ?? 0).toString())),
        DataCell(Text((data.monthlyProduction ?? 0).toString())),
        DataCell(Text(data.monthlyCompletionRate ?? '')),
        DataCell(Text((data.actualPeopleNumber ?? 0).toString())),
      ],
    );
  }
}
