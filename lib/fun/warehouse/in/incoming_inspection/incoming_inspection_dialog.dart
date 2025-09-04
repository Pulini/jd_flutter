import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/incoming_inspection_info.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/worker_check_widget.dart';

modifySubItemMaterialDialog({
  required InspectionDeliveryInfo item,
  required Function() modify,
}) {
  var qty = item.qty ?? 0;
  var numberPage = item.numPage ?? 1;
  var unit = item.unitName ?? 'incoming_inspection_dialog_metre'.tr;
  Get.dialog(
    PopScope(
      canPop: false,
      child: StatefulBuilder(builder: (context, dialogSetState) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(7),
          title: Text('incoming_inspection_dialog_modify_material'.tr),
          content: SizedBox(
            width: getScreenSize().width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    EditText(
                      hint: 'incoming_inspection_dialog_quantity'.tr,
                      initStr: qty.toShowString(),
                      onChanged: (v) => qty = v.toDoubleTry(),
                    ),
                    EditText(
                      hint: 'incoming_inspection_dialog_total_pieces'.tr,
                      initStr: numberPage.toString(),
                      onChanged: (v) => numberPage = v.toIntTry(),
                    ),
                    EditText(
                      hint: 'incoming_inspection_dialog_unit'.tr,
                      initStr: unit,
                      onChanged: (v) => unit = v,
                    )
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (qty <= 0) {
                  showSnackBar(
                    message:
                        'incoming_inspection_dialog_input_quantity_tips'.tr,
                    isWarning: true,
                  );
                  return;
                }
                if (numberPage <= 0) {
                  showSnackBar(
                    message: 'incoming_inspection_dialog_input_pieces_tips'.tr,
                    isWarning: true,
                  );
                  return;
                }
                if (numberPage <= 0) {
                  showSnackBar(
                    message: 'incoming_inspection_dialog_input_unit_tips'.tr,
                    isWarning: true,
                  );
                  return;
                }
                item.qty = qty;
                item.unitName = unit;
                item.numPage = numberPage;
                Get.back();
                modify.call();
              },
              child: Text('incoming_inspection_dialog_modify'.tr),
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

addOrModifyMaterialDialog({
  Function(InspectionDeliveryInfo)? add,
  InspectionDeliveryInfo? item,
  Function()? modify,
}) {
  var materialList = <String>[
    '帆布',
    '柔软布',
    '针织布',
    '加密布',
    '热熔胶',
    '乳胶',
    '热熔胶定型布',
    '仿猪革',
    '透气革',
    '鞋里革',
    'EVA',
    '海绵',
    '泡棉',
    '热胶',
    '全棉定型布',
    '起毛布',
    '天鹅绒',
    '里子布'
  ];
  var orderNumber = '';
  var numberPage = 1;
  var materielName = materialList[0];
  var qty = 1.0;
  var unit = 'incoming_inspection_dialog_metre'.tr;
  if (item != null) {
    orderNumber = item.billNo ?? '';
    numberPage = item.numPage ?? 0;
    materielName = item.materialName ?? '';
    qty = item.qty ?? 0;
    unit = item.unitName ?? '';
  }
  Get.dialog(
    PopScope(
      canPop: false,
      child: StatefulBuilder(builder: (context, dialogSetState) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(7),
          title: Text('incoming_inspection_dialog_add_material'.tr),
          content: SizedBox(
            width: getScreenSize().width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EditText(
                  hint: 'incoming_inspection_dialog_order_no'.tr,
                  initStr: orderNumber,
                  onChanged: (v) => orderNumber = v,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: selectView(
                        list: materialList,
                        select: (i) => dialogSetState(() {
                          materielName = materialList[i];
                        }),
                        hint: 'incoming_inspection_dialog_select_material'.tr,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          EditText(
                            hint: 'incoming_inspection_dialog_quantity'.tr,
                            initStr: qty.toShowString(),
                            onChanged: (v) => qty = v.toDoubleTry(),
                          ),
                          EditText(
                            hint: 'incoming_inspection_dialog_total_pieces'.tr,
                            initStr: numberPage.toString(),
                            onChanged: (v) => numberPage = v.toIntTry(),
                          ),
                          EditText(
                            hint: 'incoming_inspection_dialog_unit'.tr,
                            initStr: unit,
                            onChanged: (v) => unit = v,
                          )
                        ],
                      ),
                    )
                  ],
                ),
                EditText(
                  hint: 'incoming_inspection_dialog_material_name'.tr,
                  initStr: materielName,
                  onChanged: (v) => materielName = v,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (orderNumber.trim().isEmpty) {
                  showSnackBar(
                    message:
                        'incoming_inspection_dialog_input_order_no_tips'.tr,
                    isWarning: true,
                  );
                  return;
                }
                if (qty <= 0) {
                  showSnackBar(
                    message:
                        'incoming_inspection_dialog_input_material_name_tips'
                            .tr,
                    isWarning: true,
                  );
                  return;
                }
                if (numberPage <= 0) {
                  showSnackBar(
                    message: 'incoming_inspection_dialog_input_pieces_tips'.tr,
                    isWarning: true,
                  );
                  return;
                }
                if (numberPage <= 0) {
                  showSnackBar(
                    message: 'incoming_inspection_dialog_input_unit_tips'.tr,
                    isWarning: true,
                  );
                  return;
                }
                if (materielName.trim().isEmpty) {
                  showSnackBar(
                    message:
                        'incoming_inspection_dialog_input_material_name_tips'
                            .tr,
                    isWarning: true,
                  );
                  return;
                }
                Get.back();
                if (item == null) {
                  add?.call(InspectionDeliveryInfo(
                    billNo: orderNumber,
                    materialName: materielName,
                    qty: qty,
                    unitName: unit,
                    numPage: numberPage,
                  ));
                } else {
                  item.billNo = orderNumber;
                  item.materialName = materielName;
                  item.qty = qty;
                  item.unitName = unit;
                  item.numPage = numberPage;
                  modify?.call();
                }
              },
              child: Text(
                item != null
                    ? 'incoming_inspection_dialog_modify'.tr
                    : 'incoming_inspection_dialog_add'.tr,
              ),
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

applyInspectionDialog({
  required Function(WorkerInfo) submit,
}) {
  WorkerInfo? worker;

  Get.dialog(
    PopScope(
      canPop: false,
      child: StatefulBuilder(builder: (context, dialogSetState) {
        return AlertDialog(
          title: Text('incoming_inspection_dialog_inspection_application'.tr),
          content: WorkerCheck(
            hint: 'incoming_inspection_dialog_input_applicant_no_tips'.tr,
            init: spGet(spSaveIncomingInspectionApplicant),
            onChanged: (v) => worker = v,
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (worker == null) {
                  showSnackBar(
                      message:
                          'incoming_inspection_dialog_input_applicant_no_tips'
                              .tr,
                      isWarning: true);
                } else {
                  spSave(
                      spSaveIncomingInspectionApplicant, worker!.empCode ?? '');
                  Get.back();
                  submit.call(worker!);
                }
              },
              child: Text('incoming_inspection_dialog_submit'.tr),
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

submitInspectionDialog({
  required Function(WorkerInfo, String) submit,
}) {
  WorkerInfo? worker;
  TextEditingController controller = TextEditingController();
  Get.dialog(
    PopScope(
      canPop: false,
      child: StatefulBuilder(builder: (context, dialogSetState) {
        return AlertDialog(
          title: Text('incoming_inspection_dialog_submit_inspection_result'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              WorkerCheck(
                hint: 'incoming_inspection_dialog_input_inspector_tips'.tr,
                init: spGet(spSaveIncomingInspectionInspector),
                onChanged: (v) => worker = v,
              ),
              const SizedBox(height: 5),
              TextField(
                maxLines: 3,
                controller: controller,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10),
                  filled: true,
                  fillColor: Colors.transparent,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.green, width: 2),
                  ),
                  labelText:
                      'incoming_inspection_dialog_input_inspection_result_tips'
                          .tr,
                  labelStyle: const TextStyle(
                      color: Colors.black54, fontWeight: FontWeight.bold),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => controller.clear(),
                  ),
                ),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (worker == null) {
                  showSnackBar(
                    message:
                        'incoming_inspection_dialog_input_inspector_tips'.tr,
                    isWarning: true,
                  );
                  return;
                }
                var results = controller.text.trim();
                if (results.isEmpty) {
                  showSnackBar(
                    message:
                        'incoming_inspection_dialog_input_inspection_result_tips'
                            .tr,
                    isWarning: true,
                  );
                  return;
                }
                spSave(
                    spSaveIncomingInspectionInspector, worker!.empCode ?? '');
                Get.back();
                submit.call(worker!, results);
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
