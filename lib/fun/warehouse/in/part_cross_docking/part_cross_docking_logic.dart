import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/bar_code.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/fun/warehouse/code_list_report/code_list_report_view.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'part_cross_docking_state.dart';

class PartCrossDockingLogic extends GetxController {
  final PartCrossDockingState state = PartCrossDockingState();

  void clearBarCodeList() {
    BarCodeInfo.clear(
      type: BarCodeReportType.productionScanInStock.text,
      callback: (v) {
        if (v == state.barCodeList.length) {
          state.barCodeList.clear();
        } else {
          showSnackBar(
            message: 'part_cross_docking_delete_database_failed'.tr,
            isWarning: true,
          );
        }
      },
    );
  }

  void scanCode(String code) {
    if (state.barCodeList.any((v) => v.code == code)) {
      if (code.isPallet()) {
        state.checkPallet(
          pallets: [code],
          success: (data) {
            if (data.item2![0].palletExistence == 'X') {
              switch (data.item2![0].palletState) {
                case '':
                  state.pallet = data.item2![0];
                  state.palletNumber.value = code;
                  break;
                case 'X':
                  showSnackBar(message: 'part_cross_docking_pallet_not_empty'.tr, isWarning: true);
                  break;
                case 'Y':
                  showSnackBar(message: 'part_cross_docking_pallet_used'.tr, isWarning: true);
                  break;
              }
            } else {
              showSnackBar(message: 'part_cross_docking_pallet_not_exist'.tr, isWarning: true);
            }
          },
          error: (msg) => errorDialog(content: msg),
        );
        return;
      }
    } else {
      BarCodeInfo(
        code: code,
        type: BarCodeReportType.productionScanInStock.text,
      )
        ..palletNo = state.palletNumber.value
        ..isUsed = state.usedList.contains(code)
        ..save(callback: (newBarCode) => state.barCodeList.add(newBarCode));
    }
  }

  void deleteItem(BarCodeInfo barCodeList) {
    barCodeList.delete(callback: () => state.barCodeList.remove(barCodeList));
  }

  //验证生产扫码入库的数据
  void submit(Function(String) success) {
    state.checkBarCodeReportState(
      success: (data, msg) {
        var message = '';
        var codeSet = data.getAllBarCode().toSet();
        var matchedCodes = state.barCodeList
            .where((barCode) => codeSet.contains(barCode.code))
            .toList();
        for (var barCode in matchedCodes) {
          barCode.isHave = true;
          message += '${barCode.code},\n';
        }
        if (message.isNotEmpty) {
          success.call('part_cross_docking_not_report_tips'.trArgs([message]));
        } else {
          success.call(msg);
        }
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  void getReport({
    required WorkerInfo worker,
  }) {
    if (state.barCodeList.every((v) => v.isUsed)) {
      errorDialog(
          content: 'production_scan_picking_material_no_code_submit'.tr);
    } else {
      getWaitInStockBarCodeReport(
        barCodeList: state.barCodeList.where((v) => !v.isUsed).toList(),
        type: BarCodeReportType.productionScanInStock,
        success: (report) {
          Get.to(
            () => const CodeListReportPage(),
            arguments: {'reportData': report},
          )?.then((v) {
            if (v != null) {
              state.submitBarCode(
                worker: worker.empCode ?? '',
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
  }

  void refreshBarCodeStatus({required Function() refresh}) {
    getAlreadyInStockBarCode(
      type: BarCodeReportType.productionScanInStock,
      success: (list) {
        state.usedList.addAll(list.map((v) => v.barCode ?? '').toList());
        state.usedList = state.usedList.toSet().toList();
        state.barCodeList
            .where((item) => state.usedList.contains(item.code))
            .forEach((item) => item.isUsed = true);
        state.barCodeList.refresh();
        refresh.call();
      },
      error: (msg) {
        refresh.call();
        errorDialog(content: msg);
      },
    );
  }
}
