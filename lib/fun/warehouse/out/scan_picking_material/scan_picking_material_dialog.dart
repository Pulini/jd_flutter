import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/bar_code.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/worker_check_widget.dart';

checkBarCodeProcessDialog({
  required List<BarCodeInfo> list,
  required Function(WorkerInfo, BarCodeProcessInfo) submit,
}) {
  getProcessFlowInfoByBarCode(
    list: list,
    callback: (list, error) {
      WorkerInfo? worker;
      var processSelect =
          spGet(spSaveScanPickingMaterialSelectProcess).toString().toIntTry();
      var processList = <BarCodeProcessInfo>[...list];
      var processController = FixedExtentScrollController(
        initialItem: processSelect < processList.length ? processSelect : 0,
      );
      Get.dialog(
        PopScope(
          canPop: true,
          child: StatefulBuilder(builder: (context, dialogSetState) {
            return AlertDialog(
              title: Text('scan_picking_material_submit_picking'.tr),
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    WorkerCheck(
                      hint: 'scan_picking_material_input_picker_number'.tr,
                      init: spGet(spSaveScanPickingMaterialWorker),
                      onChanged: (v) => worker = v,
                    ),
                    selectView(
                      list: processList,
                      controller: processController,
                      errorMsg: error,
                      hint: 'scan_picking_material_process'.tr,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (worker == null) {
                      showSnackBar(
                        message: 'scan_picking_material_input_picker_number'.tr,
                        isWarning: true,
                      );
                      return;
                    }
                    if (processList.isEmpty) {
                      showSnackBar(
                        message: 'scan_picking_material_select_process'.tr,
                        isWarning: true,
                      );
                      return;
                    }
                    processSelect = processList.length > 1
                        ? processController.selectedItem
                        : 0;
                    spSave(
                        spSaveScanPickingMaterialSelectProcess, processSelect);
                    spSave(
                        spSaveScanPickingMaterialWorker, worker!.empCode ?? '');
                    Get.back();
                    submit.call(worker!, processList[processSelect]);
                  },
                  child: Text('scan_picking_material_submit'.tr),
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
    },
  );
}

getProcessFlowInfoByBarCode({
  required List<BarCodeInfo> list,
  required Function(List<BarCodeProcessInfo>, String) callback,
}) {
  httpPost(
    method: webApiGetProcessFlowInfoByBarCode,
    body: {
      'BarCodeList': [
        for (var item in list) {'BarCode': item.code}
      ],
      'OrganizeID': userInfo?.organizeID,
    },
  ).then((response) {
    var list = <BarCodeProcessInfo>[];
    var error = '';
    if (response.resultCode == resultSuccess) {
      for (var json in response.data) {
        list.add(BarCodeProcessInfo.fromJson(json));
      }
    } else {
      error = response.message ?? 'query_default_error'.tr;
    }
    callback.call(list, error);
  });
}
