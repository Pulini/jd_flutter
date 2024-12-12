import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_purchase_stock_in_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';

import '../../../bean/http/response/leader_info.dart';
import '../../../bean/http/response/worker_info.dart';
import '../../../utils/web_api.dart';
import '../../../widget/custom_widget.dart';
import '../../../widget/dialogs.dart';
import '../../../widget/picker/picker_controller.dart';
import '../../../widget/signature_page.dart';
import '../../../widget/worker_check_widget.dart';

const String checkSaveDialogNumber = 'CHECK_SAVE_DIALOG_NUMBER';
const String checkSaveDialogLocation = 'CHECK_SAVE_DIALOG_LOCATION';

checkSaveDialog({
  required String factoryNumber,
  required String location,
  required Function(String location, String inspector) callback,
}) {
  _getStorageLocationList(
    factoryNumber: factoryNumber,
    success: (List<LocationInfo> locationList) {
      String saveNumber = spGet(checkSaveDialogNumber) ?? '';
      String saveLocation = spGet(checkSaveDialogLocation) ?? '';
      var avatar = ''.obs;
      WorkerInfo? worker;
      var locationController = FixedExtentScrollController(
        initialItem: locationList.indexWhere(
          (v) => v.storageLocationNumber == saveLocation,
        ),
      );
      Get.dialog(
        PopScope(
          canPop: false,
          child: Obx(
            () => AlertDialog(
              title: const Text('保存核查'),
              content: SizedBox(
                width: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: SizedBox(
                        width: 150,
                        height: 150,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: avatar.isNotEmpty
                              ? Image.network(avatar.value, fit: BoxFit.fill)
                              : Icon(
                            Icons.account_circle,
                            size: 150,
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ),
                    ),
                    WorkerCheck(
                      init: saveNumber,
                      hint: '核查人',
                      onChanged: (w) {
                        worker = w;
                        avatar.value = w?.picUrl ?? '';
                      },
                    ),
                    selectView(
                      list: locationList,
                      controller: locationController,
                      errorMsg: '获取存储位置失败',
                      hint: '存储位置：',
                    ),
                  ],
                ),
              ),
              contentPadding: const EdgeInsets.only(left: 30, right: 30),
              actionsPadding: const EdgeInsets.only(right: 10, bottom: 10),
              actions: [
                TextButton(
                  onPressed: () {
                    if (worker != null) {
                      var location =
                          '${locationList[locationController.selectedItem].storageLocationNumber}';
                      spSave(checkSaveDialogNumber, worker!.empCode ?? '');
                      spSave(checkSaveDialogLocation, location);
                      callback.call(location, worker!.empCode ?? '');
                      Get.back();
                    }
                  },
                  child: Text('dialog_default_confirm'.tr),
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
        ),
      );
    },
  );
}

stockInDialog({
  required List<SapPurchaseStockInInfo> list,
  required Function() refresh,
}) {
  _getStorageLocationList(
    factoryNumber: list[0].factory ?? '',
    success: (locationList) {
      var locationController = FixedExtentScrollController();
      var leaderController = FixedExtentScrollController();
      var dpcDate = DatePickerController(
        PickerType.date,
        buttonName: '过账日期',
      );
      var leaderList = <LeaderInfo>[].obs;
      var stockNumber = ''.obs;
      var errorMsg = ''.obs;
      var isNeedFaceVerify = true.obs;

      debounce(stockNumber, (_) {
        errorMsg.value = '正在检查人脸配置...';
        leaderList.value = [];
        checkStockLeaderConfig(
          type: '入库单',
          number: userInfo?.number ?? '',
          factoryNumber: list[0].factory ?? '',
          stockNumber: stockNumber.value,
          hasConfig: (leaders) {
            isNeedFaceVerify.value = true;
            leaderList.value = leaders;
            errorMsg.value = leaders.isEmpty ? '未配置人脸信息' : '';
          },
          noConfig: () {
            isNeedFaceVerify.value = false;
            errorMsg.value = '';
          },
          error: (msg) {
            isNeedFaceVerify.value = true;
            errorMsg.value = msg;
          },
        );
      }, time: const Duration(seconds: 1));

      stockNumber.value = locationList[0].storageLocationNumber ?? '';

      var submit = TextButton(
        onPressed: () {
          var location = locationList[locationController.selectedItem];
          if (isNeedFaceVerify.value) {
            var leader = leaderList[leaderController.selectedItem];
            Get.to(() => SignaturePage(
                  name: userInfo?.name ?? '',
                  callback: (workerSignature) {
                    Get.to(
                      () => SignaturePage(
                        name: leader.liableEmpName ?? '',
                        callback: (leaderSignature) {
                          _stockIn(
                            location: location.storageLocationNumber ?? '',
                            date: dpcDate.getDateFormatSapYMD(),
                            orderList: list,
                            workerNumber: userInfo?.number ?? '',
                            workerSignature: workerSignature,
                            leaderNumber: leader.liableEmpCode ?? '',
                            leaderSignature: leaderSignature,
                            error: (msg) => errorDialog(content: msg),
                            success: (msg) => successDialog(
                              content: msg,
                              back: () {
                                Get.back();
                                refresh.call();
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                ));
          } else {
            _stockIn(
              location: location.storageLocationNumber ?? '',
              date: dpcDate.getDateFormatSapYMD(),
              orderList: list,
              workerNumber: userInfo?.number ?? '',
              error: (msg) => errorDialog(content: msg),
              success: (msg) => successDialog(
                content: msg,
                back: () {
                  Get.back();
                  refresh.call();
                },
              ),
            );
          }
        },
        child: Text('dialog_default_confirm'.tr),
      );

      Get.dialog(
        PopScope(
          canPop: false,
          child: Obx(
            () => AlertDialog(
              title: const Text('入库'),
              content: SizedBox(
                width: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DatePicker(pickerController: dpcDate),
                    selectView(
                      list: locationList,
                      controller: locationController,
                      errorMsg: '获取存储位置失败',
                      hint: '存储位置：',
                      select: (i) => stockNumber.value =
                          locationList[i].storageLocationNumber ?? '',
                    ),
                    if (isNeedFaceVerify.value)
                      selectView(
                        list: leaderList,
                        controller: leaderController,
                        errorMsg: errorMsg.value,
                        hint: '负责人：',
                      )
                  ],
                ),
              ),
              contentPadding: const EdgeInsets.only(left: 30, right: 30),
              actionsPadding: const EdgeInsets.only(right: 10, bottom: 10),
              actions: [
                if (!isNeedFaceVerify.value || leaderList.isNotEmpty) submit,
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
        ),
      );
    },
  );
}

stockInWriteOffDialog({
  required List<SapPurchaseStockInInfo> list,
  required Function() refresh,
}) {
  var dpcDate = DatePickerController(
    PickerType.date,
    buttonName: '过账日期',
  );
  var reasonController = TextEditingController();
  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        title: const Text('入库冲销'),
        content: SizedBox(
          width: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              DatePicker(pickerController: dpcDate),
              TextField(
                maxLines: 3,
                controller: reasonController,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => reasonController.clear(),
                  ),
                  contentPadding: const EdgeInsets.all(10),
                  hintText: '冲销原因',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ],
          ),
        ),
        contentPadding: const EdgeInsets.only(left: 30, right: 30),
        actionsPadding: const EdgeInsets.only(right: 10, bottom: 10),
        actions: [
          TextButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                errorDialog(content: '请输入冲销原因');
              } else {
                _stockInWriteOff(
                  reason: reasonController.text,
                  date: dpcDate.getDateFormatSapYMD(),
                  orderList: list,
                  success: (msg) => successDialog(
                    content: msg,
                    back: () {
                      Get.back();
                      refresh.call();
                    },
                  ),
                  error: (msg) => errorDialog(content: msg),
                );
              }
            },
            child: Text('dialog_default_confirm'.tr),
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
  );
}

temporaryDialog({
  required List<SapPurchaseStockInInfo> list,
  required Function() refresh,
}) {
  checkStockLeaderConfig(
    showLoading: '正在查询负责人信息...',
    type: '暂收单',
    number: userInfo?.number ?? '',
    factoryNumber: list[0].factory ?? '',
    stockNumber: list[0].location ?? '',
    hasConfig: (leaders) {
      if (leaders.length > 1) {
        var leaderController = FixedExtentScrollController();
        Get.dialog(
          PopScope(
            canPop: false,
            child: AlertDialog(
              title: const Text('生成暂收单'),
              content: SizedBox(
                width: 300,
                child: selectView(
                  list: leaders,
                  controller: leaderController,
                  errorMsg: '',
                  hint: '负责人：',
                ),
              ),
              contentPadding: const EdgeInsets.only(left: 30, right: 30),
              actionsPadding: const EdgeInsets.only(right: 10, bottom: 10),
              actions: [
                TextButton(
                  onPressed: () {
                    var leader = leaders[leaderController.selectedItem];
                    Get.to(() => SignaturePage(
                          name: userInfo?.name ?? '',
                          callback: (workerSignature) {
                            Get.to(() => SignaturePage(
                                  name: leader.liableEmpName ?? '',
                                  callback: (leaderSignature) =>
                                      _createTemporary(
                                    orderList: list,
                                    workerNumber: userInfo?.number,
                                    workerSignature: workerSignature,
                                    leaderNumber: leader.empCode,
                                    leaderSignature: leaderSignature,
                                    success: (msg) => successDialog(
                                      content: msg,
                                      back: () {
                                        Get.back();
                                        refresh.call();
                                      },
                                    ),
                                    error: (msg) => errorDialog(content: msg),
                                  ),
                                ));
                          },
                        ));
                  },
                  child: Text('dialog_default_confirm'.tr),
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
        );
      } else {
        Get.to(() => SignaturePage(
              name: userInfo?.name ?? '',
              callback: (workerSignature) {
                Get.to(() => SignaturePage(
                      name: leaders[0].liableEmpName ?? '',
                      callback: (leaderSignature) => _createTemporary(
                        orderList: list,
                        workerNumber: userInfo?.number,
                        workerSignature: workerSignature,
                        leaderNumber: leaders[0].empCode,
                        leaderSignature: leaderSignature,
                        success: (msg) => successDialog(
                          content: msg,
                          back: () {
                            Get.back();
                            refresh.call();
                          },
                        ),
                        error: (msg) => errorDialog(content: msg),
                      ),
                    ));
              },
            ));
      }
    },
    noConfig: () => _createTemporary(
      orderList: list,
      success: (msg) => successDialog(
        content: msg,
        back: () {
          Get.back();
          refresh.call();
        },
      ),
      error: (msg) => errorDialog(content: msg),
    ),
    error: (msg) => errorDialog(content: msg),
  );
}

///根据工厂编号获取Mes存储位置列表
_getStorageLocationList({
  required String factoryNumber,
  required Function(List<LocationInfo>) success,
}) {
  httpGet(
    loading: '正在获取仓库配置...',
    method: webApiGetStorageLocationList,
    params: {'FactoryNumber': factoryNumber},
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      success
          .call([for (var json in response.data) LocationInfo.fromJson(json)]);
    } else {
      showSnackBar(
        title: '错误',
        message: response.message ?? 'query_default_error'.tr,
      );
    }
  });
}

_stockIn({
  required String location,
  required String date,
  required List<SapPurchaseStockInInfo> orderList,
  String? workerNumber,
  ByteData? workerSignature,
  String? leaderNumber,
  ByteData? leaderSignature,
  required Function(String) success,
  required Function(String) error,
}) {
  sapPost(
    loading: '正在提交入库...',
    method: webApiSapDeliveryOrderStockIn,
    body: {
      'USNAM': userInfo?.number,
      'ZNAME_CN': userInfo?.name,
      'LGORT': location,
      'BUDAT': date,
      'ZREMARK': '',
      'ZZCXFLAG': '',
      'DATA': [
        for (var d in orderList) {'ZDELINO': d.deliveryNumber}
      ],
      'PICTURE': [
        if (workerSignature != null)
          {
            'ZZKEYWORD': workerNumber,
            'ZZITEMNO': 1,
            'ZZDATA': base64Encode(workerSignature.buffer.asUint8List()),
          },
        if (leaderSignature != null)
          {
            'ZZKEYWORD': leaderNumber,
            'ZZITEMNO': 2,
            'ZZDATA': base64Encode(leaderSignature.buffer.asUint8List()),
          },
      ],
    },
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      success.call(response.message ?? '');
    } else {
      error.call(response.message ?? 'query_default_error'.tr);
    }
  });
}

_stockInWriteOff({
  required String reason,
  required String date,
  required List<SapPurchaseStockInInfo> orderList,
  required Function(String) success,
  required Function(String) error,
}) {
  sapPost(
    loading: '正在提交入库...',
    method: webApiSapDeliveryOrderStockIn,
    body: {
      'USNAM': userInfo?.number,
      'ZNAME_CN': userInfo?.name,
      'LGORT': '',
      'BUDAT': date,
      'ZREMARK': reason,
      'ZZCXFLAG': 'X',
      'DATA': [
        for (var d in orderList) {'ZDELINO': d.deliveryNumber}
      ],
      'PICTURE': [],
    },
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      success.call(response.message ?? '');
    } else {
      error.call(response.message ?? 'query_default_error'.tr);
    }
  });
}

_createTemporary({
  required List<SapPurchaseStockInInfo> orderList,
  String? workerNumber,
  ByteData? workerSignature,
  String? leaderNumber,
  ByteData? leaderSignature,
  required Function(String) success,
  required Function(String) error,
}) {
  sapPost(
    loading: '正在创建暂收单...',
    method: webApiSapCreateTemporary,
    body: {
      'USNAM': userInfo?.number,
      'DATA': [
        for (var d in orderList)
          {
            'ZEBELN': d.purchaseOrder,
            'ZEBELP': d.purchaseOrderLineItem,
            'ZTEMPREQTY': d.editQty,
            'ZREMARK': d.remarks,
            'ZDELINO': d.deliveryNumber,
            'ZDELIISEQ': d.deliveryOrderLineNumber,
            'ZLGORT': d.location,
            'ZWERKS': d.factory,
            'ZINSPECTIONCODE': d.inspector,
            'ZTEMPRENO': '',
            'ZTEMPRESEQ': '',
            'ZSOURCETYPE': '',
          }
      ],
      'PICTURE': [],
    },
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      success.call(response.message ?? '');
    } else {
      error.call(response.message ?? 'query_default_error'.tr);
    }
  });
}
