import 'package:get/get.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'sap_produce_stock_in_state.dart';

class SapProduceStockInLogic extends GetxController {
  final SapProduceStockInState state = SapProduceStockInState();

  scanCode(String code) {
    try {
      var exists = state.barCodeList.firstWhere((v) => v.labelCode == code);
      var max = (exists.labelTotalQty ?? 0) - (exists.labelReceivedQty ?? 0);
      if (max - exists.scanQty > 0) {
        exists.scanQty += 1;
        state.barCodeList.refresh();
      } else {
        informationDialog(
          content: 'sap_produce_stock_in_scan_bar_code_finish'.trArgs([code]),
        );
      }
    } catch (e) {
      state.getOrderInfoFromCode(
        labelCode: code,
        error: (msg) => errorDialog(content: msg),
      );
    }
  }
}
