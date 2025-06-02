import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/quality_inspection_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';

modifyTagKeyDialog({required QualityInspectionAbnormalItemInfo data}) {
  var controller=TextEditingController(text: data.tag.value);
  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text('修改标签号'),
        content: SizedBox(
          width: 200,
          child: EditText(
            hint:'标签号',
            controller: controller,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (controller.text.isEmpty) {
                showSnackBar(
                  message:'请输入键值',
                  isWarning: true,
                );
              }else{
                data.tag.value=controller.text;
                spSave('QI-${data.abnormalItemId}-${userInfo?.number}', controller.text);
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
