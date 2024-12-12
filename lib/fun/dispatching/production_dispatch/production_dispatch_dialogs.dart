import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../bean/http/response/manufacture_instructions_info.dart';
import '../../../bean/http/response/order_color_info.dart';
import '../../../bean/http/response/production_dispatch_order_detail_info.dart';
import '../../../bean/http/response/work_plan_material_info.dart';
import '../../../bean/http/response/worker_info.dart';
import '../../../utils/utils.dart';
import '../../../widget/custom_widget.dart';
import '../../../widget/dialogs.dart';
import '../../../widget/edit_text_widget.dart';
import '../../../widget/web_page.dart';

showDispatchList(
  BuildContext context,
  bool isLast,
  List<WorkCardList> list,
  Function(int i1, int i2) modify,
) {
  var items = <ShowDispatch>[];
  list.forEachIndexed((i1, wc) {
    if (isLast) {
      if (wc.finishQty! > 0) {
        items.add(ShowDispatch(
          groupIndex: 0,
          subIndex: 0,
          processName: wc.processName ?? '',
          processNumber: wc.processNumber ?? '',
          name: wc.workerName ?? '',
          qty: wc.finishQty ?? 0.0,
        ));
      }
    } else {
      wc.dispatch.forEachIndexed((i2, d) {
        if (d.qty! > 0) {
          items.add(ShowDispatch(
            groupIndex: i1,
            subIndex: i2,
            processName: wc.processName ?? '',
            processNumber: wc.processNumber ?? '',
            name: d.name!,
            qty: d.qty!,
          ));
        }
      });
    }
  });
  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        title: Row(
          children: [
            Expanded(child: Text(isLast ? '上次派工' : '本次派工')),
            IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(
                Icons.clear,
                color: Colors.red,
              ),
            )
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) => GestureDetector(
              onTap: () {
                if (isLast) return;
                Get.back();
                modify.call(items[index].groupIndex, items[index].subIndex);
              },
              child: Container(
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: index % 2 != 0
                      ? Colors.blue.shade200
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '<${items[index].processNumber}>${items[index].processName}',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    Text(
                      '${items[index].name}(${isLast ? '已计工数：' : '计工数：'}${items[index].qty})',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
    barrierDismissible: false, //拦截dialog外部点击
  );
}

_addNewWorkerDialog(
  List<WorkerInfo> workers,
  Function(WorkerInfo wi) callback,
) {
  var name = ''.obs;
  WorkerInfo? newWorker;
  Get.dialog(PopScope(
    canPop: false,
    child: AlertDialog(
      title: const Text('添加临时组员'),
      content: SizedBox(
        width: 200,
        height: 90,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text(
                    name.value,
                    style: const TextStyle(color: Colors.blueAccent),
                  ),
                )),
            NumberEditText(
              hasFocus: true,
              hint: '请输入员工工号',
              onChanged: (s) {
                if (s.length >= 6) {
                  getWorkerInfo(
                    number: s,
                    workers: (list) {
                      if (workers.any((v) => v.empID == list[0].empID)) {
                        name.value = '员工《${list[0].empName}》已存在。';
                        newWorker = null;
                      } else {
                        newWorker = list[0];
                        name.value = list[0].empName ?? '';
                      }
                    },
                    error: (msg) => errorDialog(content: msg),
                  );
                }
              },
            )
          ],
        ),
      ),
      actions: [
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
  ));
}

addWorkerDialog(
  List<WorkerInfo> workers,
  List<int> select,
  Function(List<int>) callback,
) {
  Get.dialog(PopScope(
    canPop: false,
    child: StatefulBuilder(builder: (context, dialogSetState) {
      return AlertDialog(
        title: Row(
          children: [
            const Expanded(child: Text('选择组员')),
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
          width: MediaQuery.of(context).size.width * 0.5,
          height: MediaQuery.of(context).size.height * 0.5,
          child: GridView.builder(
            itemCount: workers.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // 网格的列数
            ),
            itemBuilder: (BuildContext context, int index) {
              var item = workers[index];
              return GestureDetector(
                onTap: () {
                  dialogSetState(() {
                    if (select.contains(item.empID)) {
                      select.remove(item.empID);
                    } else {
                      select.add(item.empID ?? 0);
                    }
                  });
                },
                child: Card(
                  color: select.contains(item.empID)
                      ? Colors.green.shade100
                      : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: item.picUrl == null ||
                                  item.picUrl?.isEmpty == true
                              ? Icon(
                                  Icons.account_circle_rounded,
                                  color: Colors.grey.shade400,
                                  size:
                                      MediaQuery.of(context).size.width * 0.08,
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(7),
                                  child: Image.network(
                                    item.picUrl ?? '',
                                  ),
                                ),
                        ),
                        Text(
                          item.empCode ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          item.empName ?? '',
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              callback.call(select);
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

modifyDispatchQtyDialog(
  DispatchInfo di,
  double surplus,
  Function(DispatchInfo) callback,
) {
  var qty = 0.0;
  Get.dialog(PopScope(
    canPop: false,
    child: AlertDialog(
      title: Text('派工'),
      content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('<${di.processNumber}>${di.processName}'),
              Text('<${di.number}>${di.name}'),
              Text(
                '本次计工(剩余可计工数:${surplus.toShowString()})',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              NumberDecimalEditText(
                hint: '请输入要计工的数量',
                max: surplus,
                initQty: di.qty,
                hasFocus: true,
                onChanged: (v) {
                  qty = v;
                },
              ),
            ],
          )),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            di.qty = qty;
            callback.call(di);
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
  ));
}

///获取批量修改派工dialog提示文本
String detailViewSetDispatchDialogText(
  bool isCheckedDivideEqually,
  bool isCheckedRounding,
  List<DispatchInfo> selectList,
  double qty,
) {
  if (isCheckedDivideEqually) {
    if (isCheckedRounding) {
      var integer = qty ~/ selectList.length;
      var decimal = (qty % selectList.length).toInt();
      return '均分${qty.toShowString()}并取整，一共${selectList.length}人，每人$integer，剩余$decimal分配给第一个人。';
    } else {
      var average = qty.div(selectList.length.toDouble());
      return '均分${qty.toShowString()}，一共${selectList.length}人，每人${average.toShowString()}。';
    }
  } else {
    var total = qty.mul(selectList.length.toDouble());
    return '一共${selectList.length}人，每人派工${qty.toShowString()}。共计派工${total.toShowString()}';
  }
}

batchModifyDispatchQtyDialog(
  bool isCheckedDivideEqually,
  bool isCheckedRounding,
  List<DispatchInfo> dil,
  double surplus,
  Function(double) callback,
) {
  var inputMax =
      isCheckedDivideEqually ? surplus : surplus.div(dil.length.toDouble());
  var qty = 0.0;
  var showText = detailViewSetDispatchDialogText(
    isCheckedDivideEqually,
    isCheckedRounding,
    dil,
    0,
  ).obs;
  Get.dialog(PopScope(
    canPop: false,
    child: AlertDialog(
      title: Text('派工'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('<${dil[0].processNumber}>${dil[0].processName}'),
            Obx(() => Text(showText.value)),
            Text(
              '本次计工(剩余可计工数:${surplus.toShowString()})',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            NumberDecimalEditText(
              hint: '请输入要计工的数量',
              max: inputMax,
              initQty: qty,
              hasFocus: true,
              onChanged: (v) {
                qty = v;
                showText.value = detailViewSetDispatchDialogText(
                  isCheckedDivideEqually,
                  isCheckedRounding,
                  dil,
                  v,
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            callback.call(qty);
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
  ));
}

typeBodySaveDialog(
  List<SaveWorkProcedure> list,
  SaveWorkProcedure Function() save,
  Function(SaveWorkProcedure) apply,
) {
  var selected = -1;
  Get.dialog(PopScope(
    canPop: false,
    child: StatefulBuilder(builder: (context, dialogSetState) {
      return AlertDialog(
        title: Text('选择你要应用的形体'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          height: MediaQuery.of(context).size.height * 0.5,
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: list.length + 1,
            itemBuilder: (BuildContext context, int index) => GestureDetector(
              onTap: () {
                if (index == list.length) {
                  dialogSetState(() => list.add(save.call()));
                } else {
                  dialogSetState(() {
                    selected = index;
                  });
                }
              },
              child: Container(
                height: 50,
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: index == list.length
                      ? Colors.orange.shade100
                      : selected == index
                          ? Colors.blue.shade100
                          : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected == index
                        ? Colors.green.shade200
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: index == list.length
                    ? const Center(child: Text('保存当前工序'))
                    : Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Text(
                              list[index].plantBody ?? '',
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                          Text(
                            list[index].saveTime ?? '',
                            style: const TextStyle(color: Colors.black),
                          ),
                          IconButton(
                            onPressed: () {
                              list[index].delete(() {
                                dialogSetState(() {
                                  list.removeAt(index);
                                  if (selected == index) selected = -1;
                                });
                              });
                            },
                            padding: const EdgeInsets.all(0),
                            icon: const Icon(
                              Icons.delete_forever_rounded,
                              color: Colors.redAccent,
                              size: 25,
                            ),
                          )
                        ],
                      ),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              if (selected != -1) {
                apply.call(list[selected]);
              }
            },
            child: Text('应用'),
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

manufactureInstructionsDialog(List<ManufactureInstructionsInfo> files) {
  var selected = -1.obs;
  Get.dialog(
    PopScope(
        canPop: false,
        child: StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              title: Text('选择要查看的工艺指导书'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.5,
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: files.length,
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () => dialogSetState(() => selected = index),
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: selected == index
                            ? Colors.blue.shade100
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected == index
                              ? Colors.green.shade200
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          files[index].name ?? '',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (selected == -1) {
                      showSnackBar(title: '查看工艺指导书', message: '请选择要查看的文件');
                    } else {
                      Get.back();
                      Get.to(() => WebPage(
                            title: files[selected].name ?? '',
                            url: files[selected].url ?? '',
                          ));
                    }
                  },
                  child: Text('查看'),
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
        )),
  );
}

colorListDialog(List<OrderColorList> files, Function(String) callback) {
  var selected = -1.obs;
  Get.dialog(
    PopScope(
        canPop: false,
        child: StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              title: Text('配色单列表'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.5,
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: files.length,
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () => dialogSetState(() => selected = index),
                    child: Container(
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: selected == index
                            ? Colors.blue.shade100
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected == index
                              ? Colors.green.shade200
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(files[index].vNumber ?? '')),
                              Text(files[index].materialCode ?? ''),
                            ],
                          ),
                          Text(files[index].materialName ?? '')
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    '返回',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (selected == -1) {
                      showSnackBar(title: '查看配色单', message: '请选择要查看的文件');
                    } else {
                      callback.call(files[selected].materialCode ?? '');
                    }
                  },
                  child: Text('查看'),
                ),
              ],
            );
          },
        )),
  );
}

sapReportDialog(double initQty, Function(double) callback) {
  var qty = initQty;
  Get.dialog(
    PopScope(
      canPop: false,
      child: StatefulBuilder(
        builder: (context, dialogSetState) {
          return AlertDialog(
            title: Text('报工数量'),
            content: SizedBox(
              width: 300,
              child: NumberDecimalEditText(
                hint: '请输入报工的数量',
                max: initQty,
                initQty: qty,
                hasFocus: true,
                onChanged: (v) => qty = v,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                  callback.call(qty);
                },
                child: Text('报工'),
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

workPlanMaterialDialog(List<WorkPlanMaterialInfo> list) {
  Get.dialog(
    PopScope(
        canPop: false,
        child: StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              title: Text('用料清单列表'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.6,
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: list.length,
                  itemBuilder: (context, index) => Container(
                    height: 55,
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.only(
                        left: 10, top: 5, right: 10, bottom: 5),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                              '${list[index].name}<${list[index].code}>',
                              style: TextStyle(
                                  color: Colors.blue.shade900,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text('规格型号:${list[index].model}'),
                            ),
                            Expanded(child: Text('颜色:${list[index].color}')),
                            Expanded(
                              child: Text(
                                  '数量:${list[index].needQty}${list[index].unit}'),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text(
                    '返回',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            );
          },
        )),
  );
}

///报功到sap
reportToSap(Function(bool isInstructionReport) callback) {
  var isInstructionReport = true.obs;
  Get.dialog(
    PopScope(
      //拦截返回键
      canPop: false,
      child: AlertDialog(
        title: Text('请选择报工方式'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Obx(() => Checkbox(
                      value: isInstructionReport.value,
                      onChanged: (v) => isInstructionReport.value = v!,
                    )),
                GestureDetector(
                  onTap: () {
                    isInstructionReport.value = !isInstructionReport.value;
                  },
                  child: Text('指令报工'),
                )
              ],
            ),
            Row(
              children: [
                Obx(() => Checkbox(
                      value: !isInstructionReport.value,
                      onChanged: (v) => isInstructionReport.value = !v!,
                    )),
                GestureDetector(
                  onTap: () {
                    isInstructionReport.value = !isInstructionReport.value;
                  },
                  child: Text('尺码报工'),
                )
              ],
            )
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Get.back();
              callback.call(isInstructionReport.value);
            },
            child: Text('dialog_default_confirm'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text(
              'dialog_default_cancel'.tr,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    ),
    barrierDismissible: false, //拦截dialog外部点击
  );
}

showSelectMaterialPopup(List<Map> list) {
  var controller = FixedExtentScrollController();
  Get.dialog(
    PopScope(
      //拦截返回键
      canPop: false,
      child: AlertDialog(
        title: Text('选择要打印的料头'),
        content: SizedBox(
          width: 300,
          height: 200,
          child: getCupertinoPicker(
            list.map((data) {
              return Center(child: Text(data['StubBarName']));
            }).toList(),
            controller,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('打印'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text(
              'dialog_default_cancel'.tr,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    ),
    barrierDismissible: false, //拦截dialog外部点击
  );
}
