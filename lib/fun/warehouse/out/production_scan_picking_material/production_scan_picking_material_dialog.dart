import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/picker/picker_item.dart';
import 'package:jd_flutter/widget/worker_check_widget.dart';

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
            title: Text('提交领料'),
            contentPadding: const EdgeInsets.only(left: 10, right: 10),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  WorkerCheck(
                    hint: '请输入领料员工号',
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
                          errorMsg: isSupplier ? sError : '请选择供应商或部门',
                          hint: '供应商：',
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
                          errorMsg: isSupplier ? '请选择供应商或部门' : dError,
                          hint: '部门：',
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
                    showSnackBar(message: '请输入领料员工号', isWarning: true);
                    return;
                  }
                  if (sList.isEmpty && dList.isEmpty) {
                    showSnackBar(message: '请选择供应商或部门', isWarning: true);
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
                child: Text('提交'),
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
  loadingDialog('正在获取供应商及部门...');
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
