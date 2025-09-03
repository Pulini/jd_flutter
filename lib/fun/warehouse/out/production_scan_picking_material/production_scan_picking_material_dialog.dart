import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/constant.dart';

import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/picker/picker_item.dart';
import 'package:jd_flutter/widget/worker_check_widget.dart';

import 'package:jd_flutter/widget/dialogs.dart';

selectSupplierAndDepartmentDialog({
  required Function(
    WorkerInfo,
    PickerSapSupplier?,
    PickerSapDepartment?,
  ) submit,
}) {
  getSapSupplierAndDepartment(callback: (sList, sError, dList, dError) {
    WorkerInfo? worker;
    var sSelect = spGet(spSaveProductionScanPickingMaterialSupplier)
        .toString()
        .toIntTry();
    var dSelect = spGet(spSaveProductionScanPickingMaterialDepartment)
        .toString()
        .toIntTry();
    var sController = FixedExtentScrollController(
      initialItem: sSelect < sList.length ? sSelect : 0,
    );
    var dController = FixedExtentScrollController(
      initialItem: dSelect < dList.length ? dSelect : 0,
    );
    var isSupplier = true;
    Get.dialog(
      PopScope(
        canPop: true,
        child: StatefulBuilder(builder: (context, dialogSetState) {
          return AlertDialog(
            title: Text('production_scan_picking_material_submit_picking'.tr),
            contentPadding: const EdgeInsets.only(left: 10, right: 10),
            content: SizedBox(
              width: context.getScreenSize().width * 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  WorkerCheck(
                    hint: 'production_scan_picking_material_input_picker_number'
                        .tr,
                    init: spGet(spSaveProductionScanPickingMaterialWorker),
                    onChanged: (v) => worker = v,
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: isSupplier,
                        onChanged: (v) => dialogSetState(() => isSupplier = v!),
                      ),
                      Expanded(
                        child: selectView(
                          list: isSupplier ? sList : [],
                          controller: sController,
                          errorMsg: isSupplier
                              ? sError
                              : 'production_scan_picking_material_select_supplier_or_department'
                                  .tr,
                          hint: 'production_scan_picking_material_supplier'.tr,
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: !isSupplier,
                        onChanged: (v) =>
                            dialogSetState(() => isSupplier = !v!),
                      ),
                      Expanded(
                        child: selectView(
                          list: isSupplier ? [] : dList,
                          controller: dController,
                          errorMsg: isSupplier
                              ? 'production_scan_picking_material_select_supplier_or_department'
                                  .tr
                              : dError,
                          hint:
                              'production_scan_picking_material_department'.tr,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (worker == null) {
                    showSnackBar(
                      message:
                          'production_scan_picking_material_input_picker_number'
                              .tr,
                      isWarning: true,
                    );
                    return;
                  }
                  if (sList.isEmpty && dList.isEmpty) {
                    showSnackBar(
                      message:
                          'production_scan_picking_material_select_supplier_or_department'
                              .tr,
                      isWarning: true,
                    );
                    return;
                  }
                  if (isSupplier) {
                    sSelect = sList.length > 1 ? sController.selectedItem : 0;
                    dSelect = 0;
                  } else {
                    sSelect = 0;
                    dSelect = dList.length > 1 ? dController.selectedItem : 0;
                  }
                  spSave(
                    spSaveProductionScanPickingMaterialWorker,
                    worker!.empCode ?? '',
                  );
                  spSave(
                    spSaveProductionScanPickingMaterialSupplier,
                    sSelect,
                  );
                  spSave(
                    spSaveProductionScanPickingMaterialDepartment,
                    dSelect,
                  );
                  Get.back();
                  submit.call(
                    worker!,
                    isSupplier ? sList[sSelect] : null,
                    isSupplier ? null : dList[dSelect],
                  );
                },
                child: Text('production_scan_picking_material_submit'.tr),
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
  });
}

getSapSupplierAndDepartment({
  required Function(
    List<PickerSapSupplier>,
    String,
    List<PickerSapDepartment>,
    String,
  ) callback,
}) {
  loadingShow('production_scan_picking_material_getting_supplier_and_department'.tr);
  Future.wait([
    httpGet(method: webApiPickerSapSupplier),
    httpGet(method: webApiPickerSapDepartment),
  ]).then((results) async {
    var supplier = <PickerSapSupplier>[];
    var supplierError = '';
    var department = <PickerSapDepartment>[];
    var departmentError = '';
    if (results[0].resultCode == resultSuccess) {
      supplier.addAll(await compute(
        parseJsonToList,
        ParseJsonParams(
          results[0].data,
          PickerSapSupplier.fromJson,
        ),
      ));
    } else {
      supplierError = results[0].message ?? 'query_default_error'.tr;
    }
    if (results[1].resultCode == resultSuccess) {
      department.addAll(await compute(
        parseJsonToList,
        ParseJsonParams(
          results[1].data,
          PickerSapDepartment.fromJson,
        ),
      ));
    } else {
      departmentError = results[1].message ?? 'query_default_error'.tr;
    }
    loadingDismiss();
    callback.call(supplier, supplierError, department, departmentError);
  });
}
