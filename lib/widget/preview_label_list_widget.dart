import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/printer/online_print_util.dart';
import 'package:jd_flutter/utils/printer/print_util.dart';
import 'package:jd_flutter/utils/printer/tsc_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/widgets_to_image_widget.dart';

import 'custom_widget.dart';
import 'dialogs.dart';

class PreviewLabelList extends StatefulWidget {
  const PreviewLabelList(
      {super.key, required this.labelWidgets, this.isDynamic = false});

  final List<Widget> labelWidgets;
  final bool isDynamic;

  @override
  State<PreviewLabelList> createState() => _PreviewLabelListState();
}

class _PreviewLabelListState extends State<PreviewLabelList> {
  var pu = PrintUtil();
  var widgetList = <Widget>[].obs;
  var imageList = <Map<String, dynamic>>[].obs;
  var imageByteList = <Uint8List>[].obs;
  RxDouble printSpeed = 0.0.obs;
  RxDouble printDensity = 0.0.obs;

  static bool _isAlreadyOpen = false;

  printLabel() async {
    if (imageList.isEmpty) return;
    loadingShow('正在生成标签...');
    var labelList = <List<Uint8List>>[];
    for (var label in imageList) {
      labelList.add(await imageResizeToLabel({
        ...label,
        'isDynamic': widget.isDynamic,
        'speed': printSpeed.value.toInt(),
        'density': printDensity.value.toInt(),
      }));
    }
    loadingDismiss();
    pu.printLabelList(
      labelList: labelList,
      finished: (success, fail) {
        successDialog(
          title: '标签下发结束',
          content: '完成${success.length}张, 失败${fail.length}张',
        );
      },
    );
  }

  printLabelOnline() async {
    var list = <Uint8List>[];
    loadingShow('正在生成标签...');
    for (var image in imageList) {
      list.add(mergeUint8List(
        await imageResizeToLabel({
          ...image,
          'isDynamic': widget.isDynamic,
          'speed': printSpeed.value.toInt(),
          'density': printDensity.value.toInt(),
        }),
      ));
    }
    loadingDismiss();
    onLinePrintDialog(list, PrintType.label);
  }

  @override
  void initState() {
    super.initState();
    if (_isAlreadyOpen) {
      // 如果已经打开，则关闭当前重复的实例
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
        Get.snackbar('提示', '标签预览页面已经打开');
      });
      return;
    }
    _isAlreadyOpen = true;
    printSpeed.value = spGet(spSavePrintSpeed) ?? 4;
    printDensity.value = spGet(spSavePrintDensity) ?? 15;
    for (var v in widget.labelWidgets) {
      widgetList.add(WidgetsToImage(
        image: (map) {
          imageList.add(map);
          imageByteList.add(map['image']);
        },
        child: v,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => pageBody(
          title: '标签预览',
          actions: [
            imageList.isNotEmpty
                ? Row(
                    children: [
                      IconButton(
                        onPressed: () => onLinePrintDialog(
                          imageByteList,
                          PrintType.label,
                        ),
                        icon: const Icon(Icons.network_check),
                      ),
                      IconButton(
                        onPressed: () => printLabel(),
                        icon: const Icon(Icons.print),
                      ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 25,
                          height: 25,
                          margin: const EdgeInsets.only(right: 10),
                          child: const CircularProgressIndicator(),
                        ),
                        Text('${imageList.length}/${widgetList.length}')
                      ],
                    ),
                  ),
          ],
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsetsGeometry.only(left: 10, right: 10),
                child: Row(
                  children: [
                    const Text('打印速度：'),
                    Expanded(
                      child: Obx(() => Slider(
                            value: printSpeed.value,
                            min: 1,
                            max: 10,
                            divisions: 9,
                            thumbColor: Colors.blueAccent,
                            activeColor: Colors.green.shade300,
                            onChanged: (v) {
                              printSpeed.value = v;
                              spSave(spSavePrintSpeed, v);
                            },
                          )),
                    ),
                    Obx(() => Text(printSpeed.value.toShowString())),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsetsGeometry.only(left: 10, right: 10),
                child: Row(
                  children: [
                    const Text('打印浓度：'),
                    Expanded(
                      child: Obx(() => Slider(
                            value: printDensity.value,
                            min: 1,
                            max: 15,
                            divisions: 14,
                            thumbColor: Colors.blueAccent,
                            activeColor: Colors.green.shade300,
                            onChanged: (v) {
                              printDensity.value = v;
                              spSave(spSavePrintDensity, v);
                            },
                          )),
                    ),
                    Obx(() => Text(printDensity.value.toShowString())),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Center(
                    child: Column(
                      children: [
                        for (var v in widgetList)
                          SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 10),
                            scrollDirection: Axis.horizontal,
                            child: v,
                          )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  @override
  void dispose() {
    _isAlreadyOpen = false; // 页面关闭时重置状态
    super.dispose();
  }
}
