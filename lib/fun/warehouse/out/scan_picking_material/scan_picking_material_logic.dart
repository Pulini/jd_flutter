import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/bar_code.dart';
import 'package:jd_flutter/bean/http/response/scan_picking_material_info.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/fun/warehouse/code_list_report/code_list_report_view.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'scan_picking_material_state.dart';

class ScanPickingMaterialLogic extends GetxController {
  final ScanPickingMaterialState state = ScanPickingMaterialState();

  clearBarCodeList() {
    BarCodeInfo.clear(
      type: BarCodeReportType.jinCanMaterialOutStock.name,
      callback: (v) {
        if (v == state.barCodeList.length) {
          state.barCodeList.clear();
        } else {
          showSnackBar(
            message: '本地数据库贴标删除失败',
            isWarning: true,
          );
        }
      },
    );
  }

  scanCode(String code) {
    if (state.barCodeList.any((v) => v.code == code)) {
      showSnackBar(
        message: '条码已存在',
        isWarning: true,
      );
    } else {
      BarCodeInfo(
        code: code,
        type: BarCodeReportType.jinCanMaterialOutStock.name,
      ).save(callback: (newBarCode) => state.barCodeList.add(newBarCode));
    }
  }

  deleteItem(BarCodeInfo barCodeList) {
    barCodeList.delete(callback: () => state.barCodeList.remove(barCodeList));
  }

  submit({
    required WorkerInfo worker,
    required BarCodeProcessInfo process,
  }) {
    state.getBarCodeStatus(
      processFlowID: process.processFlowID ?? 0,
      processName: process.processFlowName ?? '',
      success: (data) {
        for (var v in state.barCodeList) {
          if ((data.list2 ?? []).any((v2) => v2.barCode == v.code)) {
            v.isUsed = true;
          }
          ScanPickingMaterialReportSub1Info? item =
              data.list1?.firstWhereOrNull((v2) => v2.barCode == v.code);
          if (item != null) {
            v.department = item.name;
          }
        }
        if (state.barCodeList.every((v) => v.isUsed)) {
          errorDialog(content: '无条码可提交');
        } else {
          getWaitInStockBarCodeReport(
            barCodeList:state.barCodeList.where((v) => !v.isUsed).toList(),
            type: BarCodeReportType.jinCanMaterialOutStock,
            processFlowID: process.processFlowID ?? 0,
            reverse: state.reverse.value,
            success: (report) {
              Get.to(
                    () => const CodeListReportPage(),
                arguments: {'reportData': report},
              )?.then((v) {
                if (v != null) {
                  state.submitBarCode(
                    success: (msg) {
                      clearBarCodeList();
                      successDialog(content: msg);
                    },
                    error: (msg) => errorDialog(content: msg),
                  );
                }
              });
            },
            error: (msg) => errorDialog(content: msg),
          );
        }
      },
      error: (msg) => errorDialog(content: msg),
    );
  }
}
