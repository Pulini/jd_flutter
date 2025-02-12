import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/molding_pack_area_report_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'molding_pack_area_report_logic.dart';

class MoldingPackAreaReportPage extends StatefulWidget {
  const MoldingPackAreaReportPage({super.key});

  @override
  State<MoldingPackAreaReportPage> createState() =>
      _MoldingPackAreaReportPageState();
}

class _MoldingPackAreaReportPageState extends State<MoldingPackAreaReportPage> {
  final logic = Get.put(MoldingPackAreaReportPageLogic());
  final state = Get.find<MoldingPackAreaReportPageLogic>().state;

  var textColor = const TextStyle(color: Colors.blueAccent);
  var tableDataColumn = <DataColumn>[
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

  tableDataRow(
    MoldingPackAreaReportInfo data,
    Color color,
  ) {
    return DataRow(
      color: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          return color;
        },
      ),
      onSelectChanged: (selected) => logic.getDetails(
        data.interID ?? 0,
        data.clientOrderNumber ?? '',
      ),
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
        DataCell(Text(data.notInPackAreaQty.toShowString())),
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



  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      queryWidgets: [
        EditText(
          hint: 'page_molding_pack_area_report_query_instruction'.tr,
          onChanged: (v) => state.etInstruction = v,
        ),
        const SizedBox(height: 10),
        EditText(
          hint: 'page_molding_pack_area_report_query_order_number'.tr,
          onChanged: (v) => state.etOrderNumber = v,
        ),
        const SizedBox(height: 10),
        EditText(
          hint: 'page_molding_pack_area_report_query_type_body'.tr,
          onChanged: (v) => state.etTypeBody = v,
        ),
        DatePicker(pickerController: logic.dateControllerStart),
        DatePicker(pickerController: logic.dateControllerEnd),
        CheckBoxPicker(checkBoxController: logic.checkBoxController)
      ],
      query: () => logic.query(),
      body: ListView(
        padding: const EdgeInsets.only(left: 10, right: 10),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(() => DataTable(
                  border: TableBorder.all(color: Colors.black, width: 1),
                  showCheckboxColumn: false,
                  headingRowColor: WidgetStateProperty.resolveWith<Color?>(
                    (states) => Colors.blueAccent.shade100,
                  ),
                  columns: tableDataColumn,
                  rows: [
                    for (var i = 0; i < state.tableData.length; ++i)
                      tableDataRow(
                        state.tableData[i],
                        i.isEven ? Colors.transparent : Colors.grey.shade100,
                      )
                  ],
                )),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<MoldingPackAreaReportPageLogic>();
    super.dispose();
  }
}
