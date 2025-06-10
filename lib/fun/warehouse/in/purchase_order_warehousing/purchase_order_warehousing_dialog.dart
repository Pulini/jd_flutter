import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/leader_info.dart';
import 'package:jd_flutter/bean/http/response/purchase_order_warehousing_info.dart';
import 'package:jd_flutter/bean/http/response/sap_purchase_stock_in_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';

stockInDialog({
  required String factoryNumber,
  required List<PurchaseOrderInfo> dataList,
  required Function() refresh,
}) {
  if (groupBy(dataList, (v) => v.isScanPieces).length > 1) {
    errorDialog(content: '扫码与非扫码工单不能同时操作！');
    return;
  }
  var submitList = <PurchaseOrderDetailsInfo>[];
  for (var order in dataList) {
    submitList.addAll(
        order.details!.where((v) => v.isSelected.value && v.qty.value > 0));
  }
  if (submitList.isEmpty) {
    errorDialog(
        content: 'purchase_order_warehousing_dialog_not_select_order'.tr);
    return;
  }

  var leaderEnable = false.obs;
  var errorMsg = ''.obs;
  var leaderList = <LeaderInfo>[].obs;
  String saveLeaderNumber =
      spGet(spSavePurchaseOrderWarehousingCheckLeader) ?? '';

  var postDate = DatePickerController(PickerType.date,
      buttonName: 'purchase_order_warehousing_dialog_post_date'.tr);
  var leaderController = FixedExtentScrollController();
  var locationController = OptionsPickerController(
    PickerType.ghost,
    buttonName: 'purchase_order_warehousing_dialog_storage_location'.tr,
    saveKey: spSavePurchaseOrderWarehousingCheckLeader,
    dataList: () => getStorageLocationList(factoryNumber),
    onSelected: (v) => _checkFaceInfo(
      billType: '入库单',
      sapFactoryNumber: (v as LocationInfo).factoryNumber ?? '',
      sapStockNumber: v.storageLocationNumber ?? '',
      faceInfoError: (msg) {
        errorMsg.value = msg;
        leaderEnable.value = false;
        leaderList.value = [];
      },
      disableFace: () {
        errorMsg.value = '';
        leaderEnable.value = false;
        leaderList.value = [];
      },
      haveLeaderList: (leaders) {
        errorMsg.value = '';
        leaderEnable.value = true;
        leaderList.value = leaders;
        var saveLeaderIndex = leaderList.indexWhere(
          (v) => v.liableEmpCode == saveLeaderNumber,
        );
        if (saveLeaderIndex != -1) {
          leaderController.jumpToItem(saveLeaderIndex);
        }
      },
      leaderNull: (msg) {
        errorMsg.value = msg;
        leaderEnable.value = true;
        leaderList.value = [];
      },
    ),
  );
  stockInSuccess(String msg) => successDialog(
        content: msg,
        back: () {
          Get.back();
          refresh.call();
        },
      );
  stockIn() {
    if (leaderEnable.value) {
      var leader = leaderList[leaderController.selectedItem];
      livenFaceVerification(
        faceUrl: userInfo?.picUrl ?? '',
        verifySuccess: (pickerB64) => livenFaceVerification(
          faceUrl: leader.liablePicturePath ?? '',
          verifySuccess: (leaderB64) => _stockIn(
            stockID: locationController.selectedId.value,
            postDate: postDate.getDateFormatSapYMD(),
            pickerNumber: userInfo?.number,
            pickerB64: pickerB64,
            leaderNumber: leader.liableEmpCode ?? '',
            leaderB64: leaderB64,
            data: submitList,
            success: stockInSuccess,
          ),
        ),
      );
    } else {
      _stockIn(
        stockID: locationController.selectedId.value,
        postDate: postDate.getDateFormatSapYMD(),
        data: submitList,
        success: stockInSuccess,
      );
    }
  }

  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text('purchase_order_warehousing_dialog_warehousing'.tr),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DatePicker(pickerController: postDate),
              OptionsPicker(pickerController: locationController),
              Obx(
                () => leaderEnable.value
                    ? errorMsg.value.isNotEmpty
                        ? Text(
                            errorMsg.value,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : SizedBox(
                            height: 130,
                            child: CupertinoPicker(
                              scrollController: leaderController,
                              diameterRatio: 1.5,
                              magnification: 1.2,
                              squeeze: 1.2,
                              useMagnifier: true,
                              itemExtent: 32,
                              onSelectedItemChanged: (v) {},
                              children: leaderList
                                  .map((data) => Center(
                                        child: Text('${data.liableEmpName}'),
                                      ))
                                  .toList(),
                            ),
                          )
                    : Center(
                        child: Text(
                          'purchase_order_warehousing_dialog_disable_face'.tr,
                          style: const TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
        actions: [
          Obx(
            () => errorMsg.value.isNotEmpty
                ? Container()
                : TextButton(
                    onPressed: stockIn,
                    child: Text('dialog_default_confirm'.tr),
                  ),
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

_checkFaceInfo({
  required String billType,
  required String sapFactoryNumber,
  required String sapStockNumber,
  required Function(String) faceInfoError,
  required Function() disableFace,
  required Function(List<LeaderInfo>) haveLeaderList,
  required Function(String) leaderNull,
}) {
  httpGet(
    method: webApiGetStockFaceEnable,
    params: {
      'SapFactoryNumber': sapFactoryNumber,
      'SapStockNumber': sapStockNumber,
    },
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      if (response.data == '1') {
        //启用人脸
        httpGet(
          loading: 'purchase_order_warehousing_dialog_getting_leader'.tr,
          method: webApiGetLiableInfo,
          params: {
            'BillType': billType,
            'EmpCode': userInfo?.number,
            'SapFactoryNumber': sapFactoryNumber,
            'SapStockNumber': sapStockNumber,
          },
        ).then((leader) {
          if (leader.resultCode == resultSuccess) {
            haveLeaderList.call(
                [for (var json in leader.data) LeaderInfo.fromJson(json)]);
          } else {
            leaderNull.call(leader.message ?? 'query_default_error'.tr);
          }
        });
      } else {
        //未启用人脸
        disableFace.call();
      }
    } else {
      //人脸配置错误
      faceInfoError.call(response.message ?? 'query_default_error'.tr);
    }
  });
}

_stockIn({
  required String stockID,
  required String postDate,
  String? pickerNumber,
  String? pickerB64,
  String? leaderNumber,
  String? leaderB64,
  required List<PurchaseOrderDetailsInfo> data,
  required Function(String) success,
}) {
  httpPost(
    loading: 'purchase_order_warehousing_dialog_submitting_warehousing'.tr,
    method: webApiPurchaseOrderStockIn,
    body: {
      'CreateCGOrderInstock2SapList': [
        for (PurchaseOrderDetailsInfo item in data)
          {
            'PurchaseVoucherNo': item.purchaseOrder,
            'PurchaseDocumentItemNumber': item.purchaseOrderLineItem,
            'PurchaseOrderQuantity': item.qty.value,
            'PurchaseOrderMeasureUnit': item.unit,
            'StorageLocation': stockID,
            'UserName': userInfo?.number,
            'ChineseName': userInfo?.name,
            'PostingDate': postDate,
          }
      ],
      'CGOrderInstockJBQ2SapList': [
        // {
        //   'PieceNo':'',
        // }
      ],
      'PictureList': [
        if (pickerB64 != null)
          {
            'EmpCode': pickerNumber,
            'Photo': pickerB64,
          },
        if (leaderB64 != null)
          {
            'EmpCode': leaderNumber,
            'Photo': leaderB64,
          }
      ],
    },
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      success.call(response.message ?? '');
    } else {
      errorDialog(content: response.message ?? 'query_default_error'.tr);
    }
  });
}
