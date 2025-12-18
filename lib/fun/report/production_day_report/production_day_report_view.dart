import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/production_day_report_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/spinner_widget.dart';

import 'production_day_report_logic.dart';

class ProductionDayReportPage extends StatefulWidget {
  const ProductionDayReportPage({super.key});

  @override
  State<ProductionDayReportPage> createState() =>
      _ProductionDayReportPageState();
}

class _ProductionDayReportPageState extends State<ProductionDayReportPage> {
  final logic = Get.put(ProductionDayReportLogic());
  final state = Get.find<ProductionDayReportLogic>().state;

  List<DataColumn> tableDataColumn = <DataColumn>[
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

  Widget getText(String hint, String text) {
    var reasonTextStyle = const TextStyle(color: Colors.white);
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            hint,
            style: reasonTextStyle,
          ),
          Text(
            text,
            style: reasonTextStyle,
          )
        ],
      ),
    );
  }

  void reasonDialog() {
    logic.reasonDateController.pickDate.value = DateTime.now();
    reasonInputPopup(
      title: [
        getText(
          'page_production_day_report_reason_dialog_hint1'.tr,
          userInfo?.departmentName ?? '',
        ),
        getText(
          'page_production_day_report_reason_dialog_hint2'.tr,
          userInfo?.number ?? '',
        ),
        getText(
          'page_production_day_report_reason_dialog_hint3'.tr,
          userInfo?.name ?? '',
        ),
        getText(
          'page_production_day_report_reason_dialog_hint4'.tr,
          userInfo?.position ?? '',
        ),
        DatePicker(pickerController: logic.reasonDateController),
      ],
      hintText: 'dialog_reason_hint'.tr,
      confirmText: 'dialog_reason_submit'.tr,
      isCanCancel: true,
      confirm: (reason) {
        logic.submitReason(
          date: logic.reasonDateController.getDateFormatYMD(),
          reason: reason,
          refresh: () => logic.query(),
        );
      },
    );
  }

  DataRow createDataRow(ProductionDayReportInfo data, Color color) {
    bool isParty = data.number == userInfo?.number;
    return DataRow(
      color: WidgetStateProperty.resolveWith<Color?>((states) => color),
      onSelectChanged: (_) {
        if (isParty) {
          if (logic.checkDate()) {
            reasonDialog();
          } else {
            errorDialog(
              content: 'page_production_day_report_reason_dialog_error'.tr,
            );
          }
        }
      },
      cells: [
        DataCell(Text(data.depName ?? '')),
        DataCell(Text(data.manager ?? '')),
        DataCell(Text(data.toDayMustQty.toShowString())),
        DataCell(Text(data.toDayQty.toShowString())),
        DataCell(Text(data.toDayFinishRate ?? '')),
        DataCell(Text(data.noToDayQty.toShowString())),
        DataCell(Text(data.monthMustQty.toShowString())),
        DataCell(Text(data.monthQty.toShowString())),
        DataCell(Text(data.monthFinishRate ?? '')),
        DataCell(Text(data.noMonthQty.toShowString())),
        DataCell(Text(data.mustPeopleCount.toShowString())),
        DataCell(Text(data.peopleCount.toShowString())),
        DataCell(Text(data.noDoingReason ?? ''), showEditIcon: isParty),
      ],
    );
  }

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
                  showCheckboxColumn: false,
                  headingRowColor: WidgetStateProperty.resolveWith<Color?>(
                    (states) => Colors.blueAccent.shade100,
                  ),
                  columns: tableDataColumn,
                  rows: [
                    for (var i = 0; i < state.tableData.length; ++i)
                      createDataRow(
                        state.tableData[i],
                        i.isEven ? Colors.transparent : Colors.grey.shade100,
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
    Get.delete<ProductionDayReportLogic>();
    super.dispose();
  }
}
