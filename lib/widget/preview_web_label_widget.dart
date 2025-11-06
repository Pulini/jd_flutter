import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData;
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/app_init.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/printer/online_print_util.dart';
import 'package:jd_flutter/utils/printer/tsc_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:webcontent_converter/webcontent_converter.dart';

class PreviewWebLabelList extends StatefulWidget {
  const PreviewWebLabelList({super.key, required this.labelCodes});

  final List<Map<String, String>> labelCodes;

  @override
  State<PreviewWebLabelList> createState() => _PreviewWebLabelListState();
}

class _PreviewWebLabelListState extends State<PreviewWebLabelList> {
  RxDouble printSpeed = 0.0.obs;
  RxDouble printDensity = 0.0.obs;
  var labelList = <String>[].obs;
  var htmlImages = <Uint8List>[].obs;
  var reImageList = <Map<String, dynamic>>[];
  var labelByteMap = <Uint8List>[];
  late MediaQueryData mediaQueryData;

  runTask() {
    var dio = Dio()
      ..interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          options.print();
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (response.data is String) {
            logger.f('Response data: ${response.data}');
          } else {
            loggerF(response.data);
          }
          handler.next(response);
        },
        onError: (DioException e, handler) {
          logger.f('error: $e');
          handler.next(e);
        },
      ));
    loadingShow('正在获取标签信息...');
    dio.post(
      isTestUrl()
          ? 'https://mestest.goldemperor.com:9099/m'
          : 'https://wb.goldemperor.com:8096/m',
      queryParameters: {
        'xwl': 'public/interfaces/app/getBqModel',
        'bqList': widget.labelCodes.toString(),
      },
    ).then((response) async {
      loadingDismiss();
      labelList.value = [
        for (var json in jsonDecode(response.data)['data']) json
      ];
      for (var web in labelList) {
        var bytes = await WebcontentConverter.contentToImage(content: web);
        var map = await htmlImageResize(bytes);
        reImageList.add({
          'width': 110,
          'height': (map['height'] / (map['width'] / 110)).toInt(),
          'image': map['image'],
        });
        htmlImages.add(bytes);
      }
    });
  }

  @override
  void initState() {
    printSpeed.value = spGet(spSavePrintSpeed) ?? 4;
    printDensity.value = spGet(spSavePrintDensity) ?? 15;
    WidgetsBinding.instance.addPostFrameCallback((_) => runTask());
    super.initState();
  }

  double getImageWidth() {
    if (mediaQueryData.size.width >= 600) {
      return mediaQueryData.size.width > mediaQueryData.size.height
          ? mediaQueryData.size.height * 0.5
          : mediaQueryData.size.width * 0.5;
    } else {
      return mediaQueryData.size.width > mediaQueryData.size.height
          ? mediaQueryData.size.height * 0.9
          : mediaQueryData.size.width * 0.9;
    }
  }

  printLabel() async {
    if (labelByteMap.isEmpty) {
      for (var i = 0; i < reImageList.length; ++i) {
        loadingShow('正在生成标签数据( $i / ${reImageList.length} )...');
        labelByteMap.add(mergeUint8List(
          await htmlImageToLabel({
            ...reImageList[i],
            'isDynamic': true,
            'speed': printSpeed.value.toInt(),
            'density': printDensity.value.toInt(),
          }),
        ));
      }
      loadingDismiss();
    }
    onLinePrintDialog(
      labelByteMap,
      PrintType.label,
    );
  }

  @override
  Widget build(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);
    return Container(
      decoration: backgroundColor(),
      child: Obx(
        () => Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text('打印标签预览'),
            actions: [
              htmlImages.length == labelList.length && labelList.isNotEmpty
                  ? IconButton(
                      onPressed: () => printLabel(),
                      icon: const Icon(Icons.print, color: Colors.blueAccent),
                    )
                  : Row(
                      children: [
                        Text(
                            '正在生成标签：${htmlImages.length}/${labelList.length}   '),
                        const CircularProgressIndicator(
                          color: Colors.green,
                        ),
                        const SizedBox(width: 10)
                      ],
                    ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsetsGeometry.only(left: 10, right: 10),
                child: Row(
                  children: [
                    const Text('打印速度：'),
                    Expanded(
                      child: Slider(
                        value: printSpeed.value,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        thumbColor: Colors.blueAccent,
                        activeColor: Colors.green.shade300,
                        onChanged: (v) {
                          printSpeed.value = v;
                          spSave(spSavePrintSpeed, v);
                          labelByteMap.clear();
                        },
                      ),
                    ),
                    Text(printSpeed.value.toShowString()),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsetsGeometry.only(left: 10, right: 10),
                child: Row(
                  children: [
                    const Text('打印浓度：'),
                    Expanded(
                      child: Slider(
                        value: printDensity.value,
                        min: 1,
                        max: 15,
                        divisions: 14,
                        thumbColor: Colors.blueAccent,
                        activeColor: Colors.green.shade300,
                        onChanged: (v) {
                          printDensity.value = v;
                          spSave(spSavePrintDensity, v);
                          labelByteMap.clear();
                        },
                      ),
                    ),
                    Text(printDensity.value.toShowString()),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Center(
                    child: Column(
                      children: [
                        for (var v in htmlImages)
                          SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 10),
                            scrollDirection: Axis.horizontal,
                            child: Image.memory(
                              v,
                              width: getImageWidth(),
                              fit: BoxFit.contain,
                            ),
                          )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
