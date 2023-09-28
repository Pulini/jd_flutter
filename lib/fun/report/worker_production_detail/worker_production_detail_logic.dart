import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils.dart';

import '../../../http/response/worker_production_detail_info.dart';
import '../../../http/web_api.dart';
import '../../../route.dart';
import '../../../widget/dialogs.dart';
import '../../../widget/picker/picker_controller.dart';
import 'worker_production_detail_state.dart';

class WorkerProductionDetailLogic extends GetxController {
  final WorkerProductionDetailState state = WorkerProductionDetailState();

  var pickerControllerStartDate = DatePickerController(
    PickerType.date,
    saveKey:
        '${RouteConfig.workerProductionDetail.name}${PickerType.date}start',
    lastDate: DateTime.now(),
  );

  var pickerControllerEndDate = DatePickerController(
    PickerType.date,
    saveKey: '${RouteConfig.workerProductionDetail.name}${PickerType.date}end',
    lastDate: DateTime.now(),
  );

  var pickerControllerReportType = OptionsPickerController(
    PickerType.mesProductionReportType,
    saveKey:
        '${RouteConfig.workerProductionDetail.name}${PickerType.mesProductionReportType}',
  );

  var textControllerWorker = TextEditingController();

  query() {
    httpGet(
      loading: '正在查询计件明细...',
      method: webApiProductionReport,
      query: {
        'BeginDate': pickerControllerStartDate.getDateFormatYMD(),
        'EndDate': pickerControllerEndDate.getDateFormatYMD(),
        'EmpNumber': textControllerWorker.text,
        'ItemID': pickerControllerReportType.selectedId.value,
        // 'DeptID': userController.user.value?.departmentID ?? '',
        'DeptID': '554821',
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        state.dataList.value = formatData(response.data);
        Get.back();
      } else {
        errorDialog(content: response.message ?? 'query_default_error'.tr);
      }
    });
  }

  List<WorkerProductionDetailShow> formatData(dynamic json) {
    var list = <WorkerProductionDetail>[];
    for (var item in jsonDecode(json)) {
      switch (pickerControllerReportType.selectedId.value) {
        case '1001':
          list.add(WorkerProductionDetailType1.fromJson(item));
          break;
        case '1002':
          list.add(WorkerProductionDetailType2.fromJson(item));
          break;
        case '1019':
          list.add(WorkerProductionDetailType3.fromJson(item));
          break;
      }
    }
    var ids = <int>[];
    var data = <WorkerProductionDetailShow>[];
    for (var v in list) {
      if (!ids.contains(v.empID)) ids.add(v.empID!);
    }
    for (var id in ids) {
      var item = list.where((v) => v.empID == id);
      var body = item.where((v) => v.level != 1 && v.level != 2).toList();
      var head = item.singleWhere((v) => v.level == 2);
      var title = '';
      switch (pickerControllerReportType.selectedId.value) {
        case '1001':
          title = (item.singleWhere((v) => v.level == 1)
                  as WorkerProductionDetailType1)
              .billNO!;
          break;
        case '1002':
          title = (item.singleWhere((v) => v.level == 1)
                  as WorkerProductionDetailType2)
              .itemNo!;
          break;
        case '1019':
          title = (item.singleWhere((v) => v.level == 1)
                  as WorkerProductionDetailType3)
              .date!;
          break;
      }
      data.add(WorkerProductionDetailShow(title, head, body));
    }
    return data;
  }

  Widget getTable(WorkerProductionDetailShow data) {
    return SingleChildScrollView(
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
              headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                  return Colors.blueAccent.shade100;
                },
              ),
              columns: getItemTableHead(data.head),
              rows: getItemTableBody(data.body),
            )
          ],
        ),
      ),
    );
  }

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
          color: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              return index == list.length - 1
                  ? Colors.orange
                  : index.isEven
                      ? Colors.white
                      : Colors.grey.shade100;
            },
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
          color: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              return index == list.length - 1
                  ? Colors.orange
                  : index.isEven
                  ? Colors.white
                  : Colors.grey.shade100;
            },
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
          color: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              return index == list.length - 1
                  ? Colors.orange
                  : index.isEven
                  ? Colors.white
                  : Colors.grey.shade100;
            },
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
}
