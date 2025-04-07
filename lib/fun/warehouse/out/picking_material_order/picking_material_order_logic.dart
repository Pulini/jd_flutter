import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/picking_material_order_info.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/preview_a4paper_widget.dart';

import 'picking_material_order_state.dart';

class PickingMaterialOrderLogic extends GetxController {
  final PickingMaterialOrderState state = PickingMaterialOrderState();

  printMaterialList(String orderNumber) {
    state.getMaterialPrintInfo(
      orderNumber: orderNumber,
      success: (info) =>
          Get.to(() => PreviewA4Paper(paperWidgets: createA4Paper(info))),
      error: (msg) => errorDialog(content: msg),
    );
  }


  queryPickingMaterialOrder({
    required String startDate,
    required String endDate,
    required String instruction,
    required String pickingMaterialOrder,
    required String sapSupplier,
    required String sapFactory,
    required String sapWarehouse,
  }) {
    state.getPickingMaterialOrderList(
      startDate:startDate,
      endDate:endDate,
      instruction: instruction,
      pickingMaterialOrder: pickingMaterialOrder,
      sapSupplier: sapSupplier,
      sapFactory: sapFactory,
      sapWarehouse: sapWarehouse,
      error: (msg) => errorDialog(content: msg),
    );
  }

  posting({
    required String faceImage,
    required PickingMaterialOrderInfo order,
  }) {
    state.postingPickingMaterialOrder(
      faceImage: faceImage,
      order: order,
      success: (msg) =>
          successDialog(content: msg, back: () => Get.back(result: true)),
      error: (msg) => errorDialog(content: msg),
    );
  }

   reportPreparedMaterialsProgress( PickingMaterialOrderInfo order) {
     state.reportPreparedMaterialsProgress(
       order: order,
       success: (msg) =>
           successDialog(content: msg, back: () => Get.back(result: true)),
       error: (msg) => errorDialog(content: msg),
     );
   }
}
