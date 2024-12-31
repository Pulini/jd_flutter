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
            title: Text('楦头库存维护'),
            content: SizedBox(
                width: 460,
                height: 600,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    textSpan(hint: '型体：', text: typeBody),
                    textSpan(hint: '楦头号：', text: sti.shoeTreeNo ?? ''),
                    Expanded(
                      child: GridView.builder(
                        itemCount: sti.sizeList?.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 3 / 1,
                        ),
                        itemBuilder: (context, index) {
                          var controller = TextEditingController(
                            text: sti.sizeList?[index].qty.toString(),
                          );
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Row(
                                children: [
                                  textSpan(
                                    hint: '尺码：',
                                    text: sti.sizeList?[index].size ?? '',
                                  ),
                                  const SizedBox(width: 30),
                                  Text(
                                    '库存：',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      onChanged: (c) {
                                        sti.sizeList?[index].qty = c.toIntTry();
                                        controller.text =
                                            c.toIntTry().toString();
                                        controller.selection =
                                            TextSelection.fromPosition(
                                          TextPosition(
                                            offset: controller.text.length,
                                          ),
                                        );
                                      },
                                      controller: controller,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.grey[300],
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                            color: Colors.transparent,
                                          ),
                                        ),
                                        border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                )),
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
                child: Text('保存'),
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
              Text('尺码预留楦头'),
              Expanded(child: Container()),
              CombinationButton(
                combination: Combination.left,
                text: '预留2个',
                click: () => dialogSetState(() {
                  for (var v in setList) {
                    v.reserveShoeTreeQty = 2;
                  }
                }),
              ),
              CombinationButton(
                combination: Combination.right,
                text: '清零',
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
                  _item(setList[index], dialogSetState),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                set.call(setList);
              },
              child: Text('保存'),
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

_item(PartsSizeList data, StateSetter dialogSetState) {
  var controller = TextEditingController(
    text: data.reserveShoeTreeQty.toString(),
  );
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(5),
      child: Row(
        children: [
          expandedTextSpan(
            hint: '尺码：',
            text: data.size ?? '',
          ),
          expandedTextSpan(
            hint: '库存：',
            text: data.shoeTreeQty.toString(),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Text(
                  '预留：',
                  style: TextStyle(fontWeight: FontWeight.bold),
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
                        TextPosition(
                          offset: controller.text.length,
                        ),
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
                              TextPosition(
                                offset: controller.text.length,
                              ),
                            );
                          }
                        }),
                        icon: Icon(
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
                        icon: Icon(
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
          expandedTextSpan(
            hint: '  预排：',
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
    errorDialog(content: '请选择需要配送的轮次');
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
        TaskPoint(positionName: '无', positionCode: '0')
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
              title: Text('创建任务'),
              content: SizedBox(
                width: 460,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    selectView(
                      list: agvList,
                      controller: agvController,
                      errorMsg: '查询不到AGV设备信息',
                      hint: '执行设备：',
                    ),
                    selectView(
                      list: taskTypeList,
                      controller: agvTypeController,
                      errorMsg: '查询不到AGV模版信息',
                      hint: '任务模版：',
                      select: (i) => dialogSetState(() {
                        typeSelect = i;
                        startList = taskTypeList[i].startPoint ?? [];
                        endList = taskTypeList[i].endPoint ?? [];
                      }),
                    ),
                    selectView(
                      list: startList,
                      controller: startController,
                      errorMsg: '查询不到AGV起点信息',
                      hint: '任务起点：',
                    ),
                    selectView(
                      list: endList,
                      controller: endController,
                      errorMsg: '查询不到AGV终点信息',
                      hint: '任务终点：',
                    ),
                    SwitchButton(
                      onChanged: (v) => isScheduling = v,
                      name: '启用AGV配送',
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
                  child: Text('创建'),
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
      String taskState = '未知';
      Color taskStateColor = Colors.red;
      switch (taskType) {
        case 1:
          taskState = '执行中';
          taskStateColor = Colors.green;
          break;
        case 2:
          taskState = '已完成';
          taskStateColor = Colors.blueAccent;
          break;
        case 3:
          taskState = '暂停中';
          taskStateColor = Colors.orange;
          break;
      }

      var title = Text('AGV 任务详情');
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
                            hint: '任务状态：',
                            text: taskState,
                            textColor: taskStateColor,
                          ),
                          Row(
                            children: [
                              expandedTextSpan(
                                  hint: '任务起点：', text: startingPoint),
                              expandedTextSpan(hint: '任务终点：', text: endPoint),
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
    loading: '正在检查楦头库存...',
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
    loading: '正在保存楦头库存信息...',
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
    loading: '正在获取机器人信息...',
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
    loading: '正在创建AGV配送任务...',
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
    loading: '正在获取AGV当前任务...',
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
    loading: '正在取消AGV当前任务...',
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
  showSnackBar(title: 'AGV设置', message: '正在暂停AGV当前任务...');
  httpPost(
    method: webApiSmartDeliveryStopRobot,
    params: {'RobNumber': agvNumber},
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      success.call();
      showSnackBar(title: 'AGV设置', message: response.message ?? '');
    } else {
      errorDialog(content: response.message ?? 'query_default_error'.tr);
    }
  });
}

_resumeAgvTask({
  required String agvNumber,
  required Function() success,
}) {
  showSnackBar(title: 'AGV设置', message: '正在恢复AGV当前任务...');
  httpPost(
    method: webApiSmartDeliveryResumeRobot,
    params: {'RobNumber': agvNumber},
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      success.call();
      showSnackBar(title: 'AGV设置', message: response.message ?? '');
    } else {
      errorDialog(content: response.message ?? 'query_default_error'.tr);
    }
  });
}
