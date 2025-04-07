import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/printer/tsc_util.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/widgets_to_image_widget.dart';

import 'custom_widget.dart';

class PreviewA4Paper extends StatefulWidget {
  const PreviewA4Paper({super.key, required this.paperWidgets});

  final List<Widget> paperWidgets;

  @override
  State<PreviewA4Paper> createState() => _PreviewA4PaperState();
}

class _PreviewA4PaperState extends State<PreviewA4Paper> {
  var widgetList = <Widget>[].obs;
  var a4PaperList = <String>[].obs;

  printA4Paper() async {
    if (a4PaperList.isEmpty) return;
    const MethodChannel(channelPrinterFlutterToAndroid)
        .invokeMethod('PrintFile', a4PaperList)
        .then((detectCallback) {
      logger.i(detectCallback);
    }).catchError((e) {
      logger.i(e);
    });
  }

  @override
  void initState() {
    super.initState();
    for (var paper in widget.paperWidgets) {
      widgetList.add(WidgetsToImage(
        child: paper,
        image: (i) => a4PaperImageResize(i).then(
          (v) => a4PaperList.add(base64Encode(v)),
        ),
        // image: (i) => a4PaperImageResize(i).then(
        //   (v) => a4PaperList.add(base64Encode(v)),
        // ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => pageBody(
          title: 'A4打印预览',
          actions: [
            a4PaperList.isNotEmpty
                ? IconButton(
                    onPressed: () => printA4Paper(),
                    icon: const Icon(Icons.print),
                  )
                : Container(
                    width: 25,
                    height: 25,
                    margin: const EdgeInsets.only(right: 10),
                    child: const CircularProgressIndicator(),
                  ),
          ],
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(5),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  for (var v in widgetList)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: v,
                    )
                ],
              ),
            ),
          ),
        ));
  }
}
