import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/patrol_inspection_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';

changeLineDialog({required RxList<PatrolInspectionInfo> lines,required Function(int)change}) {
  var index = lines.indexWhere((v) => v.isSelected.value);
  var controllerLines = FixedExtentScrollController(initialItem: index);
  Get.dialog(
    PopScope(
      canPop: true,
      child: StatefulBuilder(builder: (context, dialogSetState) {
        return AlertDialog(
          title: Text('product_patrol_inspection_dialog_switching_lines'.tr),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                selectView(
                  list: lines,
                  controller: controllerLines,
                  errorMsg: '',
                  hint: 'product_patrol_inspection_dialog_select_unit'.tr,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                change.call(controllerLines.selectedItem);
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
modifyTagKeyDialog({required PatrolInspectionAbnormalItemInfo data}) {
  var controller=TextEditingController(text: data.tag.value);
  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text('product_patrol_inspection_dialog_modify_label_no'.tr),
        content: SizedBox(
          width: 200,
          child: EditText(
            hint:'product_patrol_inspection_dialog_label_no'.tr,
            controller: controller,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (controller.text.isEmpty) {
                showSnackBar(
                  message:'product_patrol_inspection_dialog_input_key'.tr,
                  isWarning: true,
                );
              }else{
                data.tag.value=controller.text;
                spSave('PI-${data.abnormalItemId}-${userInfo?.number}', controller.text);
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
