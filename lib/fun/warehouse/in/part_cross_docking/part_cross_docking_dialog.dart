import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/worker_check_widget.dart';

void checkWorkerDialog({
  required String msg,
  required void Function(WorkerInfo) success,
}){
  WorkerInfo? worker;
  Get.dialog(
    PopScope(
      canPop: true,
      child: StatefulBuilder(builder: (context, dialogSetState) {
        return AlertDialog(
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                textSpan(hint: '提示：', text: msg),
                WorkerCheck(
                  hint: '请输入操作员工号',
                  onChanged: (v) => worker = v,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if(worker==null){
                  showSnackBar(message: '请输入操作员工号');
                }else{
                  success.call(worker!);
                }
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
}