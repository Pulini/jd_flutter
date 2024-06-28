import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/utils.dart';

import '../../bean/http/request/maintain_label_create.dart';
import '../../bean/http/request/maintain_label_set.dart';
import '../../bean/http/response/maintain_material_info.dart';
import '../../bean/http/response/picking_bar_code_info.dart';
import '../../web_api.dart';
import '../../widget/custom_widget.dart';
import '../../widget/dialogs.dart';

createMixLabelDialog(
    List<PickingBarCodeInfo> list, int id, Function() callback) {
  var group = <List<PickingBarCodeInfo>>[];
  groupBy(list, (v) => v.size).forEach((key, value) {
    group.add(value);
  });
  var maxLabel = 0.obs;
  var controller = TextEditingController();
  var selected = <List<RxBool>>[];
  for (var v1 in group) {
    var select = <RxBool>[];
    for (var _ in v1) {
      select.add(false.obs);
    }
    selected.add(select);
  }
  Get.dialog(
    PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text('创建混码标签'),
          content: SizedBox(
            width: MediaQuery.of(Get.overlayContext!).size.width * 0.8,
            height: MediaQuery.of(Get.overlayContext!).size.height * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text('最大标签数：'),
                    Expanded(
                        child: NumberEditText(
                      onChanged: (s) {
                        if (s.toDoubleTry() > maxLabel.value) {
                          controller.text = maxLabel.value.toString();
                        }
                      },
                      controller: controller,
                    )),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: group.length,
                    itemBuilder: (context, index) => _createMixLabelItem(
                        selected, group, index, maxLabel, controller),
                  ),
                ),
              ],
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
            TextButton(
              onPressed: () => _createMixLabel(
                selected,
                group,
                maxLabel.value,
                id,
                () {
                  Get.back();
                  callback.call();
                },
              ),
              child: const Text('创建'),
            ),
          ],
        )),
  );
}

_createMixLabel(
  List<List<RxBool>> selected,
  List<List<PickingBarCodeInfo>> list,
  int maxLabel,
  int id,
  Function() callback,
) {
  if (!selected.any((v1) => v1.any((v2) => v2.value))) {
    showSnackBar(title: '错误', message: '请勾选要创建的指令和尺码', isWarning: true);
    return;
  }
  if (maxLabel == 0) {
    showSnackBar(title: '错误', message: '可生产贴标数未0', isWarning: true);
    return;
  }
  var size = <MaintainLabelCreateMixSub>[];
  for (var i = 0; i < selected.length; ++i) {
    for (var j = 0; j < selected[i].length; ++j) {
      if (selected[i][j].value) {
        size.add(MaintainLabelCreateMixSub(
          size: list[i][j].size ?? '',
          capacity: list[i][j].packingQty.toShowString(),
          mtoNo: list[i][j].interID.toString(),
        ));
      }
    }
  }
  httpPost(
    method: webApiCreateMixLabel,
    loading: '正在生成贴标...',
    body: MaintainLabelCreateMix(
      interID: id.toString(),
      barcodeQty: maxLabel,
      userID: userInfo?.userID ?? 0,
      sizeList: size,
      labelTyp: '3',
    ),
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      successDialog(content: response.message, back: () => callback.call());
    } else {
      errorDialog(content: response.message);
    }
  });
}

_createMixLabelItem(
  List<List<RxBool>> selected,
  List<List<PickingBarCodeInfo>> list,
  int index,
  RxInt maxLabel,
  TextEditingController controller,
) {
  return Obx(() => Card(
        color: selected[index].where((v) => v.value).length ==
                selected[index].length
            ? Colors.greenAccent.shade100
            : Colors.white,
        child: ExpansionTile(
          initiallyExpanded: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          leading: Checkbox(
            value: selected[index].where((v) => v.value).length ==
                selected[index].length,
            onChanged: (c) {
              for (var i = 0; i < selected[index].length; ++i) {
                selected[index][i].value = c!;
              }
              maxLabel.value = _getLabelMax(selected, list);
              controller.text = maxLabel.toString();
            },
          ),
          title: Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: '尺码：',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: list[index][0].size,
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          children: [
            for (var i = 0; i < list[index].length; ++i)
              _createMixLabelSubItem(
                selected,
                list,
                index,
                i,
                maxLabel,
                controller,
              )
          ],
        ),
      ));
}

_createMixLabelSubItem(
  List<List<RxBool>> selected,
  List<List<PickingBarCodeInfo>> list,
  int index,
  int i,
  RxInt maxLabel,
  TextEditingController controller,
) {
  var style = const TextStyle(fontSize: 14, fontWeight: FontWeight.bold);
  var checkbox = Checkbox(
    value: selected[index][i].value,
    onChanged: (c) {
      selected[index][i].value = c!;
      maxLabel.value = _getLabelMax(selected, list);
      controller.text = maxLabel.toString();
    },
  );
  var number = NumberDecimalEditText(
    onChanged: (v) {
      list[index][i].packingQty = v;
      maxLabel.value = _getLabelMax(selected, list);
      controller.text = maxLabel.toString();
    },
    initQty: list[index][i].packingQty,
  );
  return Column(
    children: [
      ListTile(
        leading: checkbox,
        title: Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                  text: '指令：', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                text: list[index][i].mtono,
                style: TextStyle(
                  color: Colors.green.shade900,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        subtitle: Text(
          '剩余数：${list[index][i].getSurplusQty().toShowString()}',
        ),
        trailing: SizedBox(
          width: 180,
          child: Row(
            children: [
              Text('装箱数：', style: style),
              Expanded(
                  child: selected[index][i].value
                      ? number
                      : Text('0', style: style)),
            ],
          ),
        ),
      ),
      if (i < list[index].length - 1)
        const Divider(
          indent: 20,
          endIndent: 20,
          height: 1,
        ),
    ],
  );
}

int _getLabelMax(
  List<List<RxBool>> selected,
  List<List<PickingBarCodeInfo>> list,
) {
  var max = 0;
  for (var i = 0; i < selected.length; ++i) {
    for (var j = 0; j < selected[i].length; ++j) {
      if (selected[i][j].value) {
        var m = list[i][j].maxLabel();
        if (max == 0 || max > m) max = m;
      }
    }
  }
  return max;
}

createCustomLabelDialog(
  List<PickingBarCodeInfo> list,
  int id,
  isMaterialLabel,
  Function() callback,
) {
  var selected = <bool>[].obs;
  var capacity = <double>[].obs;
  var createGoods = <double>[].obs;
  var create = <int>[].obs;
  for (var v in list) {
    selected.add(false);
    var surplus = v.totalQty.sub(v.qty ?? 0);
    if (surplus < 100) {
      capacity.add(surplus);
      createGoods.add(surplus);
      create.add(_createLabel(surplus, surplus));
    } else {
      capacity.add(100);
      createGoods.add(100);
      create.add(_createLabel(100, 100));
    }
  }
  Get.dialog(
    PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text('创建自定义标签'),
          content: SizedBox(
            width: MediaQuery.of(Get.overlayContext!).size.width * 0.8,
            height: MediaQuery.of(Get.overlayContext!).size.height * 0.8,
            child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: list.length,
                itemBuilder: (context, index) => _createCustomLabelItem(
                      index,
                      list,
                      selected,
                      capacity,
                      createGoods,
                      create,
                    )),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                '返回',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () => _createCustomLabel(
                list,
                selected,
                capacity,
                createGoods,
                id,
                isMaterialLabel,
                () {
                  Get.back();
                  callback.call();
                },
              ),
              child: Text('创建'),
            ),
          ],
        )),
  );
}

_createCustomLabelItem(
  int index,
  List<PickingBarCodeInfo> list,
  RxList<bool> selected,
  RxList<double> capacity,
  RxList<double> createGoods,
  RxList<int> create,
) {
  var surplus = list[index].totalQty.sub(list[index].qty ?? 0);

  return Obx(
    () => Card(
      color: selected[index] ? Colors.greenAccent.shade100 : Colors.white,
      child: ListTile(
        leading: Checkbox(
          value: selected[index],
          onChanged: (c) => selected[index] = c!,
        ),
        title: Row(
          children: [
            _textSpan(
              flex: 2,
              hint: '尺码：',
              text: list[index].size ?? '',
              textColor: Colors.redAccent,
            ),
            _textSpan(
              flex: 2,
              hint: '已生成贴标：',
              text: list[index].labelCount.toString(),
              textColor: Colors.black45,
            ),
            _textSpan(
              hint: '创建：',
              text: create[index].toString(),
              textColor: Colors.green,
            )
          ],
        ),
        subtitle: Column(
          children: [
            Row(
              children: [
                _textSpan(
                  flex: 2,
                  hint: '总货数：',
                  text: list[index].totalQty.toShowString(),
                ),
                _textSpan(
                  flex: 2,
                  hint: '已生成数：',
                  text: list[index].qty.toShowString(),
                ),
                _textSpan(
                  hint: '剩余货数：',
                  text: surplus.toShowString(),
                )
              ],
            ),
            SizedBox(
              height: 50,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Text(
                          '箱容：',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black45,
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: NumberDecimalEditText(
                            initQty: capacity[index],
                            onChanged: (c) {
                              capacity[index] = c;
                              create[index] = _createLabel(
                                capacity[index],
                                createGoods[index],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Text(
                          '本次生成货数：',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black45,
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: NumberDecimalEditText(
                            initQty: createGoods[index],
                            onChanged: (c) {
                              createGoods[index] = c;
                              create[index] = _createLabel(
                                capacity[index],
                                createGoods[index],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        CombinationButton(
                          text: '填满',
                          click: () {
                            capacity[index] = surplus;
                            createGoods[index] = surplus;
                            create[index] = _createLabel(
                              capacity[index],
                              createGoods[index],
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    ),
  );
}

_createCustomLabel(
  List<PickingBarCodeInfo> list,
  RxList<bool> selected,
  RxList<double> capacity,
  RxList<double> createGoods,
  int id,
  bool isMaterialLabel,
  Function() callback,
) {
  if (!selected.any((v1) => v1)) {
    showSnackBar(title: '错误', message: '请勾选要创建的尺码', isWarning: true);
    return;
  }
  var size = <MaintainLabelCreateCustomSub>[];
  for (var i = 0; i < selected.length; ++i) {
    if (selected[i]) {
      size.add(MaintainLabelCreateCustomSub(
        size: list[i].size ?? '',
        capacity: capacity[i].toShowString(),
        qty: createGoods[i].toShowString(),
      ));
    }
  }
  Future<BaseData> post;
  if (isMaterialLabel) {
    post = httpPost(
      method: webApiCreateCustomLargeLabel,
      loading: '正在生成贴标...',
      body: MaintainLabelCreateCustom(
        interID: id.toString(),
        userID: userInfo?.userID ?? 0,
        sizeList: size,
        labelTyp: '2',
      ),
    );
  } else {
    post = httpPost(
      method: webApiCreateCustomSizeLabel,
      loading: '正在生成贴标...',
      body: MaintainLabelCreateCustom(
        interID: id.toString(),
        userID: userInfo?.userID ?? 0,
        sizeList: size,
        labelTyp: '2',
      ),
    );
  }
  logger.f(MaintainLabelCreateCustom(
    interID: id.toString(),
    userID: userInfo?.userID ?? 0,
    sizeList: size,
    labelTyp: '2',
  ).toJson());
  post.then((response) {
    if (response.resultCode == resultSuccess) {
      successDialog(content: response.message, back: () => callback.call());
    } else {
      errorDialog(content: response.message);
    }
  });
}

_textSpan({
  required String hint,
  Color hintColor = Colors.black,
  required String text,
  Color textColor = Colors.blueAccent,
  int flex = 1,
}) {
  return Expanded(
      flex: flex,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: hint,
              style: TextStyle(fontWeight: FontWeight.bold, color: hintColor),
            ),
            TextSpan(
              text: text,
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ));
}

int _createLabel(double capacity, double createGoods) {
  if (capacity > 0.0 && createGoods > 0.0) {
    return (createGoods.div(capacity).toInt()).ceil();
  } else {
    return 0;
  }
}

setLabelPropertyDialog(
  RxList<MaintainMaterialInfo> list,
  int id,
  String materialCode,
  Function() callback,
) {
  Get.dialog(
    PopScope(
        canPop: false,
        child: AlertDialog(
          title: Row(
            children: [
              Expanded(child: Text('标签属性配置')),
              CombinationButton(
                text: '批量修改',
                click: () => batchSetLabelPropertyDialog(
                  (netWeight, grossWeight, meas, unitName) {
                    var item = <MaintainLabelSetPropertiesSub>[];
                    for (var data in list) {
                      item.add(MaintainLabelSetPropertiesSub(
                        size: data.size ?? '',
                        netWeight: netWeight.toShowString(),
                        grossWeight: grossWeight.toShowString(),
                        meas:meas,
                        unitName: unitName,
                      ));
                    }
                    _setMaterialProperties(item, id, materialCode, () =>Get.back());
                  },
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(Get.overlayContext!).size.width * 0.8,
            height: MediaQuery.of(Get.overlayContext!).size.height * 0.8,
            child: Obx(() => ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: list.length,
                  itemBuilder: (context, index) =>
                      _setLabelPropertyItem(list[index]),
                )),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                '返回',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                if (list.any((v) => v.ifNull())) {
                  showSnackBar(title: '错误', message: '重量必须大于0',isWarning: true);
                } else {
                  var item = <MaintainLabelSetPropertiesSub>[];
                  for (var data in list) {
                    item.add(MaintainLabelSetPropertiesSub(
                      size: data.size ?? '',
                      netWeight: data.netWeight ?? '0',
                      grossWeight: data.grossWeight ?? '0',
                      meas: data.meas ?? '',
                      unitName: data.unitName ?? '',
                    ));
                  }
                  _setMaterialProperties(item, id, materialCode, () =>Get.back());
                }
              },
              child: Text('修改'),
            ),
          ],
        )),
  );
}

_setLabelPropertyItem(MaintainMaterialInfo data) {
  return Card(
    child: Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '尺码：',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: data.size ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 50,
            child: Row(
              children: [
                _expandedNumberEditText(
                  '净重：',
                  data.netWeight.toDoubleTry(),
                  (s) => data.netWeight = s.toShowString(),
                ),
                _expandedNumberEditText(
                  '毛重：',
                  data.grossWeight.toDoubleTry(),
                  (s) => data.grossWeight = s.toShowString(),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 50,
            child: Row(
              children: [
                _expandedEditText(
                  '规格：',
                  data.meas ?? '',
                  (s) => data.meas = s,
                ),
                _expandedEditText(
                  '单位：',
                  data.unitName ?? '',
                  (s) => data.unitName = s,
                ),
              ],
            ),
          )
        ],
      ),
    ),
  );
}

batchSetLabelPropertyDialog(
  Function(
    double netWeight,
    double grossWeight,
    String meas,
    String unitName,
  ) callback,
) {
  double nw = 0.0;
  double gw = 0.0;
  String meas = '';
  String unit = '';
  Get.dialog(
    PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text('批量修改属性'),
          content: SizedBox(
            width: 240,
            height: 200,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _expandedNumberEditText('净重：', nw, (s) => nw = s),
                _expandedNumberEditText('毛重：', gw, (s) => gw = s),
                _expandedEditText('规格：', meas, (s) => meas = s),
                _expandedEditText('单位：', unit, (s) => unit = s),
              ],
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
            TextButton(
              onPressed: () {
                if (nw <= 0 || gw <= 0) {
                  showSnackBar(
                    title: '错误',
                    message: '请完整填写修改内容',
                    isWarning: true,
                  );
                } else {
                  callback.call(nw, gw, meas, unit);
                  Get.back();
                }
              },
              child: Text('修改'),
            ),
          ],
        )),
  );
}

_setMaterialProperties(
    List<MaintainLabelSetPropertiesSub> list,
  int id,
  String materialCode,
  Function() callback,
) {

  httpPost(
    method: webApiSetMaterialProperties,
    loading: '正在设置物料属性信息...',
    body: MaintainLabelSetProperties(
      userID: userInfo?.userID ?? 0,
      interID: id.toString(),
      materialCode: materialCode,
      items: list,
    ),
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      successDialog(content: response.message, back: () => callback.call());
    } else {
      errorDialog(content: response.message);
    }
  });
}

_expandedNumberEditText(
  String hint,
  double initQty,
  Function(double) callback,
) {
  return Expanded(
    child: Row(
      children: [
        Text(
          hint,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black45,
          ),
        ),
        Expanded(
          child: NumberDecimalEditText(
            initQty: initQty,
            onChanged: (c) {
              callback.call(c);
            },
          ),
        ),
      ],
    ),
  );
}

_expandedEditText(
  String hint,
  String initStr,
  Function(String) callback,
) {
  return Expanded(
    child: Row(
      children: [
        Text(
          hint,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black45,
          ),
        ),
        Expanded(
          child: EditText(
            initStr: initStr,
            onChanged: (c) {
              callback.call(c);
            },
          ),
        ),
      ],
    ),
  );
}

showSelectMaterialPopup(List<String> list, Function(String) callback) {
  var controller = FixedExtentScrollController();
  Get.dialog(
    PopScope(
      //拦截返回键
      canPop: false,
      child: AlertDialog(
        title: Text('选择尺码'),
        content: SizedBox(
          width: 200,
          height: 100,
          child: getCupertinoPicker(
            list.map((data) {
              return Center(child: Text(data));
            }).toList(),
            controller,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text(
              'dialog_default_cancel'.tr,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              callback.call(list[controller.selectedItem]);
            },
            child: Text('dialog_default_confirm'.tr),
          ),
        ],
      ),
    ),
    barrierDismissible: false, //拦截dialog外部点击
  );
}

createLabelSelect({
  required Function() single,
  required Function() mix,
  required Function() custom,
}) {
  showCupertinoModalPopup(
    context: Get.overlayContext!,
    builder: (context) => CupertinoActionSheet(
      title: Text(
        '创建贴标',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      message: Text('选择标签类型'),
      actions: [
        CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Get.back();
            single.call();
          },
          child: Text('单码'),
        ),
        CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Get.back();
            mix.call();
          },
          child: Text('混码'),
        ),
        CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Get.back();
            custom.call();
          },
          child: Text('自定义'),
        ),
        CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Get.back(),
          child: Text(
            'dialog_default_cancel'.tr,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    ),
  );
}

setLabelSelect({
  required Function() property,
  required Function() boxCapacity,
  required Function() language,
}) {
  showCupertinoModalPopup(
    context: Get.overlayContext!,
    builder: (context) => CupertinoActionSheet(
      title: Text(
        '设置',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      message: Text('选择设置内容'),
      actions: [
        CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Get.back();
            property.call();
          },
          child: Text('属性'),
        ),
        CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Get.back();
            boxCapacity.call();
          },
          child: Text('箱容'),
        ),
        CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Get.back();
            language.call();
          },
          child: Text('语言'),
        ),
        CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Get.back(),
          child: Text(
            'dialog_default_cancel'.tr,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    ),
  );
}
