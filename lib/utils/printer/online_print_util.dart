import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

const String printUrl = 'http://192.168.99.103:9098/m';

class PrinterInfo {
  String? departName;
  List<DeviceInfo>? devices;

  PrinterInfo({
    this.departName,
    this.devices,
  });

  factory PrinterInfo.fromJson(dynamic json) {
    return PrinterInfo(
      departName: json['DepartName'],
      devices: [
        if (json['Devices'] != null)
          for (var item in json['Devices']) DeviceInfo.fromJson(item)
      ],
    );
  }

  @override
  String toString() {
    return departName ?? '';
  }
}

class DeviceInfo {
  String? deviceId;
  String? deviceName;
  int? printerType;
  List<String>? paperTypes;

  DeviceInfo({
    this.deviceId,
    this.deviceName,
    this.printerType,
    this.paperTypes,
  });

  factory DeviceInfo.fromJson(dynamic json) {
    return DeviceInfo(
      deviceId: json['DeviceId'],
      deviceName: json['DeviceName'],
      printerType: json['PrinterType'],
      paperTypes: [
        if (json['PaperTypes'] != null)
          for (var item in json['PaperTypes']) item
      ],
    );
  }

  @override
  String toString() {
    return deviceName ?? '';
  }
}

onLinePrintDialog(List<Uint8List> papers, bool isLabel) {
  var printDio = Dio()
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
  _getOnlinePrintDeviceList(
    printDio: printDio,
    success: (devices) {
      String saveDepartmentName = spGet(onlinePrinterDepartmentName) ?? '';
      String saveDeviceId = spGet(onlinePrinterDeviceID) ?? '';
      String savePaperType = spGet(onlinePrinterPaperType) ?? '';
      var departmentIndex = (-1).obs;
      var deviceIndex = (-1).obs;
      var paperIndex = (-1).obs;
      var printerLier = <PrinterInfo>[].obs;
      var printerList = <PrinterInfo>[];
      for (var p in devices) {
        var deviceList = <DeviceInfo>[];
        if (isLabel) {
          deviceList = p.devices!.where((d) => d.printerType == 1).toList();
        } else {
          deviceList = p.devices!.where((d) => d.printerType == 0).toList();
        }
        if (deviceList.isNotEmpty) {
          p.devices = deviceList;
          printerList.add(p);
        }
      }
      printerLier.value = printerList;

      departmentIndex.value =
          printerLier.indexWhere((v) => v.departName == saveDepartmentName);
      if (departmentIndex.value == -1) {
        departmentIndex.value = 0;
        deviceIndex.value = 0;
        paperIndex.value = 0;
      } else {
        deviceIndex.value = printerLier[departmentIndex.value]
            .devices!
            .indexWhere((v) => v.deviceId == saveDeviceId);
        if (deviceIndex.value == -1) {
          deviceIndex.value = 0;
          paperIndex.value = 0;
        } else {
          paperIndex.value = printerLier[departmentIndex.value]
              .devices![deviceIndex.value]
              .paperTypes!
              .indexOf(savePaperType);
          if (paperIndex.value == 1) paperIndex.value = 0;
        }
      }

      print() {
        if (departmentIndex.value != -1) {
          spSave(
            onlinePrinterDepartmentName,
            printerLier[departmentIndex.value].toString(),
          );
          if (deviceIndex.value != -1) {
            spSave(
              onlinePrinterDeviceID,
              printerLier[departmentIndex.value]
                  .devices![deviceIndex.value]
                  .deviceId!,
            );
            if (paperIndex.value != -1 &&
                printerLier[departmentIndex.value]
                        .devices![deviceIndex.value]
                        .paperTypes
                        ?.isNotEmpty ==
                    true) {
              spSave(
                onlinePrinterPaperType,
                printerLier[departmentIndex.value]
                    .devices![deviceIndex.value]
                    .paperTypes![paperIndex.value],
              );
            }
          }
        }
        _printImg(
          printDio: printDio,
          deviceId: printerLier[departmentIndex.value]
              .devices![deviceIndex.value]
              .deviceId!,
          paperType: paperIndex.value == -1
              ? ''
              : printerLier[departmentIndex.value]
                  .devices![deviceIndex.value]
                  .paperTypes![paperIndex.value],
          imgList: papers,
          success: (msg) => successDialog(content: msg, back: () => Get.back()),
          error: (msg) => errorDialog(content: msg),
        );
      }

      Get.dialog(
        PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text('选择打印机'),
            content: SizedBox(
              width: 400,
              height: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  selectView(
                    list: printerLier,
                    hint: '部门',
                    select: (i) => departmentIndex.value = i,
                  ),
                  Obx(() => selectView(
                        list: printerLier[departmentIndex.value].devices!,
                        hint: '打印机',
                        select: (i) => deviceIndex.value = i,
                      )),
                  Obx(() => printerLier[departmentIndex.value]
                          .devices![deviceIndex.value]
                          .paperTypes!
                          .isNotEmpty
                      ? selectView(
                          list: printerLier[departmentIndex.value]
                              .devices![deviceIndex.value]
                              .paperTypes!,
                          hint: '纸张类型',
                          select: (i) => paperIndex.value = i,
                        )
                      : Container())
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => print(),
                child: Text('打印'),
              ),
              TextButton(
                onPressed: () => Get.back(),
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
    },
    error: (msg) => errorDialog(content: msg),
  );
}

_getOnlinePrintDeviceList({
  required Dio printDio,
  required Function(List<PrinterInfo>) success,
  required Function(String) error,
}) {
  loadingShow('正在获取打印机列表...');
  printDio.post(
    printUrl,
    queryParameters: {
      'xwl': 'public/interfaces/MES/AppPrintService',
      'xaction': 'getPrinterList',
      'deptId': ''
    },
  ).then((response) {
    loadingDismiss();
    var base = BaseData.fromJson(response.data);
    if (base.resultCode == resultSuccess) {
      success.call([for (var item in base.data) PrinterInfo.fromJson(item)]);
    } else {
      error.call(base.message ?? 'query_default_error'.tr);
    }
  }, onError: (e) {
    loadingDismiss();
    error.call(
      '获取打印机列表失败：${(e as DioException).response?.statusCode}  ${e.response?.statusMessage}',
    );
  });
}

_printImg({
  required Dio printDio,
  required String deviceId,
  required String paperType,
  required List<Uint8List> imgList,
  required Function(String) success,
  required Function(String) error,
}) {
  loadingShow('正在发送打印命令...');
  printDio
      .post(
    printUrl,
    queryParameters: {
      'xwl': 'public/interfaces/MES/AppPrintService',
      'xaction': 'print',
      'deviceId': deviceId,
      'paperType': paperType,
    },
    options: Options(headers: {'Content-Type': 'application/octet-stream'}),
    data:  FormData.fromMap({
            'printFiles': imgList
                .map((img) => MultipartFile.fromBytes(img,
                    filename: 'image${img.length}.jpg'))
                .toList()
          }),
  )
      .then((response) {
    loadingDismiss();
    var base = BaseData.fromJson(response.data);
    if (base.resultCode == resultSuccess) {
      success.call(base.message ?? '');
    } else {
      error.call(base.message ?? 'query_default_error'.tr);
    }
  }, onError: (e) {
    loadingDismiss();
    error.call(
      '发送打印命令失败：${(e as DioException).response?.statusCode}  ${e.response?.statusMessage}',
    );
  });
}
