import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_carton_label_binding_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/preview_web_label_widget.dart';

import 'sap_inner_box_label_split_state.dart';

class SapInnerBoxLabelSplitLogic extends GetxController {
  final SapInnerBoxLabelSplitState state = SapInnerBoxLabelSplitState();

  void scanCode({required String code, required Function() refresh}) {
    state.getLabelPrintInfo(
      code: code,
      error: (msg) => errorDialog(content: msg),
      refresh: refresh,
    );
  }

  void preSplit() {
    hidKeyboard();
    var splitList =
        (state.originalLabel!.subLabel!).where((v) => v.splitQty.value > 0);
    state.splitLabelList.add(SapLabelSplitInfo(
      long: (state.originalLabel!.long ?? 0).obs,
      width: (state.originalLabel!.width ?? 0).obs,
      height: (state.originalLabel!.height ?? 0).obs,
      materials: [
        for (var v in splitList)
          SapLabelSplitMaterialInfo(
            materialNumber: v.materialNumber ?? '',
            materialName: v.materialName ?? '',
            qty: v.splitQty.value,
            unit: v.unit ?? '',
          )
      ],
    ));
    for (var v in splitList) {
      v.canSplitQty.value = v.canSplitQty.value.sub(v.splitQty.value);
      v.splitQty.value = 0;
    }
  }

  void deletePreSplit(SapLabelSplitInfo newLabel) {
    for (var v in newLabel.materials) {
      var originalMaterial = state.originalLabel!.subLabel!
          .firstWhere((v2) => v2.materialNumber == v.materialNumber);
      originalMaterial.canSplitQty.value =
          originalMaterial.canSplitQty.value.add(v.qty);
    }
    state.splitLabelList.remove(newLabel);
  }

  bool canSubmit() {
    if (state.splitLabelList.isEmpty) {
      return false;
    }
    if (state.originalLabel!.isTradeFactory) {
      return state.originalLabel!.canSubmit() &&
          state.splitLabelList.every((v) => v.hasSpecificationsData());
    }
    return true;
  }

  void submitPreSplit() {
    state.submitPreSplitLabel(
      error: (msg) => errorDialog(content: msg),
    );
  }

  bool isMyanmarLabel() => state.newLabelList
      .where((v) => v.isSelected.value)
      .any((v) => v.factoryNo == '1098');

  void printLabel({bool? hasNotes}) {
    var selected = state.newLabelList.where((v) => v.isSelected.value).toList();
    if (selected.isNotEmpty) {
      Get.to(() => PreviewWebLabelList(
            labelCodes: selected
                .map((v) => {
                      'Note': hasNotes ?? false ? v.remarks ?? '' : '',
                      'BQID': v.labelID ?? '',
                      'ZBQLX': v.labelType ?? '',
                    })
                .toList(),
          ));
    } else {
      errorDialog(content: 'sap_inner_box_label_split_no_printable_label'.tr);
    }
  }

}
