import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils/printer/print_util.dart';
import 'package:jd_flutter/utils/printer/tsc_util.dart';
import 'package:jd_flutter/widget/widgets_to_image_widget.dart';
import 'custom_widget.dart';
import 'dialogs.dart';

class PreviewLabelList extends StatefulWidget {
  const PreviewLabelList({super.key, required this.labelWidgets});

  final List<Widget> labelWidgets;

  @override
  State<PreviewLabelList> createState() => _PreviewLabelListState();
}

class _PreviewLabelListState extends State<PreviewLabelList> {
  var pu = PrintUtil();
  var widgetList = <Widget>[].obs;
  var labelList = <List<Uint8List>>[].obs;

  printLabel() async {
    if (labelList.isEmpty) return;
    pu.printLabelList(
      labelList: labelList,
      start: () {
        loadingDialog('正在下发标签...');
      },
      progress: (i, j) {
        Get.back();
        loadingDialog('正在下发标签($i/$j)');
      },
      finished: (success, fail) {
        Get.back();
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
    for (var v in widget.labelWidgets) {
      widgetList.add(WidgetsToImage(
        image: (map) async => labelList.add(await imageResizeToLabel(map)),
        child: v,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => pageBody(
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
          body: SingleChildScrollView(
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
        ));
  }
}
