import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/widgets_to_image_widget.dart';
import 'package:image/image.dart' as img;

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
  static bool _isAlreadyOpen = false;

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
  Future<Uint8List> a4PaperImageResize(Uint8List image) async {
    var reImage = img.copyResize(
      img.decodeImage(image)!,
      width: 2380,
      height: 3368,
    );
    return Uint8List.fromList(img.encodePng(reImage));
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var paper in widget.paperWidgets) {
        widgetList.add(WidgetsToImage(
          isRotate90: true,
          image: (map) async => a4PaperList.add(
            base64Encode(await a4PaperImageResize(map['image'])),
          ),
          child: paper,
        ));
      }
    });
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
  @override
  void dispose() {
    _isAlreadyOpen = false; // 页面关闭时重置状态
    super.dispose();
  }

}
