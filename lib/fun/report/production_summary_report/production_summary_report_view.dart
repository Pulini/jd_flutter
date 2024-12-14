import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/spinner_widget.dart';

import 'production_summary_report_logic.dart';


class ProductionSummaryReportPage extends StatefulWidget {
  const ProductionSummaryReportPage({super.key});

  @override
  State<ProductionSummaryReportPage> createState() =>
      _ProductionSummaryReportPageState();
}

class _ProductionSummaryReportPageState
    extends State<ProductionSummaryReportPage> {
  final logic = Get.put(ProductionSummaryReportLogic());
  final state = Get.find<ProductionSummaryReportLogic>().state;
  List<DataColumn> tableDataColumn = <DataColumn>[
    DataColumn(
        label: Text('page_production_summary_report_table_title_hint1'.tr)),
    DataColumn(
        label: Text('page_production_summary_report_table_title_hint2'.tr)),
    DataColumn(
        label: Text('page_production_summary_report_table_title_hint3'.tr)),
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

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      queryWidgets: [
        Spinner(controller: logic.spinnerControllerWorkShop),
        DatePicker(pickerController: logic.pickerControllerDate),
      ],
      query: () => logic.query(),
      body: Obx(() => ListView(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.resolveWith<Color?>(
                    (states) => Colors.blueAccent.shade100,
                  ),
                  columns: tableDataColumn,
                  rows: [
                    for (var i = 0; i < state.tableData.length; ++i)
                      DataRow(
                        color: WidgetStateProperty.resolveWith<Color?>(
                          (states) => i.isEven
                              ? Colors.transparent
                              : Colors.grey.shade100,
                        ),
                        cells: [
                          DataCell(
                            Text(state.tableData[i].workshopLocation ?? ''),
                          ),
                          DataCell(
                            Text(state.tableData[i].group ?? ''),
                          ),
                          DataCell(
                            Text(state.tableData[i].lineLeader ?? ''),
                          ),
                          DataCell(
                            Text(state.tableData[i].todayTargetProduction
                                .toShowString()),
                          ),
                          DataCell(
                            Text(state.tableData[i].todayProduction
                                .toShowString()),
                          ),
                          DataCell(
                            Text(state.tableData[i].completionRate ?? ''),
                          ),
                          DataCell(
                            Text(state.tableData[i].monthlyTargetProduction
                                .toShowString()),
                          ),
                          DataCell(
                            Text(state.tableData[i].monthlyProduction
                                .toShowString()),
                          ),
                          DataCell(
                            Text(
                                state.tableData[i].monthlyCompletionRate ?? ''),
                          ),
                          DataCell(
                            Text((state.tableData[i].actualPeopleNumber ?? 0)
                                .toString()),
                          ),
                        ],
                      )
                  ],
                ),
              )
            ],
          )),
    );
  }

  @override
  void dispose() {
    Get.delete<ProductionSummaryReportLogic>();
    super.dispose();
  }
}
