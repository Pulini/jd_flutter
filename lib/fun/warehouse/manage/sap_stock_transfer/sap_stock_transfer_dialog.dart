import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';

void inputLocationDialog({
  required TextEditingController controller,
  required Function() location,
}) {
  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text(
          'sap_stock_transfer_scan_or_select_goods_fo_transfer_tips'.tr,
        ),
        content: SizedBox(
          width: 300,
          child: EditText(
            hint:
                'sap_stock_transfer_dialog_empty_pallet_storage_location_registration'
                    .tr,
            controller: controller,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (controller.text.isEmpty) {
                showSnackBar(
                  message:
                      'sap_stock_transfer_dialog_scan_or_enter_storage_location_tips'
                          .tr,
                  isWarning: true,
                );
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
