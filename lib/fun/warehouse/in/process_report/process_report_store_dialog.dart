import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/bar_code.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/constant.dart';

import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/worker_check_widget.dart';

void checkBarCodeProcessDialog({
  required List<BarCodeInfo> list,
  required Function(WorkerInfo, bool isSingle, List<BarCodeProcessInfo>) submit,
}) {
  getProcessFlowInfoByBarCode(
    list: list,
    callback: (data) {
      WorkerInfo? worker;
      var processSelect =
          spGet(spSaveProcessSelectProcess).toString().toIntTry();
      var processList = <BarCodeProcessInfo>[...data.process!];
      var processController = FixedExtentScrollController(
        initialItem: data.dataType == '3'
            ? 0
            : processSelect < processList.length
                ? processSelect
                : 0,
      );

      var body = data.dataType == '3'
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                WorkerCheck(
                  hint: 'process_report_store_input_operator_id'.tr,
                  init: spGet(spSaveScanPickingMaterial),
                  onChanged: (v) => worker = v,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: processList.length,
                    itemBuilder: (c, i) => Obx(() => GestureDetector(
                          onTap: () => processList[i].isSelected.value =
                              !processList[i].isSelected.value,
                          child: Container(
                            height: 45,
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: processList[i].isSelected.value
                                      ? Colors.green
                                      : Colors.grey),
                              borderRadius: BorderRadius.circular(50),
                              color: processList[i].isSelected.value
                                  ? Colors.green.shade200
                                  : Colors.white,
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: processList[i].isSelected.value,
                                  onChanged: (v) =>
                                      processList[i].isSelected.value = v!,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data.process![i].processFlowName ?? '',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      Text(
                                        data.process![i].processFlowShowName ?? '',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.blue,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ),
                )
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                WorkerCheck(
                  hint: 'process_report_store_input_operator_id'.tr,
                  init: spGet(spSaveScanPickingMaterial),
                  onChanged: (v) => worker = v,
                ),
                SelectView(
                  list: processList,
                  controller: processController,
                  errorMsg: '',
                  hint: 'process_report_store_process_procedure'.tr,
                ),
              ],
            );

      Get.dialog(
        PopScope(
          canPop: true,
          child: StatefulBuilder(builder: (context, dialogSetState) {
            return AlertDialog(
              title: Text('process_report_store_submit_process_store'.tr),
              content: SizedBox(width: 300, child: body),
              actions: [
                TextButton(
                  onPressed: () {
                    if (worker == null) {
                      showSnackBar(
                          message: 'process_report_store_input_operator_id'.tr,
                          isWarning: true);
                      return;
                    }
                    if (data.dataType == '3') {
                      var selected =
                          processList.where((v) => v.isSelected.value).toList();
                      if (selected.isEmpty) {
                        showSnackBar(
                          message:
                              'process_report_store_select_process_procedure'
                                  .tr,
                          isWarning: true,
                        );
                        return;
                      } else {
                        Get.back();
                        submit.call(worker!, false, selected);
                      }
                    } else {
                      if (processList.isEmpty) {
                        showSnackBar(
                            message:
                                'process_report_store_select_process_procedure'
                                    .tr,
                            isWarning: true);
                        return;
                      }
                      processSelect = processList.length > 1
                          ? processController.selectedItem
                          : 0;
                      spSave(spSaveProcessSelectProcess, processSelect);
                      spSave(spSaveScanPickingMaterial, worker!.empCode ?? '');
                      Get.back();
                      submit.call(worker!, true, [processList[processSelect]]);
                    }
                  },
                  child: Text('process_report_store_submit'.tr),
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

void getProcessFlowInfoByBarCode({
  required List<BarCodeInfo> list,
  required Function(BarCodeReportableProcessInfo) callback,
}) {
  httpPost(
    method: webApiGetReportableProcessByBarcode,
    loading: 'process_report_store_get_code_process'.tr,
    body: {
      'BarCodeList': [
        for (var item in list) {'BarCode': item.code}
      ],
      'OrganizeID': userInfo?.organizeID,
    },
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      callback.call(BarCodeReportableProcessInfo.fromJson(response.data));
    } else {
      errorDialog(content: response.message ?? 'query_default_error'.tr);
    }
  });
}
