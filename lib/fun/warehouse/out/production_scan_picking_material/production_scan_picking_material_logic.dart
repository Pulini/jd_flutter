import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/bar_code.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/fun/warehouse/code_list_report/code_list_report_view.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/picker/picker_item.dart';

import 'production_scan_picking_material_state.dart';

class ProductionScanPickingMaterialLogic extends GetxController {
  final ProductionScanPickingMaterialState state =
      ProductionScanPickingMaterialState();

  clearBarCodeList() {
    BarCodeInfo.clear(
      type: BarCodeReportType.productionScanPicking.name,
      callback: (v) {
        if (v == state.barCodeList.length) {
          state.barCodeList.clear();
        } else {
          showSnackBar(
            message: 'production_scan_picking_material_data_delete_fail'.tr,
            isWarning: true,
          );
        }
      },
    );
  }

  scanCode(String code) {
    if (state.barCodeList.any((v) => v.code == code)) {
      showSnackBar(
        message: 'production_scan_picking_material_code_exists'.tr,
        isWarning: true,
      );
    } else {
      BarCodeInfo(
        code: code,
        type: BarCodeReportType.productionScanPicking.name,
      )
        ..isUsed = state.usedBarCodeList.any((v) => v.barCode == code)
        ..save(callback: (newBarCode) => state.barCodeList.add(newBarCode));
    }
  }

  deleteItem(BarCodeInfo barCodeList) {
    barCodeList.delete(callback: () => state.barCodeList.remove(barCodeList));
  }

  submit({
    required WorkerInfo worker,
    required PickerSapSupplier? supplier,
    required PickerSapDepartment? department,
  }) {
    if (state.barCodeList.every((v) => v.isUsed)) {
      errorDialog(content: 'production_scan_picking_material_no_code_submit'.tr);
    } else {
      getWaitInStockBarCodeReport(
        barCodeList: state.barCodeList.where((v) => !v.isUsed).toList(),
        type: BarCodeReportType.productionScanPicking,
        success: (report) {
          Get.to(
            () => const CodeListReportPage(),
            arguments: {'reportData': report},
          )?.then((v) {
            if (v != null) {
              state.submitBarCode(
                worker: worker.empCode ?? '',
                supplier: supplier?.supplierNumber ?? '',
                department: department?.departmentId ?? 0,
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

  refreshBarCodeStatus({required Function() refresh}) {
    getAlreadyInStockBarCode(
      type: BarCodeReportType.productionScanPicking,
      success: (list) {
       state.usedBarCodeList = list;
        if (state.barCodeList.isNotEmpty) {
          for (var item in state.barCodeList) {
            if (state.usedBarCodeList.any((v) => v.barCode == item.code)) {
              item.isUsed = true;
            }
          }
        }
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
