import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../bean/http/response/worker_info.dart';
import '../../../widget/worker_check_widget.dart';

showSalesOrderListDialog(List<String> list) {
  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text('销售订单号'),
        content: SizedBox(
          width: 300,
          height: 200,
          child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: list.length,
              itemBuilder: (context, index) => Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(list[index]),
                    ),
                  )),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'dialog_default_back'.tr,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    ),
  );
}

addNewWorkerDialog(
  List<WorkerInfo> workers,
  Function(WorkerInfo wi) callback,
) {
  var avatar = ''.obs;
  var exists = false.obs;
  WorkerInfo? newWorker;
  Get.dialog(
    PopScope(
      canPop: false,
      child: Obx(
        () => AlertDialog(
          title: const Text('添加临时组员'),
          content: SizedBox(
            width: 200,
            height: 260,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      if (avatar.isNotEmpty)
                        Center(
                          child: SizedBox(
                            width: 150,
                            height: 150,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child:
                                  Image.network(avatar.value, fit: BoxFit.fill),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (exists.value)
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      '员工已存在',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                WorkerCheck(onChanged: (w) {
                  newWorker = w;
                  avatar.value = w?.picUrl ?? '';
                  exists.value =
                      w != null && workers.any((v) => v.empID == w.empID);
                }),
              ],
            ),
          ),
          contentPadding: const EdgeInsets.only(left: 30, right: 30),
          actionsPadding: const EdgeInsets.only(right: 10, bottom: 10),
          actions: [
            if (!exists.value && newWorker != null)
              TextButton(
                onPressed: () {
                  if (newWorker != null) {
                    callback.call(newWorker!);
                    Get.back();
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
