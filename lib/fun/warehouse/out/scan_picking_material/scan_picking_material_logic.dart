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

  void clearBarCodeList() {
    BarCodeInfo.clear(
      type: BarCodeReportType.jinCanMaterialOutStock.name,
      callback: (v) {
        if (v == state.barCodeList.length) {
          state.barCodeList.clear();
        } else {
          showSnackBar(
            message: 'scan_picking_material_data_delete_fail'.tr,
            isWarning: true,
          );
        }
      },
    );
  }

  void scanCode(String code) {
    if (state.barCodeList.any((v) => v.code == code)) {
      showSnackBar(
        message: 'scan_picking_material_code_exists'.tr,
        isWarning: true,
      );
    } else {
      BarCodeInfo(
        code: code,
        type: BarCodeReportType.jinCanMaterialOutStock.name,
      ).save(callback: (newBarCode) => state.barCodeList.add(newBarCode));
    }
  }

  void deleteItem(BarCodeInfo barCodeList) {
    barCodeList.delete(callback: () => state.barCodeList.remove(barCodeList));
  }

  void submit({
    required WorkerInfo worker,
    required BarCodeProcessInfo process,
  }) {
    state.getBarCodeStatus(
      processFlowID: process.processFlowID ?? 0,
      processName: process.processFlowName ?? '',
      success: (data,msg) {
        for (var v in state.barCodeList) {
          if ((data.list2 ?? []).any((v2) => v2.barCode == v.code)) {
            v.isUsed = true;
          }
          var item = data.list1?.firstWhereOrNull((v2) => v2.barCode == v.code);
          if (item != null) {
            v.department = item.name;
          }
        }
        if(msg!='成功'){
          errorDialog(content: msg);
        }
      },

      finish: () {
        if (state.barCodeList.every((v) => v.isUsed)) {
          errorDialog(content: 'scan_picking_material_no_code_submit'.tr);
        } else {
          getWaitInStockBarCodeReport(
            barCodeList: state.barCodeList.where((v) => !v.isUsed).toList(),
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
    );
  }
}
