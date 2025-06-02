import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/signature_page.dart';
import 'package:jd_flutter/widget/worker_check_widget.dart';

const String checkPickerAndWarehouseDialogNumber = 'CHECK_PICKER_AND_WAREHOUSE_DIALOG_NUMBER';
checkPickerAndWarehouseDialog({
  required Function(
    String pickerNumber,
    ByteData pickerSignature,
    String userNumber,
    ByteData userSignature,
    String warehouse,
  ) pickerCheck,
}) {
  String saveNumber = spGet(checkPickerAndWarehouseDialogNumber) ?? '';
  var avatar = ''.obs;
  WorkerInfo? picker;
  var fwController = LinkOptionsPickerController(
    PickerType.sapFactoryWarehouse,
    saveKey:
        '${RouteConfig.sapRelocationPicking.name}${PickerType.sapFactoryWarehouse}',
  );
  Get.dialog(
    PopScope(
      canPop: false,
      child: Obx(
        () => AlertDialog(
          title: Text('sap_relocation_pick_picker_verify'.tr),
          content: SizedBox(
            width: 300,
            height: 300,
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
                  hint: 'sap_relocation_pick_picker_number'.tr,
                  onChanged: (w) {
                    picker = w;
                    avatar.value = w?.picUrl ?? '';
                  },
                ),
                LinkOptionsPicker(pickerController: fwController),
              ],
            ),
          ),
          contentPadding: const EdgeInsets.only(left: 10, right: 10),
          actionsPadding: const EdgeInsets.only(right: 10, bottom: 10),
          actions: [
            TextButton(
              onPressed: () {
                if (picker != null) {
                  spSave(checkPickerAndWarehouseDialogNumber, picker!.empCode ?? '');
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
                                    fwController.getPickItem2().pickerId(),
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
