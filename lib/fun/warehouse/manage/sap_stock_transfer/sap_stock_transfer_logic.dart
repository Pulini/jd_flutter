import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/warehouse/manage/sap_stock_transfer/sap_stock_transfer_dialog.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'sap_stock_transfer_state.dart';

class SapStockTransferLogic extends GetxController {
  final SapStockTransferState state = SapStockTransferState();
  TextEditingController? locationDialogController;
  var locationOrPalletController = TextEditingController();

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

  scanCode({
    required String warehouse,
    required String code,
  }) {
    if (code.isPallet()) {
      if (state.labelList.isEmpty) {
        state.palletNumber.value = code;
        state.checkPallet(
          warehouse: warehouse,
          palletNo: code,
          error: (msg) => errorDialog(content: msg),
        );
      } else {
        if (state.palletNumber.value == code) {
          bool isAllSelected = state.labelList.every((v) => v.select);
          for (var v in state.labelList) {
            v.select = !isAllSelected;
          }
          state.labelList.refresh();
        } else {
          state.checkPallet(
            warehouse: warehouse,
            targetPalletNo: code,
            error: (msg) => errorDialog(content: msg),
          );
          locationOrPalletController.text = code;
        }
      }
      return;
    }
    if (code.isLabel()) {
      if (state.labelList.isEmpty) {
        state.checkPallet(
          warehouse: warehouse,
          labelNo: code,
          error: (msg) => errorDialog(content: msg),
        );
      } else {
        state.labelList
            .where((v) => v.labelNumber == code)
            .forEach((v) => v.select = !v.select);
        state.labelList.refresh();
      }
      return;
    }
    if (code.length < 10) {
      if (locationDialogController != null) {
        locationDialogController!.text = code;
      } else {
        state.targetPallet = null;
        state.newPallet = null;
        locationOrPalletController.text = code;
      }
      return;
    }
    errorDialog(content: '请扫描正确的条码！');
  }

  transfer(String warehouse) {
    if (state.labelList.isEmpty) {
      informationDialog(content: '请扫描托盘或标签！');
      return;
    }
    if (locationOrPalletController.text.isEmpty) {
      informationDialog(content: '请扫描目的库位标签或托盘标签！');
      return;
    }
    if (state.targetPallet == null && state.newPallet == null) {
      if (state.labelList.every((v) => !v.select)) {
        informationDialog(content: '整托盘移库必须勾选全部标签！');
      } else {
        //托盘及其全部货物移动库位
        state.transferToLocation(
          warehouse: warehouse,
          locationOrPalletNumber: locationOrPalletController.text,
          success: (msg) => successDialog(
            content: msg,
            back: () => locationOrPalletController.clear(),
          ),
          error: (msg) => errorDialog(content: msg),
        );
      }
    } else {
      var labels = state.labelList.where((v) => v.select).toList();
      if (labels.isEmpty) {
        informationDialog(content: '请扫描或勾选要移库的货物！');
      } else {
        if (state.targetPallet != null) {
          //托盘及其全部或部分货物移动至已有货物的托盘
          state.transferToTargetPallet(
            warehouse: warehouse,
            list: labels,
            success: (msg) => successDialog(
              content: msg,
              back: () => locationOrPalletController.clear(),
            ),
            error: (msg) => errorDialog(content: msg),
          );
        }
        if (state.newPallet != null) {
          //托盘及其全部或部分货物移动至新托盘
          locationDialogController = TextEditingController();
          inputLocationDialog(
            controller: locationDialogController!,
            location: () => state.transferToNewPallet(
              warehouse: warehouse,
              tLocation: locationDialogController!.text,
              list: state.labelList.where((v) => v.select).toList(),
              success: (msg) => successDialog(
                content: msg,
                back: () {
                  locationOrPalletController.clear();
                  locationDialogController = null;
                },
              ),
              error: (msg) => errorDialog(
                content: msg,
                back: () => locationDialogController = null,
              ),
            ),
          );
        }
      }
    }
  }
}
