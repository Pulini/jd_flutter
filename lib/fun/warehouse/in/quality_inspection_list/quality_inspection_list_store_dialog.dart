import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';


qualityInspectionListStoreDialog({
  Function(String, String)? success,
}) {
  //过账日期
  var postAccountDate = DatePickerController(
    PickerType.startDate,
    buttonName: 'quality_inspection_date'.tr,
    saveKey:
        '${RouteConfig.qualityInspectionList.name}${PickerType.startDate}-store-date',
  );

  var storeWarehouse = LinkOptionsPickerController(
    hasAll: true,
    PickerType.sapFactoryWarehouse,
    saveKey:
        '${RouteConfig.waitPickingMaterial.name}${PickerType.sapFactoryWarehouse}-store',
    buttonName: 'quality_inspection_store_location'.tr,
  );

  Get.dialog(
    PopScope(
      canPop: false,
      child: Obx(
        () => AlertDialog(
          title: Text('quality_inspection_store'.tr),
          content: SizedBox(
            width: 300,
            height: 130,
            child: Column(
              children: [
                DatePicker(pickerController: postAccountDate),
                LinkOptionsPicker(
                  pickerController: storeWarehouse,
                )
              ],
            ),
          ),
          contentPadding: const EdgeInsets.only(left: 10, right: 10),
          actionsPadding: const EdgeInsets.only(right: 10, bottom: 10),
          actions: [
            TextButton(
              onPressed: () {
                if (postAccountDate.getDateFormatSapYMD().isEmpty) {
                  showSnackBar(message: 'quality_inspection_empty'.tr);
                  return;
                }
                if (storeWarehouse.getPickItem1().pickerId().isEmpty ||
                    storeWarehouse.getPickItem2().pickerId().isEmpty) {
                  showSnackBar(message: 'quality_inspection_store_empty'.tr);
                  return;
                }
                Get.back();
                success!.call(postAccountDate.getDateFormatSapYMD(),
                    storeWarehouse.getPickItem2().pickerId());
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
    ),
  );
}
