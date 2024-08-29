import 'dart:convert';

import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/scan_barcode_info.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/fun/other/scan/part_process_scan/part_process_scan_report_view.dart';
import 'package:jd_flutter/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'part_process_scan_state.dart';

class PartProcessScanLogic extends GetxController {
  final PartProcessScanState state = PartProcessScanState();

  addBarCode(String code, Function() callback) {
    if (code.isEmpty) {
      showSnackBar(
          title: 'snack_bar_default_wrong'.tr,
          message: '请输入贴标号',
          isWarning: true);
      return;
    }
    if (state.barCodeList.any((v) => v == code)) {
      showSnackBar(
          title: 'snack_bar_default_wrong'.tr,
          message: '标签已存在',
          isWarning: true);
      return;
    }
    state.barCodeList.add(code);
    callback.call();
  }

  barCodeModify() {
    if (state.barCodeList.isEmpty) {
      showSnackBar(
        title: 'snack_bar_default_wrong'.tr,
        message: '没有可提交的条码',
        isWarning: true,
      );
    } else {
      state.getPartProcessReportedReport(
        success: () => Get.to(() => const PartProcessScanReportPage()),
        error: (msg) => errorDialog(content: msg),
      );
    }
  }

  List<int> getSelectedWorker(List<Distribution> dis) {
    var ids = <int>[];
    for (var v in dis) {
      if (state.workerList.any((v2) => v2.empID == v.empId)) {
        ids.add(v.empId);
      }
    }
    return ids;
  }

  deleteItem(int index) {
    state.barCodeList.removeAt(index);
  }

  setSelectedAll(int index, bool isAll) {
    if (index == 0) {
      for (var v in state.modifyDistributionList) {
        v.isSelect.value = isAll;
      }
    }
    if (index == 1) {}
    if (index == 2) {
      for (var v in state.modifyBarCodeList) {
        v.isSelect.value = isAll;
      }
    }
    state.isSelectAll.value = isAll;
  }

  refreshSelectedAll(int index) {
    if (index == 0) {
      state.isSelectAll.value =
          state.modifyDistributionList.where((v) => v.isSelect.value).length ==
              state.modifyDistributionList.length;
    }
    if (index == 1) {}
    if (index == 2) {
      state.isSelectAll.value =
          state.modifyBarCodeList.where((v) => v.isSelect.value).length ==
              state.modifyBarCodeList.length;
    }
  }

  bool isMultiSelect(int index) {
    var isMultiSelect = false;
    if (index == 0) {
      isMultiSelect =
          state.modifyDistributionList.where((v) => v.isSelect.value).length >
              1;
    }
    if (index == 1) {}
    if (index == 2) {}
    return isMultiSelect;
  }

  double getPercentage() {
    var total = 0.0;
    for (var v in state.workerPercentageList) {
      total = total.add(v.distributionQty);
    }
    return total;
  }

  double getWorkerPercentageMax(int empID) {
    var total = 0.0;
    for (var v in state.workerPercentageList) {
      if (v.empId != empID) {
        total = total.add(v.distributionQty);
      }
    }
    return 1.0.sub(total.div(1)).mul(100);
  }

  String getPercentageText() {
    var total = 0.0;
    for (var v in state.workerPercentageList) {
      total = total.add(v.distributionQty);
    }
    return '${(total * 10000).round().toDouble().div(100).toShowString()}%';
  }

  initPercentageList() {
    state.workerPercentageList.value = [
      for (var w in state.workerList)
        Distribution(
          name: w.empName ?? '',
          number: w.empCode ?? '',
          empId: w.empID ?? 0,
          distributionQty: 0,
        )
    ];
  }

  addWorkerPercentage(WorkerInfo w) {
    state.workerPercentageList.add(Distribution(
      name: w.empName ?? '',
      number: w.empCode ?? '',
      empId: w.empID ?? 0,
      distributionQty: 0,
    ));
  }

  savePercentage() {
    spSave(
      'WorkerPercentageList',
      jsonEncode(state.workerPercentageList.map((v) => v.toJson()).toList()),
    );
    successDialog(content: '当前比例保存成功。');
  }

  usePercentage() {
    var jsonString = spGet('WorkerPercentageList');
    if (jsonString == null) {
      showSnackBar(title: '应用比例', message: '没有保存比例的记录！', isWarning: true);
    } else {
      var list = <Distribution>[
        for (var json in jsonDecode(jsonString)) Distribution.fromJson(json)
      ];
      if (list.isEmpty) {}
      state.workerPercentageList.value = [
        for (var wi in state.workerList)
          list.any((v) => v.empId == wi.empID)
              ? list.firstWhere((v) => v.empId == wi.empID)
              : Distribution(
                  name: wi.empName ?? '',
                  number: wi.empCode ?? '',
                  empId: wi.empID ?? 0,
                  distributionQty: 0,
                )
      ];
      successDialog(content: '已成功载入上次保存的比例。');
    }
  }

  quickPercentage() {
    state.modifyDistributionList.where((v) => v.isSelect.value).forEach((v) {
      var total = 0.0;
      for (var r in v.reportList) {
        total = total.add(r.qty.toDoubleTry());
      }
      v.distribution.value = [
        for (var p
            in state.workerPercentageList.where((v) => v.distributionQty > 0))
          Distribution(
            name: p.name,
            number: p.number,
            empId: p.empId,
            distributionQty: (p.distributionQty * total)
                .mul(100)
                .round()
                .toDouble()
                .div(100),
          )
      ];
    });
    successDialog(content: '快速分配完成!', back: () => Get.back());
  }

  reportModifySubmit() {}
}
