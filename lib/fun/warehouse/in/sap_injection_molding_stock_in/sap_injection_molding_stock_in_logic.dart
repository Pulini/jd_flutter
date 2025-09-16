import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/bar_code.dart';
import 'package:jd_flutter/fun/warehouse/in/sap_injection_molding_stock_in/sap_injection_molding_stock_in_report_view.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'sap_injection_molding_stock_in_state.dart';

class SapInjectionMoldingStockInLogic extends GetxController {
  final SapInjectionMoldingStockInState state =
      SapInjectionMoldingStockInState();

  clearBarCodeList() {
    BarCodeInfo.clear(
      type: BarCodeReportType.injectionMoldingStockIn.text,
      callback: (v) {
        if (v == state.barCodeList.length) {
          state.barCodeList.clear();
        } else {
          showSnackBar(
            message: 'sap_injection_molding_stock_in_delete_failed'.tr,
            isWarning: true,
          );
        }
      },
    );
  }

  scanCode(String code) {
    if (state.barCodeList.any((v) => v.code == code)) {
      showSnackBar(
        message: 'sap_injection_molding_stock_in_bar_code_exists'.tr,
        isWarning: true,
      );
    } else {
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
                  showSnackBar(
                    message:
                        'sap_injection_molding_stock_in_use_empty_pallet'.tr,
                    isWarning: true,
                  );
                  break;
                case 'Y':
                  showSnackBar(
                    message:
                        'sap_injection_molding_stock_in_pallet_occupied'.tr,
                    isWarning: true,
                  );
                  break;
              }
            } else {
              showSnackBar(
                message: 'sap_injection_molding_stock_in_pallet_not_exists'.tr,
                isWarning: true,
              );
            }
          },
          error: (msg) => errorDialog(content: msg),
        );
        return;
      }
      if (state.pallet == null) {
        showSnackBar(
          message: 'sap_injection_molding_stock_in_scan_pallet_tips'.tr,
          isWarning: true,
        );
        return;
      }
      if (!state.reportedList.contains(code)) {
        showSnackBar(
          message: 'sap_injection_molding_stock_in_label_state_error'.tr,
          isWarning: true,
        );
        return;
      }
      BarCodeInfo(
        code: code,
        type: BarCodeReportType.injectionMoldingStockIn.text,
      )
        ..palletNo = state.palletNumber.value
        ..save(callback: (newBarCode) => state.barCodeList.add(newBarCode));
    }
  }

  refreshBarCodeStatus({Function()? refresh}) {
    state.getSapLabelList(
      error: (msg) => showSnackBar(
        message: msg,
        isWarning: true,
      ),
      refresh:()=> refresh?.call(),
    );
  }

  deleteItem(BarCodeInfo barCodeList) {
    barCodeList.delete(callback: () {
      state.barCodeList.remove(barCodeList);
    });
  }

  goStockInReport() {
    if (state.barCodeList.isEmpty) {
      showSnackBar(
        message: 'sap_injection_molding_stock_in_no_stock_in_label'.tr,
        isWarning: true,
      );
    } else {
      state.getStockInReport(
        success: () =>
            Get.to(() => const SapInjectionMoldingStockInReportPage()),
        error: (msg) => errorDialog(content: msg),
      );
    }
  }

  submitStockIn({
    required String leaderNumber,
    required ByteData leaderSignature,
    required String userNumber,
    required ByteData userSignature,
    required String postingDate,
  }) {
    state.submitInjectionMoldingStockIn(
      leaderNumber: leaderNumber,
      leaderSignature: leaderSignature,
      userNumber: userNumber,
      userSignature: userSignature,
      postingDate: postingDate,
      success: (msg) {
        clearBarCodeList();
        successDialog(content: msg,back: ()=>Get.back());
      },
      error: (msg) => errorDialog(content: msg),
    );
  }
}
