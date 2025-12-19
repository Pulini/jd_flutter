import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/process_dispatch_register_info.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/worker_check_widget.dart';

void showSalesOrderListDialog(List<String> list) {
  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text('process_dispatch_register_dialog_sales_order_no'.tr),
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

void setCapacityDialog({
  required List<Orders> list,
  required bool isSummary,
  required Function success,
}) {
  if (!checkUserPermission('1052501')) {
    errorDialog(
        content: 'process_dispatch_register_dialog_no_label_permission'.tr);
    return;
  }
  var createList = <CreateLabel>[];
  var boxCapacityController = TextEditingController();
  var createTotalController = TextEditingController();
  var totalQty = list.map((v) => v.qty ?? 0).reduce((a, b) => a.add(b));
  var totalMustQty = list.map((v) => v.mustQty ?? 0).reduce((a, b) => a.add(b));
  var max = totalQty.sub(totalMustQty);
  WorkerInfo? worker;
  Get.dialog(
    PopScope(
      canPop: true,
      child: StatefulBuilder(
        builder: (context, dialogSetState) {
          var mediaSize = MediaQuery.of(context).size;
          addWorker() {
            var createTotal = createTotalController.text.toDoubleTry();

            if (createTotal <= 0) {
              errorDialog(
                  content:
                      'process_dispatch_register_dialog_please_fill_total'.tr);
              return;
            }
            if (createTotal > max) {
              errorDialog(
                  content: 'process_dispatch_register_dialog_create_total_limit'
                      .trArgs([max.toShowString()]));
              return;
            }
            if (worker == null) {
              errorDialog(
                  content:
                      'process_dispatch_register_dialog_please_fill_worker_number'
                          .tr);
              return;
            }

            dialogSetState(() {
              try {
                var find = createList
                    .firstWhere((v) => v.workerId == worker!.empID.toString());
                find.qty = createTotal;
              } on StateError catch (_) {
                createList.add(CreateLabel(
                  workerNumber: worker!.empCode!,
                  workerName: worker!.empName!,
                  workerId: worker!.empID.toString(),
                  qty: createTotal,
                ));
              }
            });
          }

          create() {
            var boxCapacity = boxCapacityController.text.toDoubleTry();
            if (boxCapacity <= 0) {
              errorDialog(
                  content:
                      'process_dispatch_register_dialog_please_fill_box_capacity'
                          .tr);
              return;
            }
            if (boxCapacity > max) {
              errorDialog(
                  content: 'process_dispatch_register_dialog_box_capacity_limit'
                      .trArgs([max.toShowString()]));
              return;
            }

            if (createList.isEmpty) {
              errorDialog(
                  content: 'process_dispatch_register_dialog_add_worker'.tr);
              return;
            }
            _createLabels(
              instruction: isSummary ? '' : list.first.instructions ?? '',
              size: list.first.size ?? '',
              boxCapacity: boxCapacity,
              fids: list.map((v) => v.fid ?? 0).toList(),
              createList: createList,
              success: () {
                Get.back();
                success.call();
              },
            );
          }

          item(CreateLabel data) => Container(
                margin: const EdgeInsets.only(bottom: 5),
                padding: EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey, width: 2),
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${data.workerName}(${data.workerNumber})',
                      ),
                    ),
                    Text(data.qty.toShowString()),
                    Padding(
                      padding: EdgeInsets.only(left: 7, right: 7),
                      child: IconButton(
                        onPressed: () =>
                            dialogSetState(() => createList.remove(data)),
                        icon: Icon(
                          Icons.delete_forever,
                          color: Colors.red,
                        ),
                      ),
                    )
                  ],
                ),
              );

          return AlertDialog(
            title: Text('process_dispatch_register_dialog_create_label'.tr),
            content: SizedBox(
              width: mediaSize.width * 0.8,
              height: mediaSize.height * 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: NumberDecimalEditText(
                          max: max,
                          hint: 'process_dispatch_register_dialog_box_capacity'
                              .trArgs([max.toShowString()]),
                          controller: boxCapacityController,
                        ),
                      ),
                      Expanded(
                        child: NumberDecimalEditText(
                          hint: 'process_dispatch_register_dialog_create_total'
                              .tr,
                          controller: createTotalController,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: WorkerCheck(onChanged: (w) => worker = w)),
                      Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: CombinationButton(
                          text:
                              'process_dispatch_register_dialog_add_worker'.tr,
                          click: () => addWorker(),
                        ),
                      )
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: createList.length,
                      itemBuilder: (c, i) => item(createList[i]),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => create(),
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
        },
      ),
    ),
  );
}

void _createLabels({
  required String instruction,
  required String size,
  required double boxCapacity,
  required List<int> fids,
  required List<CreateLabel> createList,
  required Function() success,
}) {
  httpPost(
    method: webApiCreateLabelBarcode,
    loading: 'process_dispatch_register_dialog_creating_label'.tr,
    body: {
      'UserID': userInfo?.userID ?? 0,
      'Mtono': instruction,
      'Size': size,
      'BoxCapacity': boxCapacity.toShowString(),
      'FID': fids,
      'Emps': [
        for (var data in createList)
          {
            'EmpID': data.workerId,
            'Qty': data.qty.toShowString(),
            'DeptID': userInfo?.departmentID ?? 0,
          }
      ],
    },
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      successDialog(content: response.message, back: () => success.call());
    } else {
      errorDialog(content: response.message);
    }
  });
}

void addNewWorkerDialog(
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
          title: Text('process_dispatch_register_dialog_add_temp_worker'.tr),
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
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      'process_dispatch_register_dialog_worker_exists'.tr,
                      style: const TextStyle(
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

void reportDialog(ProcessDispatchLabelInfo data, Function() refresh) {
  var qtyController = TextEditingController(text: data.qty.toShowString());
  WorkerInfo? worker;
  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text('process_dispatch_register_dialog_add_temp_worker'.tr),
        content: SizedBox(
          width: 200,
          height: 260,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1、输入员工二维码。\r\n2、填写合格数。',
                style: TextStyle(color: Colors.green),
              ),
              WorkerCheck(
                init: data.empNumber,
                onChanged: (w) => worker = w!,
              ),
              NumberDecimalEditText(
                initQty: data.qty,
                controller: qtyController,
                max: data.boxCapacity,
              )
            ],
          ),
        ),
        contentPadding: const EdgeInsets.only(left: 30, right: 30),
        actionsPadding: const EdgeInsets.only(right: 10, bottom: 10),
        actions: [
          TextButton(
            onPressed: () {
              if (worker == null) {
                errorDialog(content: '请填写员工');
                return;
              }
              data.empID = worker!.empID;
              data.empNumber = worker!.empCode;
              data.empName = worker!.empName;
              data.qty = qtyController.text.toDoubleTry();
              Get.back();
            },
            child: Text('dialog_default_confirm'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              refresh.call();
            },
            child: Text(
              'dialog_default_cancel'.tr,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    ),
  );
}
