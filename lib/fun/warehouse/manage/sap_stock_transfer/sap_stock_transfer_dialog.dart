import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';

inputLocationDialog({
  required TextEditingController controller,
  required Function() location,
}) {
  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        title: const Text('空托盘库位登记'),
        content: SizedBox(
          width: 300,
          child: EditText(
            hint: '请扫描或填写库位号',
            controller: controller,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if(controller.text.isEmpty){
                showSnackBar(title: '错误', message: '请扫描或填写库位号');
                return;
              }

              Get.back();
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
      ),
    ),
  );
}