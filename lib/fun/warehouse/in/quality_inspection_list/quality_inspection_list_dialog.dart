import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/stuff_quality_inspection_info.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';

qualityInspectionListLocationDialog({
  required Function(String) success,
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
            onPressed: () {
              if (storeWarehouse.getPickItem1().pickerId().isEmpty ||
                  storeWarehouse.getPickItem2().pickerId().isEmpty) {
                showSnackBar(
                    message: 'quality_inspection_store_location_empty'.tr);
                return;
              }
              Get.back();
              success.call(storeWarehouse.getPickItem2().pickerId());
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

qualityInspectionListStoreDialog({
  required Function(String, String) success,
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
              success.call(postAccountDate.getDateFormatSapYMD(),
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
  );
}

showColor(List<StuffColorSeparationList> colorList) {
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
                  expandedFrameText(
                    text: '色系',
                    textColor: Colors.white,
                    backgroundColor: Colors.blueAccent,
                  ),
                  expandedFrameText(
                    text: '数量',
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
                      expandedFrameText(
                        text: colorList[i].batch ?? '',
                        backgroundColor: Colors.greenAccent.shade100,
                      ),
                      expandedFrameText(
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
showInputDialog({
  required double allQty,
  required Function(double) callback,
}) {
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
            onPressed: () {
              Get.back();
              callback.call(qty);
            },
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
