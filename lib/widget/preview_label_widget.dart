import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils/printer/print_util.dart';
import 'package:jd_flutter/utils/printer/tsc_util.dart';
import 'package:jd_flutter/widget/widgets_to_image_widget.dart';

import 'custom_widget.dart';
import 'dialogs.dart';

class PreviewLabel extends StatefulWidget {
  const PreviewLabel({super.key, required this.labelWidget});

  final Widget labelWidget;

  @override
  State<PreviewLabel> createState() => _PreviewLabelState();
}

class _PreviewLabelState extends State<PreviewLabel> {
  var pu = PrintUtil();
  var label = <Uint8List>[].obs;

  printLabel() async {
    if (label.isEmpty) return;
    pu.printLabel(
      label: label,
      start: () {
        loadingDialog('正在下发标签...');
      },
      reStart: () {
        loadingDismiss();
        loadingDialog('正在重新下发标签...');
      },
      success: () {
        loadingDismiss();
        successDialog(title:'打印',content: '标签下发完成');
      },
      failed: () {
        loadingDismiss();
        errorDialog(title: '打印',content: '标签下发失败');
      },
      disconnected: () {
        loadingDismiss();
        errorDialog(title: '打印',content: '蓝牙已断开');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => pageBody(
          title: '标签预览',
          actions: [
            label.isNotEmpty
                ? IconButton(
                    onPressed: () => printLabel(),
                    icon: const Icon(Icons.print),
                  )
                : Container(
                    width: 25,
                    height: 25,
                    margin: const EdgeInsets.only(right: 10),
                    child: const CircularProgressIndicator(),
                  ),
          ],
          body: Center(
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: WidgetsToImage(
                  image: (map) async =>
                      label.value = await imageResizeToLabel(map),
                  child: widget.labelWidget,
                ),
              ),
            ),
          ),
        ));
  }
}
