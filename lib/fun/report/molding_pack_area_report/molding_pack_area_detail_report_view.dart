import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils.dart';

import '../../../bean/http/response/molding_pack_area_report_info.dart';
import '../../../widget/custom_widget.dart';
import 'molding_pack_area_report_logic.dart';

class MoldingPackAreaDetailReportPage extends StatefulWidget {
  const MoldingPackAreaDetailReportPage({super.key});

  @override
  State<MoldingPackAreaDetailReportPage> createState() =>
      _MoldingPackAreaDetailReportPageState();
}

class _MoldingPackAreaDetailReportPageState
    extends State<MoldingPackAreaDetailReportPage> {
  final logic = Get.find<MoldingPackAreaReportPageLogic>();
  final state = Get.find<MoldingPackAreaReportPageLogic>().state;
  var detailTableDataColumn = <DataColumn>[
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

  detailTableDataRow(
    MoldingPackAreaReportDetailInfo data,
    Color color,
  ) {
    return DataRow(
      color: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          return color;
        },
      ),
      cells: [
        DataCell(Text(data.clientOrderNumber ?? '')),
        DataCell(Text(data.clientOrderIndex ?? '')),
        DataCell(Text(data.size ?? '')),
        DataCell(Text(data.orderQty.toShowString())),
        DataCell(Text(data.orderPiece.toShowString())),
        DataCell(Text(data.distributedQty.toShowString())),
        DataCell(Text(data.distributedPiece.toShowString())),
        DataCell(Text(data.remainQty.toShowString())),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: backgroundColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        body: ListView(
          padding: const EdgeInsets.only(left: 10, right: 10),
          children: [
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Obx(
                  () => DataTable(
                    border: TableBorder.all(color: Colors.black, width: 1),
                    showCheckboxColumn: false,
                    headingRowColor: WidgetStateProperty.resolveWith<Color?>(
                      (states) => Colors.blueAccent.shade100,
                    ),
                    columns: detailTableDataColumn,
                    rows: [
                      for (var i = 0; i < state.detailTableData.length; ++i)
                        detailTableDataRow(
                          state.detailTableData[i],
                          i.isEven ? Colors.transparent : Colors.grey.shade100,
                        )
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
