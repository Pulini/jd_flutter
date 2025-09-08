import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/signature_page.dart';
import 'package:jd_flutter/widget/worker_check_widget.dart';


modifyPickingQty({
  required double quantity,
  required double coefficient,
  required String basicUnit,
  required String commonUnit,
  required Function(double) callback,
}) {
  double ratio = coefficient <= 0 ? 2 : coefficient;
  var baseUnitController = TextEditingController(
    text: quantity.toShowString(),
  );

  var commonUnitController = TextEditingController(
    text: quantity.div(ratio).toShowString(),
  );

  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text('sap_production_picking_dialog_modify_pick_qty'.tr),
        content: SizedBox(
          width: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Text('sap_production_picking_dialog_pick'.tr),
                    Expanded(
                      child: TextField(
                        focusNode: FocusNode()..requestFocus(),
                        style: const TextStyle(color: Colors.blue),
                        textAlign: TextAlign.center,
                        controller: baseUnitController,
                        onChanged: (v) => commonUnitController.text =
                            v.toDoubleTry().div(ratio).toShowString(),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                        ],
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
                          filled: true,
                          fillColor: Colors.transparent,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () {
                        baseUnitController.clear();
                      },
                    ),
                    Text(basicUnit),
                  ],
                ),
              ),
              if (commonUnit.isNotEmpty && commonUnit != basicUnit)
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Text('sap_production_picking_dialog_pick'.tr),
                      Expanded(
                        child: TextField(
                          style: const TextStyle(color: Colors.blue),
                          textAlign: TextAlign.center,
                          controller: commonUnitController,
                          onChanged: (v) => baseUnitController.text =
                              v.toDoubleTry().mul(ratio).toShowString(),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                          ],
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 15),
                            filled: true,
                            fillColor: Colors.transparent,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                            ),
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () {
                          commonUnitController.clear();
                        },
                      ),
                      Text(commonUnit),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              callback.call(baseUnitController.text.toDoubleTry());
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

const String checkPickerDialogNumber = 'CHECK_PICKER_DIALOG_NUMBER';

checkPickerDialog({
  required Function(
    String pickerNumber,
    ByteData pickerSignature,
    String userNumber,
    ByteData userSignature,
  ) pickerCheck,
}) {
  String saveNumber = spGet(checkPickerDialogNumber) ?? '';
  var avatar = ''.obs;
  WorkerInfo? picker;
  Get.dialog(
    PopScope(
      canPop: false,
      child: Obx(
        () => AlertDialog(
          title: Text('sap_production_picking_dialog_picker_verify'.tr),
          content: SizedBox(
            width: 300,
            height: 240,
            child: ListView(
              children: [
                Center(
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: avatar.isNotEmpty
                          ? Image.network(avatar.value, fit: BoxFit.fill)
                          : Icon(
                        Icons.account_circle,
                        size: 150,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
                WorkerCheck(
                  init: saveNumber,
                  hint: 'sap_production_picking_dialog_picker_number'.tr,
                  onChanged: (w) {
                    picker = w;
                    avatar.value = w?.picUrl ?? '';
                  },
                ),
              ],
            ),
          ),
          contentPadding: const EdgeInsets.only(left: 30, right: 30),
          actionsPadding: const EdgeInsets.only(right: 10, bottom: 10),
          actions: [
            TextButton(
              onPressed: () {
                if (picker != null) {
                  spSave(checkPickerDialogNumber, picker!.empCode ?? '');
                  Get.to(() => SignaturePage(
                        name: picker?.empName ?? '',
                        callback: (pickerSignature) {
                          Get.to(() => SignaturePage(
                                name: userInfo?.name ?? '',
                                callback: (userSignature) {
                                  Get.back();
                                  pickerCheck.call(
                                    picker!.empCode ?? '',
                                    pickerSignature,
                                    userInfo?.number ?? '',
                                    userSignature,
                                  );
                                },
                              ));
                        },
                      ));
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
    ),
  );
}
