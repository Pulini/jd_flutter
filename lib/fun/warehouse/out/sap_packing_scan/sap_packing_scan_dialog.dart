import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';

menuDialog({
  required Function() viewPiece,
  required Function() sealingCabinet,
  required Function() reverse,
}) {
  Get.dialog(
    PopScope(
        canPop: true,
        child: AlertDialog(
          contentPadding: const EdgeInsets.only(left: 10, right: 10),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),
                CombinationButton(
                  text: '查看扫码件号',
                  click: viewPiece,
                ),
                const SizedBox(height: 10),
                CombinationButton(
                  text: '封柜',
                  click: sealingCabinet,
                ),
                const SizedBox(height: 10),
                CombinationButton(
                  text: '冲销',
                  click: reverse,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'dialog_default_cancel'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        )),
  );
}
