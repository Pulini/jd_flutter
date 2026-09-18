import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/dio_manager.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

const String testPrintUrl = 'http://192.168.99.103:9095/m';
const String printUrl = 'https://erp.goldemperor.com:9051/m';

enum PrintType {
  label('', 'label', '.text'),
  jpg('1', 'image', '.jpg'),
  pdf('0', 'file', '.pdf');

  final String code;
  final String prefix;
  final String suffix;

  const PrintType(this.code, this.prefix, this.suffix);

  String getFileName(String name) => '$prefix$name$suffix';
}

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


void onLinePrintDialog(List<Uint8List> papers, PrintType printType) {
  var printDio = Dio()
    ..interceptors.add(DioManager.simpleInterceptors);
  _getOnlinePrintDeviceList(
    printDio: printDio,
    success: (devices) {
      String saveDepartmentName =
          spGet(spSaveOnlinePrinterDepartmentName) ?? '';
      String saveDeviceId = spGet(spSaveOnlinePrinterDeviceID) ?? '';
      String savePaperType = spGet(spSaveOnlinePrinterPaperType) ?? '';
      var departmentIndex = (-1).obs;
      var deviceIndex = (-1).obs;
      var paperIndex = (-1).obs;
      var printerList = <PrinterInfo>[].obs;
      var list = <PrinterInfo>[];
      for (var p in devices) {
        var deviceList = <DeviceInfo>[];
        if (printType == PrintType.label) {
          deviceList = p.devices!.where((d) => d.printerType == 1).toList();
        } else {
          deviceList = p.devices!.where((d) => d.printerType == 0).toList();
        }
        if (deviceList.isNotEmpty) {
          p.devices = deviceList;
          list.add(p);
        }
      }
      printerList.value = list;
      if (printerList.isEmpty) {
        return errorDialog(content: 'utils_no_device_for_print'.tr);
      }
      departmentIndex.value =
          printerList.indexWhere((v) => v.departName == saveDepartmentName);

      if (departmentIndex.value == -1) {
        departmentIndex.value = 0;
        deviceIndex.value = 0;
        paperIndex.value = 0;
      } else {
        deviceIndex.value = printerList[departmentIndex.value]
            .devices!
            .indexWhere((v) => v.deviceId == saveDeviceId);
        if (deviceIndex.value == -1) {
          deviceIndex.value = 0;
          paperIndex.value = 0;
        } else {
          paperIndex.value = printerList[departmentIndex.value]
              .devices![deviceIndex.value]
              .paperTypes!
              .indexOf(savePaperType);
          if (paperIndex.value == 1) paperIndex.value = 0;
        }
      }

      print() {
        if (departmentIndex.value != -1) {
          spSave(
            spSaveOnlinePrinterDepartmentName,
            printerList[departmentIndex.value].toString(),
          );
          if (deviceIndex.value != -1) {
            spSave(
              spSaveOnlinePrinterDeviceID,
              printerList[departmentIndex.value]
                  .devices![deviceIndex.value]
                  .deviceId!,
            );
            if (paperIndex.value != -1 &&
                printerList[departmentIndex.value]
                        .devices![deviceIndex.value]
                        .paperTypes
                        ?.isNotEmpty ==
                    true) {
              spSave(
                spSaveOnlinePrinterPaperType,
                printerList[departmentIndex.value]
                    .devices![deviceIndex.value]
                    .paperTypes![paperIndex.value],
              );
            }
          }
        }
        _printImg(
          printDio: printDio,
          deviceId: printerList[departmentIndex.value]
              .devices![deviceIndex.value]
              .deviceId!,
          paperType: printerList[departmentIndex.value]
                      .devices![deviceIndex.value]
                      .paperTypes
                      ?.isEmpty ==
                  true
              ? ''
              : printerList[departmentIndex.value]
                  .devices![deviceIndex.value]
                  .paperTypes![paperIndex.value],
          printType: printType,
          dataList: papers,
          success: (msg) => successDialog(content: msg, back: () => Get.back()),
          error: (msg) => errorDialog(content: msg),
        );
      }

      Get.dialog(
        PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text('utils_select_printer'.tr),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SelectView(
                    list: printerList,
                    hint: 'utils_department'.tr,
                    select: (i) => departmentIndex.value = i,
                  ),
                  Obx(() => SelectView(
                        list: printerList[departmentIndex.value].devices!,
                        hint: 'utils_printer'.tr,
                        select: (i) => deviceIndex.value = i,
                      )),
                  Obx(() => printerList[departmentIndex.value]
                          .devices![deviceIndex.value]
                          .paperTypes!
                          .isNotEmpty
                      ? SelectView(
                          list: printerList[departmentIndex.value]
                              .devices![deviceIndex.value]
                              .paperTypes!,
                          hint: 'utils_paper_type'.tr,
                          select: (i) => paperIndex.value = i,
                        )
                      : Container())
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => print(),
                child: Text('utils_print'.tr),
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

void _getOnlinePrintDeviceList({
  required Dio printDio,
  required Function(List<PrinterInfo>) success,
  required Function(String) error,
}) {
  loadingShow('utils_getting_printer_list'.tr);
  printDio.post(
    isTestUrl() ? testPrintUrl : printUrl,
    queryParameters: {
      'xwl': 'public/interfaces/MES/AppPrintService',
      'xaction': 'getPrinterList',
      'deptId': userInfo?.departmentID,
      // 'deptId': '554911',
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

void _printImg({
  required Dio printDio,
  required String deviceId,
  required String paperType,
  required PrintType printType,
  required List<Uint8List> dataList,
  required Function(String) success,
  required Function(String) error,
}) {
  loadingShow('utils_sending_print_cmd'.tr);
  printDio
      .post(
    isTestUrl() ? testPrintUrl : printUrl,
    queryParameters: {
      'xwl': 'public/interfaces/MES/AppPrintService',
      'xaction': 'print',
      'deviceId': deviceId,
      'paperType': paperType,
      'printType': printType.code,
    },
    options: Options(headers: {'Content-Type': 'application/octet-stream'}),
    data: FormData.fromMap({
      'printFiles': dataList.map((data) {
        debugPrint('打印文件名：${printType.getFileName(data.length.toString())}');
        return MultipartFile.fromBytes(
          data,
          filename: printType.getFileName(data.length.toString()),
        );
      }).toList()
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
