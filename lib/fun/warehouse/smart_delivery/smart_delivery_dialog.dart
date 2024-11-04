import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';

import '../../../bean/http/response/smart_delivery_info.dart';
import '../../../utils/web_api.dart';
import '../../../widget/custom_widget.dart';
import '../../../widget/dialogs.dart';

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

createDeliveryTaskDialog({
  required String nowOrderId,
  required String nowOrderPartsId,
  required List<WorkData> nowOrderRoundList,
  required String mergeOrderId,
  required String mergeOrderPartsId,
  required List<WorkData> mergeOrderRoundList,
  required Function(String) success,
}) {
  if (nowOrderRoundList.isEmpty) {
    errorDialog(content: '请选择需要配送的轮次');
    return;
  }
  var typeList = <AgvTaskInfo>[].obs;
  var getTaskTypeFail = ''.obs;
  var typeSelected = 0.obs;
  var startList = <StartPoint>[].obs;
  var endList = <EndPoint>[].obs;
  var getPathRouteFail = ''.obs;
  var startSelected = 0.obs;
  var endSelected = 0.obs;

  arlSuccessCallback(start, end) {
    startList.value = start;
    endList.value = end;
    getPathRouteFail.value = '';
    var startSave = spGet('AGV_PathRouteStart').toString();
    var endSave = spGet('AGV_PathRouteEnd').toString();

    var saveStart = startList.indexWhere((v) => v.positionCode == startSave);
    if (saveStart != -1) {
      startSelected.value = saveStart;
    }
    var saveEnd = endList.indexWhere((v) => v.positionCode == endSave);
    if (saveEnd != -1) {
      endSelected.value = saveEnd;
    }
  }

  arlFailCallback(msg) {
    startList.value = [];
    endList.value = [];
    getPathRouteFail.value = msg;
    startSelected.value = -1;
    endSelected.value = -1;
  }

  attSuccessCallback(type) {
    typeList.value = type;
    getTaskTypeFail.value = '';
    var typeSave = spGet('AGV_TaskType').toString();
    var save = typeList.indexWhere(
      (v) => v.taskType == typeSave,
    );
    if (save != -1) {
      typeSelected.value = save;
    }
    _getAgvRouteList(
      taskType: typeList[typeSelected.value].taskType ?? '',
      success: arlSuccessCallback,
      fail: arlFailCallback,
    );
  }

  attFailCallback(msg) {
    typeList.value = [];
    getTaskTypeFail.value = msg;
    typeSelected.value = -1;
  }

  var selectedStyle = const TextStyle(
    color: Colors.blue,
    fontWeight: FontWeight.bold,
  );
  Get.dialog(
    PopScope(
      canPop: false,
      child: StatefulBuilder(builder: (context, dialogSetState) {
        return AlertDialog(
          title: Text('AGV任务创建'),
          content: Obx(
            () => SizedBox(
              width: 460,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _selectView(
                    list: typeList.map((v) {
                      return Center(
                        child: Text('${v.taskTypeName}', style: selectedStyle),
                      );
                    }).toList(),
                    initIndex: typeSelected.value,
                    errorMsg: getTaskTypeFail.value,
                    hint: '任务模版：',
                    selectedText:
                        '${typeList.isEmpty ? '' : typeList[typeSelected.value].taskTypeName}',
                    buttonClick: () => _getAgvTaskTypList(
                      success: attSuccessCallback,
                      fail: attFailCallback,
                    ),
                    select: (i) => typeSelected.value = i,
                  ),
                  _selectView(
                    list: startList.map((v) {
                      return Center(
                        child: Text('${v.positionName}', style: selectedStyle),
                      );
                    }).toList(),
                    initIndex: startSelected.value,
                    errorMsg: getPathRouteFail.value,
                    hint: '任务起点：',
                    selectedText:
                        '${startList.isEmpty ? '' : startList[startSelected.value].positionName}',
                    buttonClick: () => _getAgvRouteList(
                      taskType: typeList[typeSelected.value].taskType ?? '',
                      success: arlSuccessCallback,
                      fail: arlFailCallback,
                    ),
                    select: (i) => startSelected.value = i,
                  ),
                  _selectView(
                    list: endList.map((v) {
                      return Center(
                        child: Text('${v.positionName}', style: selectedStyle),
                      );
                    }).toList(),
                    initIndex: endSelected.value,
                    errorMsg: getPathRouteFail.value,
                    hint: '任务终点：',
                    selectedText:
                        '${endList.isEmpty ? '' : endList[endSelected.value].positionName}',
                    buttonClick: () => _getAgvTaskTypList(
                      success: attSuccessCallback,
                      fail: attFailCallback,
                    ),
                    select: (i) => endSelected.value = i,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _createAgvTask(
                  nowOrderId: nowOrderId,
                  nowOrderPartsId: nowOrderPartsId,
                  nowOrderRoundList: nowOrderRoundList,
                  mergeOrderId: mergeOrderId,
                  mergeOrderPartsId: mergeOrderPartsId,
                  mergeOrderRoundList: mergeOrderRoundList,
                  start: startList[startSelected.value].positionCode ?? '',
                  end: endList[endSelected.value].positionCode ?? '',
                  success: (taskId,msg) {
                    Get.back();
                    success.call(taskId);
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

  _getAgvTaskTypList(
    success: attSuccessCallback,
    fail: attFailCallback,
  );
}

_selectView({
  required List<Widget> list,
  required int initIndex,
  required String errorMsg,
  required String hint,
  required String selectedText,
  required Function buttonClick,
  required Function(int) select,
}) {
  return Container(
    height: list.length > 1 ? 150 : 50,
    width: double.infinity,
    margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
    padding: const EdgeInsets.only(left: 15, right: 5),
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(list.length > 1 ? 10 : 25),
    ),
    child: list.length > 1
        ? Row(
            children: [
              Text(
                hint,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: initIndex,
                  ),
                  diameterRatio: 1.5,
                  magnification: 1.2,
                  squeeze: 1.2,
                  useMagnifier: true,
                  itemExtent: 32,
                  onSelectedItemChanged: (v) => select.call(v),
                  children: list,
                ),
              ),
            ],
          )
        : list.isEmpty
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: AutoSizeText(
                      errorMsg,
                      style: const TextStyle(color: Colors.black),
                      maxLines: 2,
                      minFontSize: 8,
                      maxFontSize: 16,
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () => buttonClick.call(),
                    child: Text(
                      '重新获取',
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                ],
              )
            : Row(children: [textSpan(hint: hint, text: selectedText)]),
  );
}

checkAgvTask(String taskId) {
  _getAgvTaskInfo(
    taskId: taskId,
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
                    textSpan(hint: '型体：', text: 'typeBody'),
                    textSpan(hint: '楦头号：', text: ''),
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
          ),
        ),
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

_getAgvRouteList({
  required String taskType,
  required Function(List<StartPoint>, List<EndPoint>) success,
  required Function(String) fail,
}) {
  httpGet(
    loading: '正在获取机器人站点信息...',
    method: webApiSmartDeliveryGetRobotPosition,
    params: {'taskType': taskType},
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      var path = PatchRouteInfo.fromJson(response.data);
      success.call(path.startPoint ?? [], path.endPoint ?? []);
    } else {
      fail.call(response.message ?? 'query_default_error'.tr);
    }
  });
}

_getAgvTaskTypList({
  required Function(List<AgvTaskInfo>) success,
  required Function(String) fail,
}) {
  httpGet(
    loading: '正在获取机器人模版信息...',
    method: webApiSmartDeliveryGetTaskType,
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      success.call(<AgvTaskInfo>[
        for (var item in response.data) AgvTaskInfo.fromJson(item)
      ]);
    } else {
      fail.call(response.message ?? 'query_default_error'.tr);
    }
  });
}

_createAgvTask({
  required String nowOrderId,
  required String nowOrderPartsId,
  required List<WorkData> nowOrderRoundList,
  required String mergeOrderId,
  required String mergeOrderPartsId,
  required List<WorkData> mergeOrderRoundList,
  required String start,
  required String end,
  required Function(String taskId,String msg) success,
  required Function(String) fail,
}) {
  httpPost(
    loading: '正在创建AGV配送任务...',
    method: webApiSmartDeliveryCreatRobTask,
    body: {
      'StartPoint': start,
      'EndPoint': end,
      'CheckerID': userInfo?.userID,
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
      success.call(response.data.toString(),response.message ?? '');
    } else {
      fail.call(response.message ?? 'query_default_error'.tr);
    }
  });
}

_getAgvTaskInfo({
  required String taskId,
  required Function(String) success,
}) {
  httpGet(
    loading: '正在获取AGV当前任务...',
    method: webApiSmartDeliveryGetRobTask,
    body: {'TaskID': taskId},
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      success.call(response.message ?? '');
    } else {
      errorDialog(content: response.message ?? 'query_default_error'.tr);
    }
  });
}
