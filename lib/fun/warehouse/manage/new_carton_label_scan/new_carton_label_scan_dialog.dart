import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';

void modifyOutBoxScannedDialog({
  required int scannedQty,
  required int max,
  required Function(int scannedQty) modify,
}) {
  var controller = TextEditingController(text: scannedQty.toString());
  Get.dialog(
    barrierDismissible: false,
    PopScope(
      canPop: false,
      child: AlertDialog(
          title: Text('carton_label_scan_modify_out_box_scanned'.tr),
          content: SizedBox(
            width: 300,
            child: NumberEditText(
              hint: 'min: $scannedQty max: $max',
              controller: controller,
              onChanged: (s) {
                 if (s.toIntTry() > max) {
                  controller.text = max.toString();
                }
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
               var qty=controller.text.toIntTry();
               if(qty<scannedQty){
                 controller.text=scannedQty.toString();
               }else{
                 Get.back();
                 modify.call(controller.text.toIntTry());
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
          ]),
    ),
  );
}
