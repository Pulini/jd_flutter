import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_scan_info.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'sap_packing_scan_reverse_state.dart';

class SapPackingScanReverseLogic extends GetxController {
  final SapPackingScanReverseState state = SapPackingScanReverseState();

  void reverseScan(String code) {
    state.getReverseLabelInfo(
      code: code,
      success: (label) {
        if (state.reverseLabelList.isNotEmpty) {
          if (state.reverseLabelList[0].deliveryOrderNo ==
              label.deliveryOrderNo) {
            if (state.reverseLabelList
                .none((v) => v.pieceId == label.pieceId)) {
              state.reverseLabelList.add(label);
            } else {
              errorDialog(content: 'sap_packing_scan_label_exists'.tr);
            }
          } else {
            errorDialog(content: 'sap_packing_scan_diff_delivery_not_allowed'.tr);
          }
        } else {
          state.reverseLabelList.add(label);
        }
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  void deleteReverseLabel(SapPackingScanReverseLabelInfo data) {
    state.reverseLabelList.remove(data);
  }

  void reverseLabel() {
    state.reverseLabel(
      success: (msg) => successDialog(content: msg),
      error: (msg) => errorDialog(content: msg),
    );
  }

}
