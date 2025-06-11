import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/sap_label_binding_info.dart';
import 'package:jd_flutter/fun/warehouse/manage/sap_label_binding/sap_label_binding_state.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';

modifyBoxInfo({
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
    title = '确定要将所有标签合并绑定到全新的外箱标上吗?';
  }
  if (operationType == ScanLabelOperationType.binding) {
    title = '确定要将所有标签绑定到件号<${targetBoxLabel!.pieceNo}>的外箱标上吗？';
  }
  if (operationType == ScanLabelOperationType.unbind) {
    title = '确定要将件号<${targetBoxLabel!.pieceNo}>中的所有标签解绑吗？';
  }
  if (operationType == ScanLabelOperationType.transfer) {
    title = '确定要将所有标签转移到件号<${targetBoxLabel!.pieceNo}>的外箱标上吗？';
  }

  Get.dialog(
    PopScope(
      canPop: true,
      child: StatefulBuilder(builder: (context, dialogSetState) {
        return AlertDialog(
          title: Text(operationType.text),
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
                        hint: '长',
                        initQty: long,
                        onChanged: (v) {},
                      ),
                    ),
                    Expanded(
                      child: NumberDecimalEditText(
                        hint: '宽',
                        initQty: width,
                        onChanged: (v) {},
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: NumberDecimalEditText(
                        hint: '高',
                        initQty: height,
                        onChanged: (v) {},
                      ),
                    ),
                    Expanded(
                      child: NumberDecimalEditText(
                        hint: '外包装重量',
                        initQty: outWeight,
                        onChanged: (v) {},
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
                    errorDialog(content: '贸易工厂标签必须填写长宽高和外包装重量!');
                    return;
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
