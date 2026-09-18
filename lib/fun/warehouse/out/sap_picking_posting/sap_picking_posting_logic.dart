import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_posting_info.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'sap_picking_posting_state.dart';

class SapPickingPostingLogic extends GetxController {
  final SapPickingPostingState state = SapPickingPostingState();

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

  void getNewOrderNumber() {
    state.getNewOrderNumber(error: (msg) => errorDialog(content: msg));
  }

  void getMaterialDetail({
    required String code,
    Function()? semiFinishedProduct,
    Function()? finishedProduct,
  }) {
    if (code.isEmpty) {
      errorDialog(content: "sap_picking_posting_scan_semi_barcode".tr);
      return;
    }
    state.getPickingMaterialDetail(
      code: code,
      success: (data) => addLabel(
          data: data,
          semiFinishedProduct: semiFinishedProduct,
          finishedProduct: finishedProduct),
      error: (msg) => errorDialog(content: msg),
    );
  }

  void addLabel({
    required SapPickingPostingInfo data,
    Function()? semiFinishedProduct,
    Function()? finishedProduct,
  }) {
    if (data.rowType == 'I') {
      if (state.semiFinishedProductList.any((v) => v.isExists(data))) {
        errorDialog(content: 'sap_picking_posting_semi_label_scanned'.tr);
        return;
      }
      try {
        state.semiFinishedProductList
            .firstWhere(
                (v) => v.dataList.first.materialCode == data.materialCode)
            .dataList
            .add(data);
      } on StateError catch (_) {
        state.semiFinishedProductList
            .add(SapPickingPostingGroup()..dataList.add(data));
      }
      semiFinishedProduct?.call();
    } else if (data.rowType == 'H') {
      if (state.finishedProductList.isNotEmpty) {
        if (state.finishedProductList.any((v) => v.label == data.label)) {
          errorDialog(content: 'sap_picking_posting_finished_label_scanned'.tr);
          return;
        }
        if (state.finishedProductList.first.materialCode != data.materialCode) {
          errorDialog(content: 'sap_picking_posting_diff_material_not_allowed'.tr);
          return;
        }
        if (state.finishedProductList.first.salesOrder != data.salesOrder) {
          errorDialog(content: 'sap_picking_posting_diff_order_not_allowed'.tr);
          return;
        }
        state.finishedProductList.add(data);
        finishedProduct?.call();
      } else {
        state.finishedProductList.add(data);
        finishedProduct?.call();
      }
    } else {
      errorDialog(
          content:
              'sap_picking_posting_type_error'.trArgs(['(${data.materialCode})${data.materialName}', data.rowType.toString()]));
    }
  }

  void clearSemiFinishedProduct() {
    state.semiFinishedProductList.clear();
  }

  void clearFinishedProduct() {
    state.finishedProductList.clear();
  }

  void deleteSemiFinishedProductItem(SapPickingPostingGroup data) {
    state.semiFinishedProductList.remove(data);
  }

  void submitPickingLabel(bool isPosting) {
    state.submitPickingLabel(
      isPosting: isPosting,
      success: (msg) {
        clearSemiFinishedProduct();
        clearFinishedProduct();
        successDialog(content: msg, back: () => getNewOrderNumber());
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  void refreshLabels(String orderNumber, List<SapPickingPostingInfo> labels) {
    state.order.value = orderNumber;
    for (var v in labels) {
      addLabel(data: v);
    }
  }
}
