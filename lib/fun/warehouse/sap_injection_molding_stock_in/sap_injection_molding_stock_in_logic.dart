import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/bar_code.dart';
import 'package:jd_flutter/fun/warehouse/sap_injection_molding_stock_in/sap_injection_molding_stock_in_report_view.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

import '../../../constant.dart';
import '../../../widget/dialogs.dart';
import 'sap_injection_molding_stock_in_state.dart';

class SapInjectionMoldingStockInLogic extends GetxController {
  final SapInjectionMoldingStockInState state =
      SapInjectionMoldingStockInState();

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  clearBarCodeList() {
    BarCodeInfo.clear(
      type: barCodeTypes[0],
      callback: (v) {
        if (v == state.barCodeList.length) {
          state.barCodeList.clear();
        } else {
          showSnackBar(title: '错误', message: '本地数据库删除失败', isWarning: true);
        }
      },
    );
  }

  scanCode(String code) {
    if (state.barCodeList.any((v) => v.code == code)) {
      showSnackBar(title: '错误', message: '条码已存在', isWarning: true);
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
                      title: '错误', message: '请使用空托盘入库！！', isWarning: true);
                  break;
                case 'Y':
                  showSnackBar(
                      title: '错误', message: '此托盘已在其他仓库使用！！', isWarning: true);
                  break;
              }
            } else {
              showSnackBar(title: '错误', message: '此托盘不存在！！', isWarning: true);
            }
          },
          error: (msg) => errorDialog(content: msg),
        );
        return;
      }
      if (state.pallet == null) {
        showSnackBar(title: '错误', message: '请先扫描托盘！！', isWarning: true);
        return;
      }
      BarCodeInfo(
        code: code,
        type: barCodeTypes[0],
        palletNo: state.palletNumber.value,
      )
        ..isUsed = state.usedList.contains(code)
        ..save(callback: (newBarCode) => state.barCodeList.add(newBarCode));
    }
  }

  refreshBarCodeStatus({required void Function() refresh}) {
    state.getSapLabelList(
      error: (msg) => showSnackBar(title: '错误', message: msg, isWarning: true),
      refresh: refresh,
    );
  }

  deleteItem(BarCodeInfo barCodeList) {
    barCodeList.delete(callback: () {
      state.barCodeList.remove(barCodeList);
    });
  }

  goStockInReport() {
    var list = state.barCodeList.where((v) => !v.isUsed).toList();
    if (list.isEmpty) {
      showSnackBar(title: '错误', message: '没有未入库的标签！！', isWarning: true);
    } else {
      state.getStockInReport(
        list: list,
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
        successDialog(content: msg);
      },
      error: (msg) => errorDialog(content: msg),
    );
  }
}
