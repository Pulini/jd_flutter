import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/worker_production_detail_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'worker_production_detail_logic.dart';

class WorkerProductionDetailPage extends StatefulWidget {
  const WorkerProductionDetailPage({super.key});

  @override
  State<WorkerProductionDetailPage> createState() =>
      _WorkerProductionDetailPageState();
}

class _WorkerProductionDetailPageState
    extends State<WorkerProductionDetailPage> {
  final logic = Get.put(WorkerProductionDetailLogic());
  final state = Get.find<WorkerProductionDetailLogic>().state;

  getTable(WorkerProductionDetailShow data) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.green.shade200,
            border: Border.all(color: Colors.grey, width: 1),
          ),
          margin: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(data.title),
              ),
              DataTable(
                showCheckboxColumn: false,
                headingRowColor: WidgetStateProperty.resolveWith<Color?>(
                  (states) => Colors.blueAccent.shade100,
                ),
                columns: getItemTableHead(data.head),
                rows: getItemTableBody(data.body),
              )
            ],
          ),
        ),
      );

  List<DataColumn> getItemTableHead(WorkerProductionDetail data) {
    if (data is WorkerProductionDetailType1) {
      return [
        DataColumn(
          label: Text('worker_production_report_item_title_order_no'.tr),
        ),
        DataColumn(
          label: Text('worker_production_report_item_title_date'.tr),
        ),
        DataColumn(
          label: Text(
              'worker_production_report_item_title_report_department_name'.tr),
        ),
        DataColumn(
          label: Text('worker_production_report_item_title_report_group'.tr),
        ),
        DataColumn(
          label: Text('worker_production_report_item_title_dispatch_no'.tr),
        ),
        DataColumn(
          label: Text('worker_production_report_item_title_process'.tr),
        ),
        DataColumn(
          label: Text('worker_production_report_item_title_goods_no'.tr),
        ),
        DataColumn(
          label: Text('worker_production_report_item_title_process_code'.tr),
        ),
        DataColumn(
          label: Text(
            'worker_production_report_item_title_process_name'.tr,
          ),
        ),
        DataColumn(
          label: Text('worker_production_report_item_title_qty'.tr),
          numeric: true,
        ),
        if (state.showPrice)
          DataColumn(
            label: Text('worker_production_report_item_title_price'.tr),
            numeric: true,
          ),
        if (state.showAmount)
          DataColumn(
            label: Text('worker_production_report_item_title_amount'.tr),
            numeric: true,
          ),
        DataColumn(
          label: Text(
              'worker_production_report_item_title_small_order_subsidy'.tr),
        ),
        if (state.showAmount && state.showPrice)
          DataColumn(
            label: Text('worker_production_report_item_title_amount_total'.tr),
            numeric: true,
          ),
        DataColumn(
          label: Text(
              'worker_production_report_item_title_small_order_subsidy_rate'
                  .tr),
        )
      ];
    }
    if (data is WorkerProductionDetailType2) {
      return [
        DataColumn(
          label: Text('worker_production_report_item_title_goods_no'.tr),
        ),
        DataColumn(
          label: Text('worker_production_report_item_title_process_code'.tr),
        ),
        DataColumn(
          label: Text('worker_production_report_item_title_process_name'.tr),
        ),
        DataColumn(
          label: Text('worker_production_report_item_title_qty'.tr),
          numeric: true,
        ),
        if (state.showPrice)
          DataColumn(
            label: Text('worker_production_report_item_title_price'.tr),
            numeric: true,
          ),
        if (state.showAmount)
          DataColumn(
            label: Text('worker_production_report_item_title_amount'.tr),
            numeric: true,
          ),
        DataColumn(
          label: Text(
              'worker_production_report_item_title_small_order_subsidy'.tr),
        ),
        if (state.showAmount && state.showPrice)
          DataColumn(
            label: Text('worker_production_report_item_title_amount_total'.tr),
            numeric: true,
          ),
        DataColumn(
          label: Text(
              'worker_production_report_item_title_small_order_subsidy_rate'
                  .tr),
        )
      ];
    }
    if (data is WorkerProductionDetailType3) {
      return [
        DataColumn(
          label: Text('worker_production_report_item_title_worker_number'.tr),
        ),
        DataColumn(
          label: Text('worker_production_report_item_title_date'.tr),
        ),
        DataColumn(
          label: Text('worker_production_report_item_title_worker_name'.tr),
        ),
        DataColumn(
          label: Text('worker_production_report_item_title_qty'.tr),
          numeric: true,
        ),
        if (state.showAmount)
          DataColumn(
            label: Text('worker_production_report_item_title_amount'.tr),
            numeric: true,
          ),
      ];
    }
    return [];
  }

  List<DataRow> getItemTableBody(List<WorkerProductionDetail> list) {
    List<DataRow> row = [];
    for (int index = 0; index < list.length; index++) {
      var data = list[index];
      if (data is WorkerProductionDetailType1) {
        row.add(DataRow(
          color: WidgetStateProperty.resolveWith<Color?>(
            (states) => index == list.length - 1
                ? Colors.orange
                : index.isEven
                    ? Colors.white
                    : Colors.grey.shade100,
          ),
          cells: [
            DataCell(Text(data.billNO ?? '')),
            DataCell(Text(data.billDate ?? '')),
            DataCell(Text(data.organizeName ?? '')),
            DataCell(Text(data.deptName ?? '')),
            DataCell(Text(data.dispatchNO ?? '')),
            DataCell(Text(data.processFlowName ?? '')),
            DataCell(Text(data.itemNo ?? '')),
            DataCell(Text(data.processNumber ?? '')),
            DataCell(Text(data.processName ?? '')),
            DataCell(Text(data.qty.toShowString())),
            if (state.showPrice) DataCell(Text(data.price.toShowString())),
            if (state.showAmount) DataCell(Text(data.amount.toShowString())),
            DataCell(Text(data.smallBillSubsidy.toShowString())),
            if (state.showAmount) DataCell(Text(data.amountSum.toShowString())),
            DataCell(Text(data.smallBillSubsidyPCT.toShowString()))
          ],
        ));
      }
      if (data is WorkerProductionDetailType2) {
        row.add(DataRow(
          color: WidgetStateProperty.resolveWith<Color?>(
            (states) => index == list.length - 1
                ? Colors.orange
                : index.isEven
                    ? Colors.white
                    : Colors.grey.shade100,
          ),
          cells: [
            DataCell(Text(data.itemNo ?? '')),
            DataCell(Text(data.processNumber ?? '')),
            DataCell(Text(data.processName ?? '')),
            DataCell(Text(data.qty.toShowString())),
            if (state.showPrice) DataCell(Text(data.price.toShowString())),
            if (state.showAmount) DataCell(Text(data.amount.toShowString())),
            DataCell(Text(data.smallBillSubsidy.toShowString())),
            if (state.showAmount) DataCell(Text(data.amountSum.toShowString())),
            DataCell(Text(data.smallBillSubsidyPCT.toShowString()))
          ],
        ));
      }
      if (data is WorkerProductionDetailType3) {
        row.add(DataRow(
          color: WidgetStateProperty.resolveWith<Color?>(
            (states) => index == list.length - 1
                ? Colors.orange
                : index.isEven
                    ? Colors.white
                    : Colors.grey.shade100,
          ),
          cells: [
            DataCell(Text(data.empNumber ?? '')),
            DataCell(Text(data.date ?? '')),
            DataCell(Text(data.empName ?? '')),
            DataCell(Text(data.qty.toShowString())),
            if (state.showAmount) DataCell(Text(data.amount.toShowString())),
          ],
        ));
      }
    }
    return row;
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      queryWidgets: [
        DatePicker(pickerController: logic.pickerControllerStartDate),
        DatePicker(pickerController: logic.pickerControllerEndDate),
        OptionsPicker(pickerController: logic.pickerControllerReportType),
        EditText(
            hint: 'worker_production_detail_query_hint'.tr,
            controller: logic.tecWorkerNumber),
      ],
      query: () => logic.query(),
      body: Obx(
        () => ListView.builder(
          padding: const EdgeInsets.all(5),
          itemCount: state.dataList.length,
          itemBuilder: (BuildContext context, int index) =>
              getTable(state.dataList[index]),
        ),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<WorkerProductionDetailLogic>();
    super.dispose();
  }
}
