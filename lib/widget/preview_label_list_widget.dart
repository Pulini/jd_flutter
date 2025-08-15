import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/constant.dart';
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
  var labelList = <List<Uint8List>>[].obs;
  RxDouble printSpeed = 0.0.obs;
  RxDouble printDensity = 0.0.obs;

  printLabel() async {
    if (labelList.isEmpty) return;
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

  @override
  void initState() {
    super.initState();
    printSpeed.value = spGet(spSavePrintSpeed) ?? 4;
    printDensity.value = spGet(spSavePrintDensity) ?? 15;
    for (var v in widget.labelWidgets) {
      widgetList.add(WidgetsToImage(
        image: (map) async => labelList.add(await imageResizeToLabel({
          ...map,
          'isDynamic': widget.isDynamic,
          'speed': printSpeed.value.toInt(),
          'density': printDensity.value.toInt(),
        })),
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
            labelList.isNotEmpty
                ? IconButton(
                    onPressed: () => printLabel(),
                    icon: const Icon(Icons.print),
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
                        Text('${labelList.length}/${widgetList.length}')
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
                    Text('打印速度：'),
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
                    Text('打印浓度：'),
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
}
