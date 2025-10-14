import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/printer/online_print_util.dart';

import 'package:jd_flutter/utils/printer/print_util.dart';
import 'package:jd_flutter/utils/printer/tsc_util.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/widgets_to_image_widget.dart';

import 'custom_widget.dart';

class PreviewLabel extends StatefulWidget {
  const PreviewLabel({
    super.key,
    required this.labelWidget,
    this.isDynamic = false,
  });

  final Widget labelWidget;
  final bool isDynamic;

  @override
  State<PreviewLabel> createState() => _PreviewLabelState();
}

class _PreviewLabelState extends State<PreviewLabel> {
  var pu = PrintUtil();
  var image = <String, dynamic>{}.obs;
  var imageByteList = <Uint8List>[].obs;
  RxDouble printSpeed = 0.0.obs;
  RxDouble printDensity = 0.0.obs;
  static bool _isAlreadyOpen = false;

  printLabel() async {
    if (image.isEmpty) return;
    loadingShow('正在生成标签...');
    var label = await imageResizeToLabel({
      ...image,
      'isDynamic': widget.isDynamic,
      'speed': printSpeed.value.toInt(),
      'density': printDensity.value.toInt(),
    });
    loadingDismiss();
    pu.printLabel(
      label: label,
      start: () {
        loadingShow('正在下发标签...');
      },
      success: () {
        loadingDismiss();
        successDialog(content: '标签下发完成！');
      },
      failed: () {
        loadingDismiss();
        errorDialog(content: '标签下发失败！');
      },
    );
  }

  @override
  void initState() {
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
    super.initState();
  }

  onlinePrint() async {
    onLinePrintDialog([
      mergeUint8List(
        await imageResizeToLabel({
          ...image,
          'isDynamic': widget.isDynamic,
          'speed': printSpeed.value.toInt(),
          'density': printDensity.value.toInt(),
        }),
      )
    ], PrintType.label);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => pageBody(
          title: '标签预览',
          actions: [
            image.isNotEmpty
                ? Row(
                    children: [
                      IconButton(
                        onPressed: () => onlinePrint(),
                        icon: const Icon(Icons.network_check),
                      ),
                      IconButton(
                        onPressed: () => printLabel(),
                        icon: const Icon(Icons.print),
                      ),
                    ],
                  )
                : Container(
                    width: 25,
                    height: 25,
                    margin: const EdgeInsets.only(right: 10),
                    child: const CircularProgressIndicator(),
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
                child: Center(
                  child: SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: WidgetsToImage(
                        image: (map) async {
                          image.value = map;
                          imageByteList.add(map['image']);
                        },
                        child: widget.labelWidget,
                      ),
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
