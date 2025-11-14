import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_carton_label_binding_info.dart';
import 'package:jd_flutter/fun/warehouse/manage/sap_carton_label_binding/sap_carton_label_binding_state.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';

void modifyBoxInfo({
  required ScanLabelOperationType operationType,
  required SapLabelBindingInfo? targetBoxLabel,
  required Function(
    double long,
    double width,
    double height,
    double outWeight,
  ) modify,
}) {
  double long = targetBoxLabel?.long ?? 0;
  double width = targetBoxLabel?.width ?? 0;
  double height = targetBoxLabel?.height ?? 0;
  double outWeight = targetBoxLabel?.outWeight ?? 0;
  var title = '';
  if (operationType == ScanLabelOperationType.create) {
    title = 'carton_label_binding_label_binding_new_piece_tips'.tr;
  }
  if (operationType == ScanLabelOperationType.binding) {
    title = 'carton_label_binding_label_binding_tips'.trArgs([targetBoxLabel!.pieceNo??'']);
  }
  if (operationType == ScanLabelOperationType.unbind) {
    title = 'carton_label_binding_label_unbind_tips'.trArgs([targetBoxLabel!.pieceNo??'']);
  }
  if (operationType == ScanLabelOperationType.transfer) {
    title = 'carton_label_binding_label_transfer_tips'.trArgs([targetBoxLabel!.pieceNo??'']);
  }

  Get.dialog(
    PopScope(
      canPop: true,
      child: StatefulBuilder(builder: (context, dialogSetState) {
        return AlertDialog(
          title: Text(getOperationTypeText(operationType)),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: NumberDecimalEditText(
                        hint: 'carton_label_binding_long'.tr,
                        initQty: long,
                        onChanged: (v) =>long=v,
                      ),
                    ),
                    Expanded(
                      child: NumberDecimalEditText(
                        hint: 'carton_label_binding_width'.tr,
                        initQty: width,
                        onChanged: (v) =>width=v,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: NumberDecimalEditText(
                        hint: 'carton_label_binding_height'.tr,
                        initQty: height,
                        onChanged: (v) =>height=v,
                      ),
                    ),
                    Expanded(
                      child: NumberDecimalEditText(
                        hint: 'carton_label_binding_out_weight'.tr,
                        initQty: outWeight,
                        onChanged: (v) =>outWeight=v,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (targetBoxLabel != null &&
                    targetBoxLabel.isTradeFactory == 'X') {
                  if (long <= 0 ||
                      width <= 0 ||
                      height <= 0 ||
                      outWeight <= 0) {
                    errorDialog(content: 'carton_label_binding_data_not_input_tips'.tr);
                  } else {
                    Get.back();
                    modify.call(long, width, height, outWeight);
                  }
                } else {
                  Get.back();
                  modify.call(long, width, height, outWeight);
                }
              },
              child: Text('dialog_default_confirm'.tr),
            ),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'dialog_default_cancel'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        );
      }),
    ),
  );
}
