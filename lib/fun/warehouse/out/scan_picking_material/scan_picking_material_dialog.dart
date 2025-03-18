import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/bar_code.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/constant.dart';
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
              title: Text('提交领料'),
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    WorkerCheck(
                      hint: '请输入领料员工号',
                      init: spGet(spSaveScanPickingMaterial),
                      onChanged: (v) => worker = v,
                    ),
                    selectView(
                      list: processList,
                      controller: processController,
                      errorMsg: error,
                      hint: '制程/工序：',
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
                    if (processList.isEmpty) {
                      showSnackBar(message: '请选择制程和工序', isWarning: true);
                      return;
                    }
                    processSelect = processList.length > 1
                        ? processController.selectedItem
                        : 0;
                    spSave(
                        spSaveScanPickingMaterialSelectProcess, processSelect);
                    spSave(spSaveScanPickingMaterial, worker!.empCode ?? '');
                    Get.back();
                    submit.call(worker!, processList[processSelect]);

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
      debugPrint('list=${list.length}');
    } else {
      error = response.message ?? 'query_default_error'.tr;
    }
    callback.call(list, error);
  });
}
