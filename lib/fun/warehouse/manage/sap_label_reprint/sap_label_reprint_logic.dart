import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/preview_web_label_widget.dart';

import 'sap_label_reprint_state.dart';

class SapLabelReprintLogic extends GetxController {
  final SapLabelReprintState state = SapLabelReprintState();

  void scanLabel(String code) {
    state.getLabelList(
      code: code,
      success: (label) {
        for (var newLabel in label) {
          if (state.labelList.none((v) => v.labelID == newLabel.labelID)) {
            state.labelList.add(newLabel);
          }
        }
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  void searchPiece(String piece) {
    if (piece.isEmpty) return;
    state.getLabelList(
      piece: piece,
      success: (label) {
        for (var newLabel in label) {
          if (state.labelList.none((v) => v.labelID == newLabel.labelID)) {
            state.labelList.add(newLabel);
          }
        }
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  void printLabel() {
    var selected = state.labelList.where((v) => v.isSelected.value).toList();
    if (selected.isNotEmpty) {
      Get.to(() => PreviewWebLabelList(
            labelCodes: selected.map((v) =>{
              'BQID':v.labelID ?? '',
              'ZBQLX':v.labelType ?? '',
            }).toList(),
          ));
    } else {
      errorDialog(content: 'sap_label_reprint_no_printable_label'.tr);
    }
  }

  bool isSelectedAll() =>
      state.labelList.isNotEmpty &&
      state.labelList.every((v) => v.isSelected.value);

  void cleanLabels() {
    askDialog(content: 'sap_label_reprint_clear_labels_confirm'.tr, confirm: () => state.labelList.clear());
  }

  void selectAll(bool isSelect) {
    for (var v in state.labelList) {
      v.isSelected.value = isSelect;
    }
  }
}
