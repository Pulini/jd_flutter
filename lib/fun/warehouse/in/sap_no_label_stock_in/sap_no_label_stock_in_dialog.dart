import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/signature_page.dart';
import 'package:jd_flutter/widget/worker_check_widget.dart';

const String checkStockInHandoverDialogNumber =
    'CHECK_STOCK_IN_HANDOVER_DIALOG_NUMBER';

modifyMaterialStockInQtyDialog({
  required double max,
  required double qty,
  required Function(double) callback,
}) {
  var controller = TextEditingController(
    text: qty.toShowString(),
  );
  controller.selection = TextSelection.fromPosition(
    TextPosition(offset: controller.text.length),
  );
  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text('sap_no_label_stock_in_dialog_modify_stock_in_qty'.tr),
        content: SizedBox(
          width: 300,
          child: NumberDecimalEditText(
            hint: 'sap_no_label_stock_in_dialog_report_qty'.tr,
            max: max,
            onChanged: (d) => qty = d,
            controller: controller,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              callback.call(controller.text.toDoubleTry());
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

checkStockInHandoverDialog({
  required Function(
    String leaderNumber,
    ByteData leaderSignature,
    String userNumber,
    ByteData userSignature,
    String postingDate,
  ) handoverCheck,
}) {
  var dpcDate = DatePickerController(PickerType.date,
      saveKey: '${RouteConfig.sapNoLabelStockIn.name}${PickerType.date}',
      buttonName: 'sap_no_label_stock_in_dialog_posting_date'.tr);
  String saveNumber = spGet(checkStockInHandoverDialogNumber) ?? '';
  var avatar = ''.obs;
  WorkerInfo? leader;
  Get.dialog(
    PopScope(
      canPop: false,
      child: Obx(() => AlertDialog(
            title: Text('sap_no_label_stock_in_dialog_leader_confirm'.tr),
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
                    hint: 'sap_no_label_stock_in_dialog_leader_number'.tr,
                    onChanged: (w) {
                      leader = w;
                      avatar.value = w?.picUrl ?? '';
                    },
                  ),
                  DatePicker(pickerController: dpcDate),
                ],
              ),
            ),
            contentPadding: const EdgeInsets.only(left: 30, right: 30),
            actionsPadding: const EdgeInsets.only(right: 10, bottom: 10),
            actions: [
              TextButton(
                onPressed: () {
                  if (leader != null) {
                    spSave(checkStockInHandoverDialogNumber,
                        leader!.empCode ?? '');
                    Get.to(() => SignaturePage(
                          name: leader?.empName ?? '',
                          callback: (leaderSignature) {
                            Get.to(() => SignaturePage(
                                  name: userInfo?.name ?? '',
                                  callback: (userSignature) {
                                    Get.back();
                                    handoverCheck.call(
                                      leader!.empCode ?? '',
                                      leaderSignature,
                                      userInfo?.number ?? '',
                                      userSignature,
                                      dpcDate.getDateFormatSapYMD(),
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
          )),
    ),
  );
}
