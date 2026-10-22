import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/bar_code.dart';
import 'package:jd_flutter/fun/warehouse/code_list_report/code_list_report_view.dart';
import 'package:jd_flutter/fun/warehouse/in/suppliers_scan_store/suppliers_scan_store_state.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class SuppliersScanStoreLogic extends GetxController {
  final SuppliersScanStoreState state = SuppliersScanStoreState();

  //清空供应商扫码入库的条码
  void clearBarCodeList() {
    BarCodeInfo.clear(
      type: BarCodeReportType.supplierScanInStock.text,
      callback: (v) {
        if (v == state.barCodeList.length) {
          state.barCodeList.clear();
        } else {
          showSnackBar(
              message: 'suppliers_scan_delete_error'.tr, isWarning: true);
        }
      },
    );
  }

  //添加条码
  void scanCode(String code) {
    if (state.barCodeList.any((v) => v.code == code)) {
      showSnackBar(message: 'suppliers_scan_have_code'.tr, isWarning: true);
    } else {
      if (code.isPallet()) {
        state.checkPallet(
          pallet: code,
          success: (data) {
            if (data.item2![0].palletExistence == 'X') {
              switch (data.item2![0].palletState) {
                case '':
                  state.pallet = data.item2![0];
                  state.palletNumber.value = code;
                  break;
                case 'X':
                  showSnackBar(
                      message: 'suppliers_scan_use_empty_pallets'.tr,
                      isWarning: true);
                  break;
                case 'Y':
                  showSnackBar(
                      message: 'suppliers_scan_use_other'.tr, isWarning: true);
                  break;
              }
            } else {
              showSnackBar(
                  message: 'suppliers_scan_does_not_exist'.tr, isWarning: true);
            }
          },
          error: (msg) => errorDialog(content: msg),
        );
        return;
      }
      BarCodeInfo(
        code: code,
        type: BarCodeReportType.supplierScanInStock.text,
      )
        ..palletNo = state.palletNumber.value
        ..isUsed = state.usedList.contains(code)
        ..save(callback: (newBarCode) => state.barCodeList.add(newBarCode));
    }
  }

  bool haveCodeData() {
    if (state.barCodeList.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  //删除对应条码
  void deleteCode(BarCodeInfo barCodeList) {
    barCodeList.deleteByCode(callback: () {
      state.barCodeList.remove(barCodeList);
    });
  }

  void goReport({
    required String postingDate,
    required String stockID,
  }) {
    if (state.barCodeList.isNotEmpty) {
      state.goReport(
        success: (data) => Get.to(
          () => const CodeListReportPage(),
          arguments: {'reportData': data},
        )?.then((v) {
          if (v == null) {
            state.peopleNumber.text = '';
            state.peopleName.value = '';
            showSnackBar(
              title: 'dialog_default_title_information'.tr,
              message: 'suppliers_scan_not_completed'.tr,
              isWarning: true,
            );
          } else if (v == true) {
            submitCode(postingDate: postingDate, stockID: stockID);
          }
        }),
        error: (msg) => errorDialog(content: msg),
      );
    } else {
      showSnackBar(
          title: 'shack_bar_warm'.tr,
          message: 'suppliers_scan_no_barcode_to_submit'.tr);
    }
  }

  //获得已入库条形码数据
  void getUsedBarCode({
    Function()? refresh,
  }) {
    state.getUsedBarCode(
      success: (list) {
        state.usedList.clear();
        for (var i = 0; i < list.length; ++i) {
          state.usedList.add(list[i].barCode.toString());
        }
        for (var data in state.barCodeList) {
          data.isUsed = state.usedList.contains(data.code);
        }
        refresh?.call();
      },
      error: (msg) {
        showSnackBar(
          title: 'dialog_default_title_information'.tr,
          message: msg,
        );
        refresh?.call();
      },
    );
  }

  //提交条形码数据,自动生成外购入库单
  void submitCode({
    required String postingDate,
    required String stockID,
  }) {
    state.submitCode(
      postingDate: postingDate,
      stockID: stockID,
      success: (msg) => successDialog(
        content: msg,
        back: () {
          clearBarCodeList();
          getUsedBarCode();
        },
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }
}
