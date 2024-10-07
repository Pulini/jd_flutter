import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../bean/http/response/worker_info.dart';
import '../../../widget/custom_widget.dart';

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

_addNewWorkerDialog(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (avatar.isNotEmpty)
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Image.network(avatar.value, fit: BoxFit.fill),
                    ),
                  ),
                if (exists.value)
                  Text(
                    '员工已存在',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
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

modifyOperatorDialog(
  List<WorkerInfo> workers,
  Function(int) callback,
) {
  var select = (-1).obs;
  Get.dialog(PopScope(
    canPop: false,
    child: StatefulBuilder(builder: (context, dialogSetState) {
      return AlertDialog(
        title: Row(
          children: [
            const Expanded(child: Text('修改操作员')),
            IconButton(
              icon: const Icon(
                Icons.add,
                size: 30,
                color: Colors.blueAccent,
              ),
              onPressed: () {
                _addNewWorkerDialog(workers, (wi) {
                  dialogSetState(() {
                    workers.add(wi);
                  });
                });
              },
            ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 300,
          child: GridView.builder(
            itemCount: workers.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2 / 1,
            ),
            itemBuilder: (context, index) => GestureDetector(
              onTap: () {
                dialogSetState(() {
                  select.value = index;
                });
              },
              child: Card(
                color: select.value == index
                    ? Colors.greenAccent.shade100
                    : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    children: [
                      avatarPhoto(workers[index].picUrl),
                      Expanded(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            workers[index].empCode ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            workers[index].empName ?? '',
                            style: TextStyle(
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ))
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              // callback.call(select);
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
  ));
}
