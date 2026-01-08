import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_wms_reprint_label_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/preview_label_list_widget.dart';
import 'package:jd_flutter/widget/preview_label_widget.dart';
import 'package:jd_flutter/widget/tsc_label_templates/fixed_label_75w45h.dart';

import 'sap_wms_split_label_state.dart';

class SapWmsSplitLabelLogic extends GetxController {
  final SapWmsSplitLabelState state = SapWmsSplitLabelState();

  void scanCode(String code) {
    state.getLabels(
      labelNumber: code,
      error: (msg) => errorDialog(content: msg),
    );
  }

  void split({
    required double splitQty,
    required Function() input,
    required Function() finish,
  }) {
    if (splitQty == 0) {
      errorDialog(
          content: 'sap_wms_split_label_input_split_qty_tips'.tr, back: input);
      return;
    }
    if ((state.originalLabel?.quantity ?? 0) == splitQty) {
      errorDialog(content: 'sap_wms_split_label_split_qty_error_tops'.tr);
      return;
    }
    state.originalLabel?.quantity = state.originalLabel?.quantity.sub(splitQty);
    state.labelList.add(ReprintLabelInfo(
      isNewLabel: 'X',
      labelNumber: state.originalLabel?.labelNumber,
      materialCode: state.originalLabel?.materialCode,
      materialName: state.originalLabel?.materialName,
      typeBody: state.originalLabel?.typeBody,
      size: state.originalLabel?.size,
      quantity: splitQty,
      unit: state.originalLabel?.unit,
    ));
    finish.call();
  }

  void deleteLabel() {
    var removeQty = state.labelList
        .where((v) => v.isNewLabel == 'X' && v.select)
        .map((v) => v.quantity ?? 0)
        .reduce((a, b) => a.add(b));
    state.labelList.removeWhere((v) => v.isNewLabel == 'X' && v.select);
    state.originalLabel?.quantity =
        state.originalLabel?.quantity.add(removeQty);
  }

  void submitSplit() {
    state.submitSplit(
      success: (msg) => successDialog(content: msg),
      error: (msg) => errorDialog(content: msg),
    );
  }

  void reprintLabel({required String factory, required String warehouse}) {
    if (factory !=  ('2000' )&&
        warehouse != '1200' &&
        warehouse != '1101' &&
        warehouse != '1102' &&
        warehouse != '1105') {
      msgDialog(
          content:
              'sap_wms_split_label_select_warehouse_before_print_label_tips'
                  .tr);
      return;
    }
    var list = <Widget>[];
    state.labelList.where((v) => v.select).forEach((v) {
      if (warehouse == '1101') {
        list.add(sapWmsSplitLabel1101WarehouseLabel(
          labelNumber: v.labelNumber ?? '',
          factory: v.factory ?? '',
          process: v.process ?? '',
          materialName: v.materialName ?? '',
          dispatchNumber: v.dispatchNumber ?? '',
          decrementTableNumber: v.decrementTableNumber ?? '',
          numPage: v.numPage ?? '',
          dispatchDate: v.dispatchDate ?? '',
          dayOrNightShift: v.dayOrNightShift ?? '',
          machineNumber: v.machineNumber ?? '',
          size: v.size ?? '',
          boxCapacity: v.boxCapacity ?? 0,
          unit: v.unit ?? '',
        ));
      } else if (warehouse == '1102' || warehouse == '1105') {
        list.add(sapWmsSplitLabel1102And1105WarehouseLabel(
          labelNumber: v.labelNumber ?? '',
          typeBody: v.typeBody ?? '',
          materialCode: v.materialCode ?? '',
          materialName: v.materialName ?? '',
          numPage: v.numPage ?? '',
          quantity: v.quantity ?? 0,
          unit: v.unit ?? '',
        ));
      } else if (warehouse == '1200') {
        list.add(sapWmsSplitLabel1200WarehouseLabel(
          labelNumber: v.labelNumber ?? '',
          typeBody: v.typeBody ?? '',
          instructionNo: v.instructionNo ?? '',
          materialCode: v.materialCode ?? '',
          materialName: v.materialName ?? '',
          grossWeight: 0,
          netWeight: 0,
          meas: '',
          quantity: v.quantity ?? 0,
          unit: v.unit ?? '',
          numPage: v.numPage ?? '',
          size: v.size ?? '',
        ));
      } else {
        list.add(sapWmsSplitLabelOtherWarehouseLabel(
          labelNumber: v.labelNumber ?? '',
          typeBody: v.typeBody ?? '',
          instructionNo: v.instructionNo ?? '',
          materialCode: v.materialCode ?? '',
          materialName: v.materialName ?? '',
          numPage: v.numPage ?? '',
          quantity: v.quantity ?? 0,
          unit: v.unit ?? '',
        ));
      }
    });
    if (list.isEmpty) {
      msgDialog(content: 'sap_wms_split_label_select_label_fo_print'.tr);
    } else {
      if (list.length > 1) {
        Get.to(() => PreviewLabelList(labelWidgets: list));
      } else {
        Get.to(() => PreviewLabel(labelWidget: list[0]));
      }
    }
  }
}
