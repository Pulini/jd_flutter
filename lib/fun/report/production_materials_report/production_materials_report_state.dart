import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../http/response/molding_pack_area_report_info.dart';

class ProductionMaterialsReportState {
  var tableData = <MoldingPackAreaReportInfo>[].obs;
  var isPickingMaterialCompleted =false.obs;

  var tableDataColumn = <DataColumn>[
    DataColumn(label: Text('销售订单号')),
    DataColumn(label: Text('生产订单编号')),
    DataColumn(label: Text('订单类型')),
    DataColumn(label: Text('产品编码')),
    DataColumn(label: Text('产品名称')),
    DataColumn(label: Text('订单交期')),
    DataColumn(label: Text('计划开工日期')),
    DataColumn(label: Text('计划完工日期')),
    DataColumn(label: Text('尺码')),
    DataColumn(label: Text('BOM号')),
    DataColumn(label: Text('BOM版本')),
    DataColumn(label: Text('单位')),
    DataColumn(
      label: Text('生产数量'),
      numeric: true,
    ),
    DataColumn(
      label: Text('已派工数量'),
      numeric: true,
    ),
    DataColumn(label: Text('部位')),
    DataColumn(label: Text('外发工序')),
    DataColumn(label: Text('子项物料编码')),
    DataColumn(label: Text('子项物料名称')),
    DataColumn(label: Text('规格型号')),
    DataColumn(label: Text('子项单位')),
    DataColumn(label: Text('子项尺码')),
    DataColumn(label: Text('物料需求日期')),
    DataColumn(
      label: Text('最新BOM需求数量'),
      numeric: true,
    ),
    DataColumn(label: Text('批次')),
    DataColumn(
      label: Text('需求数量'),
      numeric: true,
    ),
    DataColumn(
      label: Text('已领数量'),
      numeric: true,
    ),
    DataColumn(
      label: Text('未领数量'),
      numeric: true,
    ),
    DataColumn(
      label: Text('补单数量'),
      numeric: true,
    ),
  ];

  ProductionMaterialsReportState() {
    ///Initialize variables
  }

  createTableDataRow(
    MoldingPackAreaReportInfo data,
    Color color,
    Function(int, String) goDetail,
  ) {
    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          return color;
        },
      ),
      onSelectChanged: (selected) {
        goDetail.call(data.interID!, data.clientOrderNumber!);
      },
      cells: [
        DataCell(Text(data.departmentName.toString())),
        DataCell(Text(data.orderNo ?? '')),
      ],
    );
  }
}
