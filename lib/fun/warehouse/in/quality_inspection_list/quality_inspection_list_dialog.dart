import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/stuff_quality_inspection_info.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/click_debounce.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';

void qualityInspectionListLocationDialog({
  required Function(String) success,
}) {
  final debouncer = ClickDebouncer();
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
      child: AlertDialog(
        title: Text('quality_inspection_storage_location'.tr),
        content: SizedBox(
          width: 300,
          height: 80,
          child: LinkOptionsPicker(pickerController: storeWarehouse),
        ),
        contentPadding: const EdgeInsets.only(left: 10, right: 10),
        actionsPadding: const EdgeInsets.only(right: 10, bottom: 10),
        actions: [
          TextButton(
            onPressed: () => debouncer.run(() {
              if (storeWarehouse.getPickItem1().pickerId().isEmpty ||
                  storeWarehouse.getPickItem2().pickerId().isEmpty) {
                showSnackBar(
                    message: 'quality_inspection_store_location_empty'.tr);
                return;
              }
              Get.back();
              success.call(storeWarehouse.getPickItem2().pickerId());
            }),
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

void qualityInspectionListStoreDialog({
  required Function(String, String) success,
}) {
  final debouncer = ClickDebouncer();
  //过账日期
  var postAccountDate = DatePickerController(
    PickerType.startDate,
    buttonName: 'quality_inspection_date'.tr,
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
      child: AlertDialog(
        title: Text('quality_inspection_store'.tr),
        content: SizedBox(
          width: 300,
          height: 130,
          child: Column(
            children: [
              DatePicker(pickerController: postAccountDate),
              LinkOptionsPicker(pickerController: storeWarehouse)
            ],
          ),
        ),
        contentPadding: const EdgeInsets.only(left: 10, right: 10),
        actionsPadding: const EdgeInsets.only(right: 10, bottom: 10),
        actions: [
          TextButton(
            onPressed: () => debouncer.run(() {
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
              success.call(postAccountDate.getDateFormatSapYMD(),
                  storeWarehouse.getPickItem2().pickerId());
            }),
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

void showColor(List<StuffColorSeparationList> colorList) {
  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text('quality_inspection_color_message'.tr),
        content: SizedBox(
          width: 300,
          height: 300,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  ExpandedFrameText(
                    text: 'quality_inspection_color_title'.tr,
                    textColor: Colors.white,
                    backgroundColor: Colors.blueAccent,
                  ),
                  ExpandedFrameText(
                    text: 'quality_inspection_quality_title'.tr,
                    textColor: Colors.white,
                    backgroundColor: Colors.blueAccent,
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: colorList.length,
                  itemBuilder: (c, i) => Row(
                    children: [
                      ExpandedFrameText(
                        text: colorList[i].batch ?? '',
                        backgroundColor: Colors.greenAccent.shade100,
                      ),
                      ExpandedFrameText(
                        text: colorList[i]
                            .colorSeparationQuantity!
                            .toDoubleTry()
                            .toShowString(),
                        backgroundColor: Colors.greenAccent.shade100,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        contentPadding: const EdgeInsets.only(left: 10, right: 10),
        actionsPadding: const EdgeInsets.only(right: 10, bottom: 10),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('dialog_default_confirm'.tr),
          ),
        ],
      ),
    ),
  );
}

// 输入数量
void showInputDialog({
  required double allQty,
  required Function(double) callback,
}) {
  final debouncer = ClickDebouncer();
  var qty = 0.0;
  Get.dialog(
    PopScope(
      //拦截返回键
      canPop: false,
      child: AlertDialog(
        title: Text('quality_inspection_input_qty'.tr,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
        content: NumberDecimalEditText(
          hint: 'production_dispatch_dialog_input_dispatch_qty'.tr,
          max: allQty,
          initQty: allQty,
          hasFocus: true,
          onChanged: (v) => qty = v,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => debouncer.run(() {
              Get.back();
              callback.call(qty);
            }),
            child: Text('dialog_default_confirm'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text(
              'dialog_default_cancel'.tr,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    ),
    barrierDismissible: false, //拦截dialog外部点击
  );
}
