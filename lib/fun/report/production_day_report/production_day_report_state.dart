import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

import '../../../http/response/production_day_report_info.dart';
import '../../../http/web_api.dart';

class ProductionDayReportState {
  List<ProductionDayReportInfo> tableData = <ProductionDayReportInfo>[];
  RxList<DataRow> tableDataRows = <DataRow>[].obs;
  List<DataColumn> tableDataColumn = const <DataColumn>[
    DataColumn(label: Text('部门名称')),
    DataColumn(label: Text('负责人')),
    DataColumn(label: Text('今日目标产量'), numeric: true),
    DataColumn(label: Text('今日实际产量'), numeric: true),
    DataColumn(label: Text('今日完成率'), numeric: true),
    DataColumn(label: Text('今日未完成产量'), numeric: true),
    DataColumn(label: Text('月目标产量'), numeric: true),
    DataColumn(label: Text('月累计产量'), numeric: true),
    DataColumn(label: Text('月累计达成率'), numeric: true),
    DataColumn(label: Text('月累计未完成产量'), numeric: true),
    DataColumn(label: Text('应到人数'), numeric: true),
    DataColumn(label: Text('实际人数'), numeric: true),
    DataColumn(label: Text('未达成原因分析')),
  ];

  createDataRow(ProductionDayReportInfo data, Color color,Function modifyReason) {
    bool isParty = data.number == userController.user.value?.number;
    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          return color;
        },
      ),
      onSelectChanged: (selected) {
        if(isParty){
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
