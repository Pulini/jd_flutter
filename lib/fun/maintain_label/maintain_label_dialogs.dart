import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils.dart';

import '../../bean/http/response/picking_bar_code_info.dart';
import '../../widget/custom_widget.dart';

createMixLabelDialog(List<List<PickingBarCodeInfo>> list) {
  var selected = <List<RxBool>>[];
  for (var v1 in list) {
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
                    Expanded(
                      child: NumberEditText(
                        onChanged: (s) {},
                      ),
                    ),
                    CombinationButton(
                      text: '填满剩余数',
                      click: () {},
                    )
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: list.length,
                    itemBuilder: (context, index) => Obx(
                      () => Card(
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
                            value:
                                selected[index].where((v) => v.value).length ==
                                    selected[index].length,
                            onChanged: (c) {
                              for (var v in selected[index]) {
                                v.value = c!;
                              }
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
                              Column(
                                children: [
                                  ListTile(
                                    leading: Checkbox(
                                      value: selected[index][i].value,
                                      onChanged: (c) {
                                        selected[index][i].value = c!;
                                      },
                                    ),
                                    title: Text.rich(
                                      TextSpan(
                                        children: [
                                          const TextSpan(
                                              text: '指令：',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
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
                                          const Text(
                                            '装箱数：',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Expanded(
                                            child: selected[index][i].value
                                                ? NumberDecimalEditText(
                                                    onChanged: (v) {
                                                      list[index][i]
                                                          .packingQty = v;
                                                    },
                                                    initQty: list[index][i]
                                                        .packingQty,
                                                  )
                                                : Text(
                                                    '0',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                          ),
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
                              ),
                          ],
                        ),
                      ),
                    ),
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
              onPressed: () {
                Get.back();
              },
              child: Text('创建'),
            ),
          ],
        )),
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
