import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/quality_inspection_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';

void modifyTagKeyDialog({required QualityInspectionAbnormalItemInfo data}) {
  var controller = TextEditingController(text: data.tag.value);
  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text('product_quality_inspection_dialog_modify_label_no'.tr),
        content: SizedBox(
          width: 200,
          child: EditText(
            hint: 'product_quality_inspection_dialog_label_no'.tr,
            controller: controller,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (controller.text.isEmpty) {
                showSnackBar(
                  message: 'product_quality_inspection_dialog_input_key'.tr,
                  isWarning: true,
                );
              } else {
                data.tag.value = controller.text;
                spSave('QI-${data.abnormalItemId}-${userInfo?.number}',
                    controller.text);
                Get.back();
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
      ),
    ),
  );
}
