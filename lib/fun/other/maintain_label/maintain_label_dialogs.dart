import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/maintain_material_info.dart';
import 'package:jd_flutter/bean/http/response/picking_bar_code_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';

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
          title: Text('maintain_label_dialog_create_mix_label'.tr),
          content: SizedBox(
            width: MediaQuery.of(Get.overlayContext!).size.width * 0.8,
            height: MediaQuery.of(Get.overlayContext!).size.height * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text('maintain_label_dialog_max_label_qty'.tr),
                    Expanded(
                      child: NumberEditText(
                        onChanged: (s) {
                          if (s.toDoubleTry() > maxLabel.value) {
                            controller.text = maxLabel.value.toString();
                          }
                        },
                        controller: controller,
                      ),
                    ),
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
              child: Text(
                'maintain_label_dialog_back'.tr,
                style: const TextStyle(color: Colors.grey),
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
              child: Text('maintain_label_dialog_create'.tr),
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
    showSnackBar(
      message: 'maintain_label_dialog_select_instruction_and_size'.tr,
      isWarning: true,
    );
    return;
  }
  if (maxLabel == 0) {
    showSnackBar(
      message: 'maintain_label_dialog_cant_generate'.tr,
      isWarning: true,
    );
    return;
  }

  httpPost(
    method: webApiCreateMixLabel,
    loading: 'maintain_label_dialog_generating_label'.tr,
    body: {
      'InterID': id.toString(),
      'BarcodeQty': maxLabel,
      'UserID': userInfo?.userID,
      'SizeList': [
        for (var i = 0; i < selected.length; ++i)
          for (var j = 0; j < selected[i].length; ++j)
            if (selected[i][j].value)
              {
                'Size': list[i][j].size,
                'Capacity': list[i][j].packingQty.toShowString(),
                'MtoNo': list[i][j].interID.toString(),
              }
      ],
      'LabelTyp': '3',
    },
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
                TextSpan(
                  text: 'maintain_label_dialog_size'.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold),
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
              TextSpan(
                text: 'maintain_label_dialog_instruction'.tr,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
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
        subtitle: Text('maintain_label_dialog_surplus_qty'.trArgs([
          list[index][i].getSurplusQty().toShowString(),
        ])),
        trailing: SizedBox(
          width: 180,
          child: Row(
            children: [
              Text('maintain_label_dialog_packing_qty'.tr, style: style),
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
          title: Text('maintain_label_dialog_create_customize_label'.tr),
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
              child: Text(
                'maintain_label_dialog_back'.tr,
                style: const TextStyle(color: Colors.grey),
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
              child: Text('maintain_label_dialog_create'.tr),
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
            expandedTextSpan(
              flex: 2,
              hint: 'maintain_label_dialog_size'.tr,
              text: list[index].size ?? '',
              textColor: Colors.redAccent,
            ),
            expandedTextSpan(
              flex: 2,
              hint: 'maintain_label_dialog_generated_label'.tr,
              text: list[index].labelCount.toString(),
              textColor: Colors.black45,
            ),
            expandedTextSpan(
              hint: 'maintain_label_dialog_generate'.tr,
              text: create[index].toString(),
              textColor: Colors.green,
            )
          ],
        ),
        subtitle: Column(
          children: [
            Row(
              children: [
                expandedTextSpan(
                  flex: 2,
                  hint: 'maintain_label_dialog_total_qty'.tr,
                  text: list[index].totalQty.toShowString(),
                ),
                expandedTextSpan(
                  flex: 2,
                  hint: 'maintain_label_dialog_generated_qty'.tr,
                  text: list[index].qty.toShowString(),
                ),
                expandedTextSpan(
                  hint: 'maintain_label_dialog_surplus_goods_qty'.tr,
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
                          'maintain_label_dialog_box_capacity'.tr,
                          style: const TextStyle(
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
                          'maintain_label_dialog_generated_goods_qty'.tr,
                          style: const TextStyle(
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
                          text: 'maintain_label_dialog_full'.tr,
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
    showSnackBar(
      message: 'maintain_label_dialog_select_size_tips'.tr,
      isWarning: true,
    );
    return;
  }
  var body = {
    'InterID': id.toString(),
    'UserID': userInfo?.userID ?? 0,
    'SizeList': [
      for (var i = 0; i < selected.length; ++i)
        if (selected[i])
          {
            'Size': list[i].size ?? '',
            'Capacity': capacity[i].toShowString(),
            'Qty': createGoods[i].toShowString(),
          }
    ],
    'LabelTyp': '2',
  };
  Future<BaseData> post;
  if (isMaterialLabel) {
    post = httpPost(
      method: webApiCreateCustomLargeLabel,
      loading: 'maintain_label_dialog_generating_label'.tr,
      body: body,
    );
  } else {
    post = httpPost(
      method: webApiCreateCustomSizeLabel,
      loading: 'maintain_label_dialog_generating_label'.tr,
      body: body,
    );
  }
  post.then((response) {
    if (response.resultCode == resultSuccess) {
      successDialog(content: response.message, back: () => callback.call());
    } else {
      errorDialog(content: response.message);
    }
  });
}

int _createLabel(double capacity, double createGoods) {
  if (capacity > 0.0 && createGoods > 0.0) {
    return (createGoods.div(capacity).toInt()).ceil();
  } else {
    return 0;
  }
}

setLabelPropertyDialog(
  RxList<MaintainMaterialPropertiesInfo> list,
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
              Expanded(
                child: Text('maintain_label_dialog_label_attribute_config'.tr),
              ),
              CombinationButton(
                text: 'maintain_label_dialog_batch_modify'.tr,
                click: () => batchSetLabelPropertyDialog(
                  (netWeight, grossWeight, meas, unitName) {
                    var item = <Map>[];
                    for (var data in list) {
                      item.add({
                        'Size': data.size ?? '',
                        'NetWeight': netWeight.toShowString(),
                        'GrossWeight': grossWeight.toShowString(),
                        'Meas': meas,
                        'UnitName': unitName,
                      });
                    }
                    _setMaterialProperties(
                        item, id, materialCode, () => Get.back());
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
              child: Text(
                'maintain_label_dialog_back'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                if (list.any((v) => v.ifNull())) {
                  showSnackBar(
                    message:
                        'maintain_label_dialog_weight_mast_greater_zero'.tr,
                    isWarning: true,
                  );
                } else {
                  var item = <Map>[];
                  for (var data in list) {
                    item.add({
                      'Size': data.size ?? '',
                      'NetWeight': data.netWeight ?? '0',
                      'GrossWeight': data.grossWeight ?? '0',
                      'Meas': data.meas ?? '',
                      'UnitName': data.unitName ?? '',
                    });
                  }
                  _setMaterialProperties(
                    item,
                    id,
                    materialCode,
                    () {
                      Get.back();
                      callback.call();
                    },
                  );
                }
              },
              child: Text('maintain_label_dialog_modify'.tr),
            ),
          ],
        )),
  );
}

_setLabelPropertyItem(MaintainMaterialPropertiesInfo data) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'maintain_label_dialog_size'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: data.size ?? '',
                  style: const TextStyle(
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
                  'maintain_label_dialog_net_weight'.tr,
                  data.netWeight.toDoubleTry(),
                  (s) => data.netWeight = s.toShowString(),
                ),
                _expandedNumberEditText(
                  'maintain_label_dialog_gross_weight'.tr,
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
                  'maintain_label_dialog_specifications'.tr,
                  data.meas ?? '',
                  (s) => data.meas = s,
                ),
                _expandedEditText(
                  'maintain_label_dialog_unit'.tr,
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
  var nw = 0.0.obs;
  var gw = 0.0.obs;
  String meas = '';
  String unit = '';
  double bnw = spGet('BatchSetProperty_NetWeight') ?? 0.0;
  double bgw = spGet('BatchSetProperty_GrossWeight') ?? 0.0;
  Get.dialog(
    PopScope(
        canPop: false,
        child: AlertDialog(
          title: Row(
            children: [
              Expanded(
                child: Text('maintain_label_dialog_batch_modify_attribute'.tr),
              ),
              if (bnw > 0 && bgw > 0)
                CombinationButton(
                    text: 'maintain_label_dialog_last_save'.tr,
                    click: () {
                      nw.value = bnw;
                      gw.value = bgw;
                    }),
            ],
          ),
          content: SizedBox(
            width: 300,
            height: 200,
            child: Obx(() => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _expandedNumberEditText(
                      'maintain_label_dialog_net_weight'.tr,
                      nw.value,
                      (s) => nw.value = s,
                    ),
                    _expandedNumberEditText(
                      'maintain_label_dialog_gross_weight：.tr',
                      gw.value,
                      (s) => gw.value = s,
                    ),
                    _expandedEditText(
                      'maintain_label_dialog_specifications：.tr',
                      meas,
                      (s) => meas = s,
                    ),
                    _expandedEditText(
                      'maintain_label_dialog_unit：.tr',
                      unit,
                      (s) => unit = s,
                    ),
                  ],
                )),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'maintain_label_dialog_back'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                if (nw.value <= 0 || gw.value <= 0) {
                  showSnackBar(
                    message: 'maintain_label_dialog_input_tips'.tr,
                    isWarning: true,
                  );
                } else {
                  spSave('BatchSetProperty_NetWeight', nw.value);
                  spSave('BatchSetProperty_GrossWeight', gw.value);
                  callback.call(nw.value, gw.value, meas, unit);
                  Get.back();
                }
              },
              child: Text('maintain_label_dialog_modify'.tr),
            ),
          ],
        )),
  );
}

_setMaterialProperties(
  List<Map> list,
  int id,
  String materialCode,
  Function() callback,
) {
  httpPost(
    method: webApiSetMaterialProperties,
    loading: 'maintain_label_dialog_setting_material_attribute'.tr,
    body: {
      'UserID': userInfo?.userID ?? 0,
      'InterID': id.toString(),
      'MaterialCode': materialCode,
      'Items': list,
    },
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

setLabelCapacityDialog(
  RxList<MaintainMaterialCapacityInfo> list,
  int id,
  Function() callback,
) {
  Get.dialog(
    PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text('maintain_label_dialog_modify_label_box_capacity'.tr),
          content: SizedBox(
            width: MediaQuery.of(Get.overlayContext!).size.width * 0.8,
            height: MediaQuery.of(Get.overlayContext!).size.height * 0.8,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'maintain_label_dialog_batch_modify_tips'.tr,
                      style: TextStyle(
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    SizedBox(
                      width: 180,
                      child: NumberDecimalEditText(onChanged: (d) {
                        for (var data in list) {
                          data.capacity = d;
                        }
                        list.refresh();
                      }),
                    ),
                    const SizedBox(
                      width: 20,
                    )
                  ],
                ),
                Expanded(
                  child: Obx(() => ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: list.length,
                        itemBuilder: (context, index) => Card(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              children: [
                                expandedTextSpan(
                                  hint: 'maintain_label_dialog_size'.tr,
                                  text: list[index].size ?? '',
                                ),
                                Text('maintain_label_dialog_box_capacity'.tr),
                                SizedBox(
                                  width: 180,
                                  child: NumberDecimalEditText(
                                    initQty: list[index].capacity,
                                    onChanged: (d) => list[index].capacity = d,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      )),
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'maintain_label_dialog_back'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                _setMaterialCapacity(
                  list,
                  () {
                    Get.back();
                    callback.call();
                  },
                );
              },
              child: Text('maintain_label_dialog_modify'.tr),
            ),
          ],
        )),
  );
}

_setMaterialCapacity(
  RxList<MaintainMaterialCapacityInfo> list,
  Function() callback,
) {
  httpPost(
    method: webApiSetMaterialCapacity,
    loading: 'maintain_label_dialog_setting_material_box_capacity'.tr,
    body: {
      'UserID': userInfo?.userID ?? 0,
      'Items': [
        for (var data in list)
          {
            'ItemID': data.itemID ?? 0,
            'FactoryType': data.factoryType ?? '',
            'Size': data.size ?? '',
            'Capacity': data.capacity.toShowString(),
            'ProcessFlowID': data.processFlowID.toString(),
          }
      ],
    },
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      successDialog(content: response.message, back: () => callback.call());
    } else {
      errorDialog(content: response.message);
    }
  });
}

setLabelLanguageDialog(
  RxList<MaintainMaterialLanguagesInfo> list,
  String materialCode,
  Function() callback,
) {
  Get.dialog(
    PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text('maintain_label_dialog_modify_label_language'.tr),
          content: SizedBox(
            width: MediaQuery.of(Get.overlayContext!).size.width * 0.8,
            height: MediaQuery.of(Get.overlayContext!).size.height * 0.8,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: list.length,
              itemBuilder: (context, index) => Card(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    children: [
                      Text(list[index].languageName ?? ''),
                      Expanded(
                        child: EditText(
                          initStr: list[index].materialName,
                          onChanged: (s) => list[index].materialName = s,
                        ),
                      ),
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
                'maintain_label_dialog_back'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () => _setMaterialLanguages(
                list,
                materialCode,
                () {
                  Get.back();
                  callback.call();
                },
              ),
              child: Text('maintain_label_dialog_modify'.tr),
            ),
          ],
        )),
  );
}

_setMaterialLanguages(
  RxList<MaintainMaterialLanguagesInfo> list,
  String materialCode,
  Function() callback,
) {
  httpPost(
    method: webApiSetMaterialLanguages,
    loading: 'maintain_label_dialog_setting_material_language'.tr,
    body: {
      'UserID': userInfo?.userID ?? 0,
      'Items': [
        for (var data in list)
          {
            'LanguageID': data.languageID.toString(),
            'LanguageName': data.languageName ?? '',
            'MaterialName': data.materialName ?? '',
          }
      ],
      'MaterialCode': materialCode,
    },
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      successDialog(content: response.message, back: () => callback.call());
    } else {
      errorDialog(content: response.message);
    }
  });
}

selectMaterialDialog(List<String> list, Function(String) callback) {
  var controller = FixedExtentScrollController();
  Get.dialog(
    PopScope(
      //拦截返回键
      canPop: false,
      child: AlertDialog(
        title: Text('maintain_label_dialog_select_size'.tr),
        content: SizedBox(
          width: 200,
          height: 100,
          child: getCupertinoPicker(
            items:list.map((data) {
              return Center(child: Text(data));
            }).toList(),
            controller: controller,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Get.back();
              callback.call(list[controller.selectedItem]);
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

selectLanguageDialog(
    {required List<String> list, required Function(String) callback}) {
  var controller = FixedExtentScrollController();
  Get.dialog(
    PopScope(
      //拦截返回键
      canPop: false,
      child: AlertDialog(
        title: Text('maintain_label_dialog_select_language'.tr),
        content: SizedBox(
          width: 200,
          height: 100,
          child: getCupertinoPicker(
           items: list.map((data) {
              return Center(child: Text(data));
            }).toList(),
            controller:  controller,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Get.back();
              callback.call(list[controller.selectedItem]);
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

createLabelSelect({
  required Function() single,
  required Function() mix,
  required Function() custom,
}) {
  showCupertinoModalPopup(
    context: Get.overlayContext!,
    builder: (context) => CupertinoActionSheet(
      title: Text(
        'maintain_label_dialog_create_label'.tr,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      message: Text('maintain_label_dialog_select_label_type'.tr),
      actions: [
        CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Get.back();
            single.call();
          },
          child: Text('maintain_label_dialog_singe'.tr),
        ),
        CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Get.back();
            mix.call();
          },
          child: Text('maintain_label_dialog_mix'.tr),
        ),
        CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Get.back();
            custom.call();
          },
          child: Text('maintain_label_dialog_customize'.tr),
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
        'maintain_label_dialog_set'.tr,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      message: Text('maintain_label_dialog_select_set'.tr),
      actions: [
        CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Get.back();
            property.call();
          },
          child: Text('maintain_label_dialog_set_attribute'.tr),
        ),
        CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Get.back();
            boxCapacity.call();
          },
          child: Text('maintain_label_dialog_set_box_capacity'.tr),
        ),
        CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Get.back();
            language.call();
          },
          child: Text('maintain_label_dialog_set_language'.tr),
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
