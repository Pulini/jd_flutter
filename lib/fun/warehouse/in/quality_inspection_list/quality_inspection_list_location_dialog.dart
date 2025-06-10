import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/signature_page.dart';
import 'package:jd_flutter/widget/worker_check_widget.dart';

qualityInspectionListLocationDialog({
  Function(String)? success,
}) {

  var storeWarehouse = LinkOptionsPickerController(
    hasAll: true,
    PickerType.sapFactoryWarehouse,
    saveKey:
        '${RouteConfig.waitPickingMaterial.name}${PickerType.sapFactoryWarehouse}-location',
    buttonName: 'quality_inspection_store_location'.tr,
  );

  Get.dialog(
    PopScope(
      canPop: false,
      child: Obx(
        () => AlertDialog(
          title: Text('quality_inspection_storage_location'.tr),
          content: SizedBox(
            width: 300,
            height: 80,
            child: Column(
              children: [
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
                if (storeWarehouse.getOptionsPicker1().pickerId().isEmpty ||
                    storeWarehouse.getOptionsPicker2().pickerId().isEmpty) {
                  showSnackBar(message: 'quality_inspection_store_location_empty'.tr);
                  return;
                }
                Get.back();
                success!.call(storeWarehouse.getOptionsPicker2().pickerId());
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
