import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils/utils.dart';

import '../../../bean/http/response/sap_no_label_stock_in_info.dart';
import '../../../widget/dialogs.dart';
import 'sap_no_label_stock_in_state.dart';

class SapNoLabelStockInLogic extends GetxController {
  final SapNoLabelStockInState state = SapNoLabelStockInState();

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

  query({
    required String reportStartDate,
    required String reportEndDate,
    required String dispatchNumber,
    required String materialCode,
    required String process,
  }) {
    state.queryOrderList(
      reportStartDate: reportStartDate,
      reportEndDate: reportEndDate,
      dispatchNumber: dispatchNumber,
      materialCode: materialCode,
      process: process,
      error: (msg) => errorDialog(content: msg),
    );
  }

  modifyMaterialStockInQty(double qty, SapNoLabelStockInItemInfo data) {
    double surplus = qty;
    for (var v in data.materialList) {
      var needStockInQty = (v.reportQty ?? 0).sub(v.receivedQty ?? 0);
      if (surplus > needStockInQty) {
        v.pickQty = needStockInQty;
        surplus = surplus.sub(needStockInQty);
      } else {
        v.pickQty = surplus;
        surplus = 0;
      }
    }
    state.orderList.refresh();
  }

  submitStockIn({
    required String leaderNumber,
    required ByteData leaderSignature,
    required String userNumber,
    required ByteData userSignature,
    required String process,
    required String postingDate,
    required Function() success,
  }) {
    state.submitNoLabelStockIn(
      leaderNumber: leaderNumber,
      leaderSignature: leaderSignature,
      userNumber: userNumber,
      userSignature: userSignature,
      process: process,
      postingDate: postingDate,
      success: (msg) => successDialog(content: msg, back: () => success.call()),
      error: (msg) => errorDialog(content: msg),
    );
  }
}
