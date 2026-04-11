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
                textSpan(hint: 'part_cross_docking_tips'.tr, text: msg),
                WorkerCheck(
                  hint: 'part_cross_docking_worker_number_hint'.tr,
                  onChanged: (v) => worker = v,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if(worker==null){
                  showSnackBar(message: 'part_cross_docking_worker_number_hint'.tr);
                }else{
                  success.call(worker!);
                }
              },
              child: Text('part_cross_docking_submit'.tr),
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