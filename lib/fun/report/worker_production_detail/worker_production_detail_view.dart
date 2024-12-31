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
        DataColumn(label: Text(data.billNO ?? '')),
        DataColumn(label: Text(data.billDate ?? '')),
        DataColumn(label: Text(data.organizeName ?? '')),
        DataColumn(label: Text(data.deptName ?? '')),
        DataColumn(label: Text(data.dispatchNO ?? '')),
        DataColumn(label: Text(data.processFlowName ?? '')),
        DataColumn(label: Text(data.itemNo ?? '')),
        DataColumn(label: Text(data.processNumber ?? '')),
        DataColumn(label: Text(data.processName ?? '')),
        DataColumn(
          label: Text(data.qty.toShowString()),
          numeric: true,
        ),
        if (state.showPrice)
          DataColumn(
            label: Text(data.price.toShowString()),
            numeric: true,
          ),
        if (state.showAmount)
          DataColumn(
            label: Text(data.amount.toShowString()),
            numeric: true,
          ),
        DataColumn(label: Text(data.smallBillSubsidy.toShowString())),
        if (state.showAmount)
          DataColumn(
            label: Text(data.amountSum.toShowString()),
            numeric: true,
          ),
        DataColumn(label: Text(data.smallBillSubsidyPCT.toShowString()))
      ];
    }
    if (data is WorkerProductionDetailType2) {
      return [
        DataColumn(label: Text(data.itemNo ?? '')),
        DataColumn(label: Text(data.processNumber ?? '')),
        DataColumn(label: Text(data.processName ?? '')),
        DataColumn(
          label: Text(data.qty.toShowString()),
          numeric: true,
        ),
        if (state.showPrice)
          DataColumn(
            label: Text(data.price.toShowString()),
            numeric: true,
          ),
        if (state.showAmount)
          DataColumn(
            label: Text(data.amount.toShowString()),
            numeric: true,
          ),
        DataColumn(label: Text(data.smallBillSubsidy.toShowString())),
        if (state.showAmount)
          DataColumn(
            label: Text(data.amountSum.toShowString()),
            numeric: true,
          ),
        DataColumn(label: Text(data.smallBillSubsidyPCT.toShowString()))
      ];
    }
    if (data is WorkerProductionDetailType3) {
      return [
        DataColumn(label: Text(data.empNumber ?? '')),
        DataColumn(label: Text(data.date ?? '')),
        DataColumn(label: Text(data.empName ?? '')),
        DataColumn(
          label: Text(data.qty.toShowString()),
          numeric: true,
        ),
        if (state.showAmount)
          DataColumn(
            label: Text(data.amount.toShowString()),
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
        EditText(hint: 'worker_production_detail_query_hint'.tr, onChanged: (v) => state.etWorker = v),
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
