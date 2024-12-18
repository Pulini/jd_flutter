import 'package:get/get.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'sap_sales_shipment_state.dart';

class SapSalesShipmentLogic extends GetxController {
  final SapSalesShipmentState state = SapSalesShipmentState();

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

  query(String ins, String date) {
    state.querySalesShipmentList(
      instructionNo: ins,
      deliveryDate: date,
      error: (msg) => errorDialog(content: msg),
    );
  }
}
