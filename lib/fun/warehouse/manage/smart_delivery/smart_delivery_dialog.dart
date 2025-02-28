import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/smart_delivery_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/switch_button_widget.dart';

modifyShoeTreeDialog(String typeBody, int departmentID) {
  _getShoeTreeList(
    typeBody: typeBody,
    departmentID: departmentID,
    success: (sti) {
      Get.dialog(
        PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text('smart_delivery_dialog_shoe_tree_maintenance'.tr),
            content: SizedBox(
              width: 460,
              height: 600,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textSpan(
                    hint: 'smart_delivery_dialog_type_body'.tr,
                    text: typeBody,
                  ),
                  textSpan(
                    hint: 'smart_delivery_dialog_shoe_tree_no'.tr,
                    text: sti.shoeTreeNo ?? '',
                  ),
                  Expanded(
                    child: GridView.builder(
                      itemCount: sti.sizeList?.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 3 / 1,
                      ),
                      itemBuilder: (context, i) =>
                          _modifyShoeTreeItem(sti.sizeList ?? [], i),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => _saveShoeTree(
                  sti: sti,
                  shoeTreeNo: sti.shoeTreeNo ?? '',
                  departmentID: departmentID,
                  success: (msg) => successDialog(
                    content: msg,
                    back: () => Get.back(),
                  ),
                ),
                child: Text('smart_delivery_dialog_save'.tr),
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
      );
    },
  );
}

_modifyShoeTreeItem(List<SizeInfo> list, int index) {
  var controller = TextEditingController(text: list[index].qty.toString());
  var data = list[index];
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(5),
      child: Row(
        children: [
          textSpan(
            hint: 'smart_delivery_dialog_size'.tr,
            text: data.size ?? '',
          ),
          const SizedBox(width: 30),
          Text(
            'smart_delivery_dialog_inventory'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: TextField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (c) {
                data.qty = c.toIntTry();
                controller.text = c.toIntTry().toString();
                controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: controller.text.length),
                );
              },
              controller: controller,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[300],
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

reserveShoeTreeDialog(
  List<PartsSizeList> shoeTreeList,
  Function(List<PartsSizeList>) set,
) {
  var setList = <PartsSizeList>[
    for (var v in shoeTreeList)
      PartsSizeList(
        size: v.size,
        qty: v.qty,
        shoeTreeQty: v.shoeTreeQty,
      )..reserveShoeTreeQty = v.reserveShoeTreeQty
  ];
  Get.dialog(
    PopScope(
      canPop: false,
      child: StatefulBuilder(
        builder: (context, dialogSetState) => AlertDialog(
          title: Row(
            children: [
              Text('smart_delivery_dialog_size_reserve_shoe_tree'.tr),
              Expanded(child: Container()),
              CombinationButton(
                combination: Combination.left,
                text: 'smart_delivery_dialog_reserve_two'.tr,
                click: () => dialogSetState(() {
                  for (var v in setList) {
                    v.reserveShoeTreeQty = 2;
                  }
                }),
              ),
              CombinationButton(
                combination: Combination.right,
                text: 'smart_delivery_dialog_reset'.tr,
                click: () => dialogSetState(() {
                  for (var v in setList) {
                    v.reserveShoeTreeQty = 0;
                  }
                }),
              ),
            ],
          ),
          content: SizedBox(
            width: 460,
            height: 600,
            child: ListView.builder(
              itemCount: setList.length,
              itemBuilder: (context, index) =>
                  _reserveShoeTreeItem(setList[index], dialogSetState),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                set.call(setList);
              },
              child: Text('smart_delivery_dialog_save'.tr),
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

_reserveShoeTreeItem(PartsSizeList data, StateSetter dialogSetState) {
  var controller =
      TextEditingController(text: data.reserveShoeTreeQty.toString());
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(5),
      child: Row(
        children: [
          expandedTextSpan(
            hint: 'smart_delivery_dialog_size'.tr,
            text: data.size ?? '',
          ),
          expandedTextSpan(
            hint: 'smart_delivery_dialog_inventory'.tr,
            text: data.shoeTreeQty.toString(),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Text(
                  'smart_delivery_dialog_reserve'.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: TextField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (c) => dialogSetState(() {
                      data.reserveShoeTreeQty = c.toIntTry();
                      controller.text = c.toIntTry().toString();
                      controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: controller.text.length),
                      );
                    }),
                    controller: controller,
                    decoration: InputDecoration(
                      prefixIcon: IconButton(
                        onPressed: () => dialogSetState(() {
                          var qty = controller.text.toIntTry();
                          if (qty > 0) {
                            qty -= 1;
                            data.reserveShoeTreeQty = qty;
                            controller.text = qty.toString();
                            controller.selection = TextSelection.fromPosition(
                              TextPosition(offset: controller.text.length),
                            );
                          }
                        }),
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red,
                        ),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () => dialogSetState(() {
                          var qty = controller.text.toIntTry();
                          qty += 1;
                          data.reserveShoeTreeQty = qty;
                          controller.text = qty.toString();
                          controller.selection = TextSelection.fromPosition(
                            TextPosition(
                              offset: controller.text.length,
                            ),
                          );
                        }),
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.green,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.grey[300],
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                        ),
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          expandedTextSpan(
            hint: 'smart_delivery_dialog_pre_sort'.tr,
            text: data.roundDelivery().toString(),
          ),
        ],
      ),
    ),
  );
}

const agvDeviceSelect = 'AGV_DEVICE_SELECT';
const agvTaskTypeSelect = 'AGV_TASK_TYPE_SELECT';
const agvTaskStartSelect = 'AGV_TASK_START_SELECT';
const agvTaskEndSelect = 'AGV_TASK_END_SELECT';

createDeliveryTaskDialog({
  required String nowOrderId,
  required String nowOrderPartsId,
  required List<WorkData> nowOrderRoundList,
  required String mergeOrderId,
  required String mergeOrderPartsId,
  required List<WorkData> mergeOrderRoundList,
  required Function(String taskId, String agvNumber) success,
}) {
  if (nowOrderRoundList.isEmpty) {
    errorDialog(content: 'smart_delivery_dialog_select_delivery_round'.tr);
    return;
  }

  _getAgvInfo(
    success: (agvInfo) {
      var agvSelect = spGet(agvDeviceSelect).toString().toIntTry();
      var typeSelect = spGet(agvTaskTypeSelect).toString().toIntTry();
      var startSelect = spGet(agvTaskStartSelect).toString().toIntTry();
      var endSelect = spGet(agvTaskEndSelect).toString().toIntTry();

      var agvList = <RobotDeviceInfo>[...agvInfo.robInfo ?? []];
      var taskTypeList = <RobotPositionInfo>[...agvInfo.robotPosition ?? []];
      var startList = <TaskPoint>[];
      var endList = <TaskPoint>[];
      var emptyList = <TaskPoint>[
        TaskPoint(
            positionName: 'smart_delivery_dialog_null'.tr, positionCode: '0')
      ];

      if (taskTypeList.isNotEmpty) {
        if (typeSelect < taskTypeList.length) {
          startList.addAll(taskTypeList[typeSelect].startPoint ?? []);
          endList.addAll(taskTypeList[typeSelect].endPoint ?? []);
          emptyList.addAll(taskTypeList[typeSelect].endPoint ?? []);
        } else {
          startList.addAll(taskTypeList[0].startPoint ?? []);
          endList.addAll(taskTypeList[0].endPoint ?? []);
          emptyList.addAll(taskTypeList[0].endPoint ?? []);
        }
      }

      var agvController = FixedExtentScrollController(
        initialItem: agvSelect < agvList.length ? agvSelect : 0,
      );

      var agvTypeController = FixedExtentScrollController(
        initialItem: typeSelect < taskTypeList.length ? typeSelect : 0,
      );

      var startController = FixedExtentScrollController(
        initialItem: startSelect < startList.length ? startSelect : 0,
      );

      var endController = FixedExtentScrollController(
        initialItem: endSelect < endList.length ? endSelect : 0,
      );
      var isScheduling = true;

      Get.dialog(
        PopScope(
          canPop: false,
          child: StatefulBuilder(builder: (context, dialogSetState) {
            return AlertDialog(
              title: Text('smart_delivery_dialog_create_task'.tr),
              content: SizedBox(
                width: 460,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    selectView(
                      list: agvList,
                      controller: agvController,
                      errorMsg:
                          'smart_delivery_dialog_unable_query_device_info'.tr,
                      hint: 'smart_delivery_dialog_execute_device'.tr,
                    ),
                    selectView(
                      list: taskTypeList,
                      controller: agvTypeController,
                      errorMsg:
                          'smart_delivery_dialog_unable_query_mode_info'.tr,
                      hint: 'smart_delivery_dialog_task_mode'.tr,
                      select: (i) => dialogSetState(() {
                        typeSelect = i;
                        startList = taskTypeList[i].startPoint ?? [];
                        endList = taskTypeList[i].endPoint ?? [];
                      }),
                    ),
                    selectView(
                      list: startList,
                      controller: startController,
                      errorMsg:
                          'smart_delivery_dialog_unable_query_starting_point_info'
                              .tr,
                      hint: 'smart_delivery_dialog_task_starting_point'.tr,
                    ),
                    selectView(
                      list: endList,
                      controller: endController,
                      errorMsg:
                          'smart_delivery_dialog_unable_query_endpoint_info'.tr,
                      hint: 'smart_delivery_dialog_task_endpoint'.tr,
                    ),
                    SwitchButton(
                      onChanged: (v) => isScheduling = v,
                      name: 'smart_delivery_dialog_start_delivery'.tr,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    agvSelect =
                        agvList.length > 1 ? agvController.selectedItem : 0;
                    typeSelect = taskTypeList.length > 1
                        ? agvTypeController.selectedItem
                        : 0;
                    startSelect =
                        startList.length > 1 ? startController.selectedItem : 0;
                    endSelect =
                        endList.length > 1 ? endController.selectedItem : 0;
                    spSave(agvDeviceSelect, agvSelect);
                    spSave(agvTaskTypeSelect, typeSelect);
                    spSave(agvTaskStartSelect, startSelect);
                    spSave(agvTaskEndSelect, endSelect);
                    _createAgvTask(
                      agvNumber: agvList[agvSelect].agvNumber ?? '',
                      nowOrderId: nowOrderId,
                      nowOrderPartsId: nowOrderPartsId,
                      nowOrderRoundList: nowOrderRoundList,
                      mergeOrderId: mergeOrderId,
                      mergeOrderPartsId: mergeOrderPartsId,
                      mergeOrderRoundList: mergeOrderRoundList,
                      start: startList[startSelect].positionCode ?? '',
                      end: endList[endSelect].positionCode ?? '',
                      isScheduling: isScheduling,
                      success: (taskId, agvNumber, msg) {
                        Get.back();
                        success.call(taskId, agvNumber);
                        successDialog(content: msg);
                      },
                      fail: (msg) => errorDialog(content: msg),
                    );
                  },
                  child: Text('smart_delivery_dialog_creat'.tr),
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

checkAgvTask({
  required String taskId,
  required String agvNumber,
  required Function(String) cancelTask,
}) {
  _getAgvTaskInfo(
    taskId: taskId,
    success: (task) {
      int taskType = task.taskType ?? 0;
      String startingPoint = task.startingPoint ?? '';
      String endPoint = task.endPoint ?? '';
      String taskState = 'smart_delivery_dialog_unknown'.tr;
      Color taskStateColor = Colors.red;
      switch (taskType) {
        case 1:
          taskState = 'smart_delivery_dialog_executing'.tr;
          taskStateColor = Colors.green;
          break;
        case 2:
          taskState = 'smart_delivery_dialog_completed'.tr;
          taskStateColor = Colors.blueAccent;
          break;
        case 3:
          taskState = 'smart_delivery_dialog_pause'.tr;
          taskStateColor = Colors.orange;
          break;
      }

      var title = Text('smart_delivery_dialog_task_detail'.tr);
      Get.dialog(
        PopScope(
            canPop: false,
            child: StatefulBuilder(
              builder: (c, dialogSetState) {
                return AlertDialog(
                  title: title,
                  content: SizedBox(
                      width: 300,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (taskType == 1 || taskType == 3)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  onPressed: () => _cancelAgvTask(
                                    taskId: taskId,
                                    success: () {
                                      Get.back();
                                      cancelTask.call(taskId);
                                    },
                                  ),
                                  icon: const Icon(
                                    Icons.stop_circle,
                                    color: Colors.red,
                                    size: 35,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _stopAgvTask(
                                    agvNumber: agvNumber,
                                    success: () => dialogSetState(
                                      () => taskType = 3,
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.pause_circle,
                                    color: Colors.orange,
                                    size: 35,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _resumeAgvTask(
                                    agvNumber: agvNumber,
                                    success: () => dialogSetState(
                                      () => taskType = 1,
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.replay_circle_filled_sharp,
                                    color: Colors.green,
                                    size: 35,
                                  ),
                                ),
                              ],
                            ),
                          textSpan(
                            hint: 'smart_delivery_dialog_task_state'.tr,
                            text: taskState,
                            textColor: taskStateColor,
                          ),
                          Row(
                            children: [
                              expandedTextSpan(
                                hint:
                                    'smart_delivery_dialog_task_starting_point'
                                        .tr,
                                text: startingPoint,
                              ),
                              expandedTextSpan(
                                hint: 'smart_delivery_dialog_task_endpoint'.tr,
                                text: endPoint,
                              ),
                            ],
                          ),
                        ],
                      )),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'dialog_default_back'.tr,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                );
              },
            )),
      );
    },
  );
}

_getShoeTreeList({
  required String typeBody,
  required int departmentID,
  required Function(SmartDeliveryShorTreeInfo) success,
}) {
  httpGet(
    loading: 'smart_delivery_dialog_checking_shoe_tree_inventory'.tr,
    method: webApiSmartDeliveryGetShorTreeList,
    params: {
      'TypeBody': typeBody,
      'StockID': userInfo?.defaultStockID,
      'DepartmentID': departmentID,
    },
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      success.call(SmartDeliveryShorTreeInfo.fromJson(response.data));
    } else {
      errorDialog(content: response.message ?? 'query_default_error'.tr);
    }
  });
}

_saveShoeTree({
  required SmartDeliveryShorTreeInfo sti,
  required String shoeTreeNo,
  required int departmentID,
  required Function(String) success,
}) {
  httpPost(
    loading: 'smart_delivery_dialog_saving_shoe_tree_inventory'.tr,
    method: webApiSmartDeliverySaveShorTree,
    body: {
      'ShoeTreeNo': shoeTreeNo,
      'StockID': userInfo?.defaultStockID,
      'DepartmentID': departmentID,
      'SizeList': [
        for (var size in sti.sizeList!)
          {
            'Size': size.size,
            'Qty': size.qty,
          }
      ]
    },
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      success.call(response.message ?? '');
    } else {
      errorDialog(content: response.message ?? 'query_default_error'.tr);
    }
  });
}

_getAgvInfo({
  required Function(AgvInfo) success,
}) {
  httpGet(
    loading: 'smart_delivery_dialog_getting_device_info'.tr,
    method: webApiSmartDeliveryGetRobInfo,
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      success.call(AgvInfo.fromJson(response.data));
    } else {
      errorDialog(content: response.message ?? 'query_default_error'.tr);
    }
  });
}

_createAgvTask({
  required String agvNumber,
  required String nowOrderId,
  required String nowOrderPartsId,
  required List<WorkData> nowOrderRoundList,
  required String mergeOrderId,
  required String mergeOrderPartsId,
  required List<WorkData> mergeOrderRoundList,
  required String start,
  required String end,
  required bool isScheduling,
  required Function(String taskId, String agvNumber, String msg) success,
  required Function(String) fail,
}) {
  httpPost(
    loading: 'smart_delivery_dialog_creating_delivery_task'.tr,
    method: webApiSmartDeliveryCreatRobTask,
    body: {
      'StartPoint': start,
      'EndPoint': end,
      'IsScheduling': isScheduling ? 1 : 0,
      'CheckerID': userInfo?.userID,
      'RobNumber': agvNumber,
      'RoundsData': [
        {
          'NewWorkCardInterID': nowOrderId,
          'PartsID': nowOrderPartsId,
          'Rounds': nowOrderRoundList.map((v) => v.round.toIntTry()).toList()
        },
        if (mergeOrderRoundList.isNotEmpty)
          {
            'NewWorkCardInterID': mergeOrderId,
            'PartsID': mergeOrderPartsId,
            'Rounds':
                mergeOrderRoundList.map((v) => v.round.toIntTry()).toList()
          }
      ]
    },
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      success.call(response.data.toString(), agvNumber, response.message ?? '');
    } else {
      fail.call(response.message ?? 'query_default_error'.tr);
    }
  });
}

_getAgvTaskInfo({
  required String taskId,
  required Function(AgvTaskInfo) success,
}) {
  httpGet(
    loading: 'smart_delivery_dialog_getting_now_task'.tr,
    method: webApiSmartDeliveryGetRobTask,
    params: {'TaskID': taskId},
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      success.call(AgvTaskInfo.fromJson(response.data));
    } else {
      errorDialog(content: response.message ?? 'query_default_error'.tr);
    }
  });
}

_cancelAgvTask({
  required String taskId,
  required Function() success,
}) {
  httpPost(
    loading: 'smart_delivery_dialog_canceling_now_task'.tr,
    method: webApiSmartDeliveryCancelTask,
    body: {'TaskID': taskId},
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      successDialog(content: response.message, back: () => success.call());
    } else {
      errorDialog(content: response.message ?? 'query_default_error'.tr);
    }
  });
}

_stopAgvTask({
  required String agvNumber,
  required Function() success,
}) {
  showSnackBar(
      title: 'smart_delivery_dialog_set'.tr,
      message: 'smart_delivery_dialog_pausing_now_task'.tr);
  httpPost(
    method: webApiSmartDeliveryStopRobot,
    params: {'RobNumber': agvNumber},
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      success.call();
      showSnackBar(
          title: 'smart_delivery_dialog_set'.tr,
          message: response.message ?? '');
    } else {
      errorDialog(content: response.message ?? 'query_default_error'.tr);
    }
  });
}

_resumeAgvTask({
  required String agvNumber,
  required Function() success,
}) {
  showSnackBar(
      title: 'smart_delivery_dialog_set'.tr,
      message: 'smart_delivery_dialog_restoring_now_task'.tr);
  httpPost(
    method: webApiSmartDeliveryResumeRobot,
    params: {'RobNumber': agvNumber},
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      success.call();
      showSnackBar(
          title: 'smart_delivery_dialog_set'.tr,
          message: response.message ?? '');
    } else {
      errorDialog(content: response.message ?? 'query_default_error'.tr);
    }
  });
}
