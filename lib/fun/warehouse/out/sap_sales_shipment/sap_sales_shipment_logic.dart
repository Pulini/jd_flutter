import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'sap_sales_shipment_state.dart';

class SapSalesShipmentLogic extends GetxController {
  final SapSalesShipmentState state = SapSalesShipmentState();


  query(String ins, String date) {
    state.querySalesShipmentList(
      instructionNo: ins,
      deliveryDate: date,
      error: (msg) => errorDialog(content: msg),
    );
  }

  refreshPallet(int index) {
    state.orderList[index].palletList.clear();
    state.palletList.clear();
    getPalletList(index);
  }

  getPalletList(int index) {
    if (state.orderList[index].palletList.isEmpty) {
      state.checkPalletOrLabel(
        instructionNo:
            state.orderList[index].instructionList[0].instructionNo ?? '',
        success: (palletList) {
          for (var v in palletList) {
            v.pickQty = 0;
          }
          state.orderList[index].palletList = palletList;
          groupBy(state.orderList[index].palletList, (v) => v.palletNumber)
              .forEach((k, v) {
            state.palletList.add(v);
          });
        },
        error: (msg) => errorDialog(content: msg),
      );
    } else {
      groupBy(state.orderList[index].palletList, (v) => v.palletNumber)
          .forEach((k, v) {
        state.palletList.add(v);
      });
    }
  }

  scanCode(String code) {
    if (code.isPallet()) {
      state.palletList.where((v) => v[0].palletNumber == code).forEach((v) {});
      for (var pallet in state.palletList) {
        if (pallet[0].palletNumber == code) {
          for (var label in pallet) {
            label.pickQty > 0
                ? label.pickQty = 0
                : label.pickQty = label.quantity ?? 0;
          }
        }
      }
      state.palletList.refresh();
      return;
    }
    if (code.isLabel()) {
      for (var pallet in state.palletList) {
        pallet.where((v) => v.labelCode == code).forEach((label) {
          label.pickQty > 0
              ? label.pickQty = 0
              : label.pickQty = label.quantity ?? 0;
        });
      }
      state.palletList.refresh();
      return;
    }
    errorDialog(content: 'sap_sales_shipment_scan_wrong_barcode_tips'.tr);
  }

  postingShipment({required Function() refresh}) {
    state.postingSalesShipment(
      success: (msg) => successDialog(content: msg, back: refresh),
      error: (msg) => errorDialog(content: msg),
    );
  }
}
