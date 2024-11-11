import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_purchase_stock_in_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../bean/http/response/leader_info.dart';
import '../../../bean/http/response/worker_info.dart';
import '../../../constant.dart';
import '../../../utils/web_api.dart';
import '../../../widget/custom_widget.dart';
import '../../../widget/dialogs.dart';
import '../../../widget/downloader.dart';
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
      WorkerInfo? newWorker;
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
                    if (avatar.isNotEmpty)
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Image.network(avatar.value, fit: BoxFit.fill),
                        ),
                      ),
                    WorkerCheck(
                      init: saveNumber,
                      hint: '核查人',
                      onChanged: (w) {
                        newWorker = w;
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
                    if (newWorker != null) {
                      var location =
                          '${locationList[locationController.selectedItem].storageLocationNumber}';
                      spSave(checkSaveDialogNumber, newWorker!.empCode ?? '');
                      spSave(checkSaveDialogLocation, location);
                      callback.call(location, newWorker!.empCode ?? '');
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
  required String factoryNumber,
  required Function() callback,
}) {
  _getStorageLocationList(
      factoryNumber: factoryNumber,
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
        debounce(stockNumber, (_) {
          _getStockFaceConfig(
            factoryNumber: factoryNumber,
            stockNumber: stockNumber.value,
            success: (leader) {
              errorMsg.value = '';
              leaderList.value = leader;
            },
            error: (msg) {
              leaderList.value = [];
              errorMsg.value = msg;
            },
          );
        }, time: const Duration(seconds: 1));
        stockNumber.value = locationList[0].storageLocationNumber ?? '';
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
                      selectView(
                        list: leaderList,
                        controller: leaderController,
                        errorMsg: errorMsg.value,
                        hint: '负责人：',
                      ),
                    ],
                  ),
                ),
                contentPadding: const EdgeInsets.only(left: 30, right: 30),
                actionsPadding: const EdgeInsets.only(right: 10, bottom: 10),
                actions: [
                  TextButton(
                    onPressed: () {
                      var leader = leaderList[leaderController.selectedItem];
                      Get.to(
                        () => SignatureView(name: leader.liableEmpName ?? ''),
                      );
                      // face(leaderList[leaderController.selectedItem].liablePicturePath??'');
                      // Get.back();
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
      });
}

///根据工厂编号获取Mes存储位置列表
_getStorageLocationList({
  required String factoryNumber,
  required Function(List<LocationInfo>) success,
}) {
  httpGet(
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

///根据工厂编号获取Mes存储位置列表
_getStockFaceConfig({
  required String factoryNumber,
  required String stockNumber,
  required Function(List<LeaderInfo>) success,
  required Function(String) error,
}) {
  httpGet(
    method: webApiGetStockFaceConfig,
    params: {
      'SapFactoryNumber': factoryNumber,
      'SapStockNumber': stockNumber,
    },
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      if (response.data == '1') {
        getLeaderList(
          billType: '入库单',
          // empCode: userInfo?.number,
          // sapFactoryNumber: factoryNumber,
          // sapStockNumber: stockNumber,
          empCode: '039724',
          sapFactoryNumber: '1000',
          sapStockNumber: '8005',
          success: success,
          error: error,
        );
      } else {
        error.call('该库位未启用人脸验证');
      }
    } else {
      error.call(response.message ?? 'query_default_error'.tr);
    }
  });
}

face(String url) {
  Downloader(
    url: url.replaceAll('"', ''),
    completed: (filePath) {
      try {
        Permission.camera.request().isGranted.then((permission) {
          if (permission) {
            const MethodChannel(channelFaceVerificationAndroidToFlutter)
                .invokeMethod('StartDetect', filePath)
                .then(
              (detect) {
                logger.i(detect);
              },
            ).catchError((e) {
              logger.i(e);
            });
          } else {
            errorDialog(content: 'face_login_no_camera_permission'.tr);
          }
        });
      } on PlatformException {
        errorDialog(content: 'face_login_failed'.tr);
      }
    },
  );
}
