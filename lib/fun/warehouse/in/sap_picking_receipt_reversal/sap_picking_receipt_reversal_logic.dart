import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'sap_picking_receipt_reversal_state.dart';

class SapPickingReceiptReversalLogic extends GetxController {
  final SapPickingReceiptReversalState state = SapPickingReceiptReversalState();


  void query({
    required String order,
    required String materialCode,
    required int orderType,
    required String startDate,
    required String endDate,
    required String warehouse,
  }) {
    state.queryOrderList(
      order: order,
      materialCode: materialCode,
      orderType: orderType,
      startDate: startDate,
      endDate: endDate,
      warehouse: warehouse,
      error: (msg) => errorDialog(content: msg),
    );
  }

  void productionReceiptWriteOff({
    required String leaderNumber,
    required ByteData leaderSignature,
    required String userNumber,
    required ByteData userSignature,
    required String postingDate,
    required Function() refresh,
  }) {
    state.productionReceiptWriteOff(
      leaderNumber: leaderNumber,
      leaderSignature: leaderSignature,
      userNumber: userNumber,
      userSignature: userSignature,
      postingDate: postingDate,
      success: (msg) => successDialog(content: msg, back: refresh),
      error: (msg) => errorDialog(content: msg),
    );
  }
}
