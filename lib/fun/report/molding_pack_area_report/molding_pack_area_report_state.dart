import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils.dart';

import '../../../http/response/molding_pack_area_report_info.dart';

class MoldingPackAreaReportPageState {
  RxList<DataRow> tableDataRows = <DataRow>[].obs;
  List<DataColumn> tableDataColumn = <DataColumn>[
    DataColumn(label: Text('page_molding_pack_area_report_table_hint1'.tr)),
    DataColumn(label: Text('page_molding_pack_area_report_table_hint2'.tr)),
    DataColumn(label: Text('page_molding_pack_area_report_table_hint3'.tr)),
    DataColumn(label: Text('page_molding_pack_area_report_table_hint4'.tr)),
    DataColumn(label: Text('page_molding_pack_area_report_table_hint5'.tr)),
    DataColumn(label: Text('page_molding_pack_area_report_table_hint6'.tr)),
    DataColumn(
      label: Text('page_molding_pack_area_report_table_hint7'.tr),
      numeric: true,
    ),
    DataColumn(
      label: Text('page_molding_pack_area_report_table_hint8'.tr),
      numeric: true,
    ),
    DataColumn(
      label: Text('page_molding_pack_area_report_table_hint9'.tr),
      numeric: true,
    ),
    DataColumn(
      label: Text('page_molding_pack_area_report_table_hint10'.tr),
      numeric: true,
    ),
    DataColumn(
      label: Text('page_molding_pack_area_report_table_hint11'.tr),
      numeric: true,
    ),
    DataColumn(
      label: Text('page_molding_pack_area_report_table_hint12'.tr),
      numeric: true,
    ),
    DataColumn(
      label: Text('page_molding_pack_area_report_table_hint13'.tr),
      numeric: true,
    ),
    DataColumn(
      label: Text('page_molding_pack_area_report_table_hint14'.tr),
      numeric: true,
    ),
    DataColumn(
      label: Text('page_molding_pack_area_report_table_hint15'.tr),
      numeric: true,
    ),
    DataColumn(
      label: Text('page_molding_pack_area_report_table_hint16'.tr),
      numeric: true,
    ),
    DataColumn(
      label: Text('page_molding_pack_area_report_table_hint17'.tr),
      numeric: true,
    ),
  ];

  var line=''.obs;
  var typeBody=''.obs;
  var color=''.obs;

  RxList<DataRow> detailTableDataRows = <DataRow>[].obs;
  List<DataColumn> detailTableDataColumn = <DataColumn>[
    DataColumn(
        label: Text('page_molding_pack_area_report_detail_table_hint1'.tr)),
    DataColumn(
        label: Text('page_molding_pack_area_report_detail_table_hint2'.tr),
        numeric: true),
    DataColumn(
        label: Text('page_molding_pack_area_report_detail_table_hint3'.tr),
        numeric: true),
    DataColumn(
        label: Text('page_molding_pack_area_report_detail_table_hint4'.tr),
        numeric: true),
    DataColumn(
        label: Text('page_molding_pack_area_report_detail_table_hint5'.tr),
        numeric: true),
    DataColumn(
        label: Text('page_molding_pack_area_report_detail_table_hint6'.tr),
        numeric: true),
    DataColumn(
        label: Text('page_molding_pack_area_report_detail_table_hint7'.tr),
        numeric: true),
    DataColumn(
        label: Text('page_molding_pack_area_report_detail_table_hint8'.tr),
        numeric: true),
  ];

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
        DataCell(Text(data.clientOrderNumber ?? '')),
        DataCell(Text(data.fetchDate ?? '')),
        DataCell(Text(data.factoryType ?? '')),
        DataCell(Text(data.color ?? '')),
        DataCell(Text(data.orderQty.toShowString())),
        DataCell(Text(data.orderPiece.toShowString())),
        DataCell(Text(data.inPackAreaQty.toShowString())),
        DataCell(Text(data.inPackAreaPiece.toShowString())),
        DataCell(Text(data.distributedQty.toShowString())),
        DataCell(Text(data.distributedPiece.toShowString())),
        DataCell(Text(data.remainQty.toShowString())),
        DataCell(Text(data.sapFinishQty.toShowString())),
        DataCell(Text(data.sapFinishPiece.toShowString())),
        DataCell(Text(data.sapUnFinishQty.toShowString())),
        DataCell(Text(data.sapUnFinishPiece.toShowString())),
      ],
    );
  }
}
