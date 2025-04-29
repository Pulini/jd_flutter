import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/delivery_order_info.dart';
import 'package:jd_flutter/bean/http/response/sap_purchase_stock_in_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_item.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/bean/http/response/leader_info.dart';

stockInDialog({
  required String workerCenterId,
  required List<DeliveryOrderInfo> submitList,
  required Function() refresh,
}) {
  var matchCode = <String>[];
  if (!submitList.every((v) => v.isExempt == true) &&
      !submitList.every((v) => v.isExempt == false)) {
    errorDialog(content: 'delivery_order_dialog_exempt_type_different'.tr);
    return;
  }
  for (var v in submitList) {
    if (!matchCode.contains(v.matchCode)) {
      matchCode.add(v.matchCode ?? '');
    }
  }
  if (matchCode.length > 1) {
    errorDialog(content: 'delivery_order_dialog_match_code_different'.tr);
    return;
  }

  var leaderEnable = false.obs;
  var errorMsg = ''.obs;
  var leaderList = <LeaderInfo>[].obs;
  String saveLeaderNumber = spGet(spSaveDeliveryOrderStockInCheckLeader) ?? '';

  var postDate = DatePickerController(PickerType.date, buttonName: 'delivery_order_dialog_post_date'.tr);
  var leaderController = FixedExtentScrollController();
  var locationController = OptionsPickerController(
    PickerType.ghost,
    buttonName: 'delivery_order_dialog_location'.tr,
    saveKey: spSaveDeliveryOrderStockInCheckLocation,
    dataList: () => _getStorageLocationList(submitList[0].factoryNO ?? ''),
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
          verifySuccess: (leaderB64) => _stockInDeliveryOrder(
            workerCenterId: workerCenterId,
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
      _stockInDeliveryOrder(
        workerCenterId: workerCenterId,
        stockID: locationController.selectedId.value,
        postDate: postDate.getDateFormatSapYMD(),
        data: submitList,
        success: stockInSuccess,
      );
    }
    Get.back();
  }

  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text('delivery_order_dialog_stock_in'.tr),
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
                          'delivery_order_dialog_disable_face'.tr,
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

stockOutDialog({
  required String workerCenterId,
  required List<DeliveryOrderInfo> submitList,
  required Function() refresh,
}) {
  var locationController = OptionsPickerController(
    PickerType.ghost,
    buttonName: 'delivery_order_dialog_location'.tr,
    dataList: () => _getStorageLocationList(submitList[0].factoryNO ?? ''),
  );
  var departmentController = OptionsPickerController(
    PickerType.sapDepartment,
    buttonName: 'delivery_order_dialog_picking_department'.tr,
  );
  Get.dialog(AlertDialog(
    title: Text('delivery_order_dialog_stock_out'.tr),
    content: SizedBox(
      width: 240,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OptionsPicker(pickerController: locationController),
          OptionsPicker(pickerController: departmentController),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => _stockOutDeliveryOrder(
          workerCenterId: workerCenterId,
          factory: locationController.selectedId.value,
          department: departmentController.selectedId.value,
          data: submitList,
          success: (msg) => successDialog(
            content: msg,
            back: () {
              Get.back();
              refresh.call();
            },
          ),
        ),
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
  ));
}

stockOutReversalDialog({
  required List<DeliveryOrderInfo> submitList,
  required Function() refresh,
}) {
  _checkFaceInfo(
    billType: '暂收单',
    sapFactoryNumber: submitList[0].factoryNO ?? '',
    sapStockNumber: submitList[0].location ?? '',
    faceInfoError: (msg) => errorDialog(content: msg),
    disableFace: () => _createTemporaryOder(
      data: submitList,
      success: (msg) => successDialog(content: msg, back: () => refresh.call()),
    ),
    haveLeaderList: (leaders) {
      var leaderController = FixedExtentScrollController();
      Get.dialog(
        PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text('delivery_order_dialog_leader'.tr),
            content: SizedBox(
              width: 300,
              height: 130,
              child: CupertinoPicker(
                scrollController: leaderController,
                diameterRatio: 1.5,
                magnification: 1.2,
                squeeze: 1.2,
                useMagnifier: true,
                itemExtent: 32,
                onSelectedItemChanged: (v) {},
                children: leaders
                    .map((data) => Center(
                  child: Text('${data.liableEmpName}'),
                ))
                    .toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => livenFaceVerification(
                  faceUrl: userInfo?.picUrl ?? '',
                  verifySuccess: (pickerB64) => livenFaceVerification(
                    faceUrl: leaders[leaderController.selectedItem]
                            .liablePicturePath ??
                        '',
                    verifySuccess: (leaderB64) => _createTemporaryOder(
                      pickerNumber: userInfo?.number,
                      pickerB64: pickerB64,
                      leaderNumber: leaders[leaderController.selectedItem]
                              .liableEmpCode ??
                          '',
                      leaderB64: leaderB64,
                      data: submitList,
                      success: (msg) => successDialog(
                        content: msg,
                        back: () {
                          Get.back();
                          refresh.call();
                        },
                      ),
                    ),
                  ),
                ),
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
    },
    leaderNull: (msg) => errorDialog(content: msg),
  );
}

//获取Sap供应商列表
Future _getStorageLocationList(String factoryNumber) async {
  var response = await httpGet(
      method: webApiGetStorageLocationList,
      params: {'FactoryNumber': factoryNumber});
  if (response.resultCode == resultSuccess) {
    try {
      List<PickerItem> list = [];
      list.addAll(await compute(
        parseJsonToList,
        ParseJsonParams(
          response.data,
          LocationInfo.fromJson,
        ),
      ));
      return list;
    } on Error catch (e) {
      logger.e(e);
      return 'json_format_error'.tr;
    }
  } else {
    return response.message;
  }
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
          loading: 'delivery_order_dialog_getting_leader'.tr,
          method: webApiGetLiableInfo,
          params: {
            'BillType': billType,
            'EmpCode': userInfo?.number,
            'SapFactoryNumber': sapFactoryNumber,
            'SapStockNumber': sapStockNumber,
          },
        ).then((leader) {
          // leader.data = jsonDecode(
          //     '[{"EmpID":87055,"EmpCode":"000872","EmpName":"刘艳飞","LiableEmpID":25193,"LiableEmpCode":"002013","LiableEmpName":"欧阳丽军","DepartmentID":554933,"DeptName":"原材料仓","OrgName":"金帝厂","PicturePath":"https://geapp.goldemperor.com:8084/金帝集团股份有限公司/员工/2013/2/刘艳飞/000872.jpg","LiablePicturePath":"https://geapp.goldemperor.com:8084/金帝集团股份有限公司/员工/2008/11/欧阳丽军/002013.jpg"},{"EmpID":87055,"EmpCode":"000872","EmpName":"刘艳飞","LiableEmpID":51267,"LiableEmpCode":"005642","LiableEmpName":"廖奇家","DepartmentID":554933,"DeptName":"原材料仓","OrgName":"金帝厂","PicturePath":"https://geapp.goldemperor.com:8084/金帝集团股份有限公司/员工/2013/2/刘艳飞/000872.jpg","LiablePicturePath":"https://geapp.goldemperor.com:8084/金帝集团股份有限公司/员工/2010/7/廖奇家/005642.jpg"}]');
          // leader.resultCode = resultSuccess;
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

_stockInDeliveryOrder({
  required String workerCenterId,
  required String stockID,
  required String postDate,
  String? pickerNumber,
  String? pickerB64,
  String? leaderNumber,
  String? leaderB64,
  required List<DeliveryOrderInfo> data,
  required Function(String) success,
}) {
  var orderNoList = <String>[];
  for (var v in data) {
    if (!orderNoList.contains(v.deliNo)) orderNoList.add(v.deliNo ?? '');
  }
  httpPost(
    loading: 'delivery_order_dialog_submitting_stock_in'.tr,
    method: webApiDeliveryOrderStockIn,
    body: {
      'EmpCode': userInfo?.number,
      'ChineseName': userInfo?.name,
      'Line': userInfo?.sapRole == '003' ? workerCenterId : '',
      'SAPStockID': stockID,
      'PostingDate': postDate,
      'DeilNoList': orderNoList,
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

_stockOutDeliveryOrder({
  required String workerCenterId,
  required String factory,
  required String department,
  required List<DeliveryOrderInfo> data,
  required Function(String) success,
}) {
  var orderNoList = <DeliveryOrderInfo>[];
  for (var v in data) {
    if (!orderNoList.any((v2) => v2.deliNo == v.deliNo)) orderNoList.add(v);
  }

  httpPost(
    loading: 'delivery_order_dialog_submitting_stock_out'.tr,
    method: webApiDeliveryOrderStockIn,
    body: {
      'EmpCode': userInfo?.number,
      'PickingDepart': department,
      'Line': workerCenterId,
      'SAPStockID': factory,
      'DeilNoList': [
        for (var item in orderNoList)
          {
            'DeilNo': item.deliNo,
            'ScWorkcardNo': item.produceOrderNo,
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

_createTemporaryOder({
  String? pickerNumber,
  String? pickerB64,
  String? leaderNumber,
  String? leaderB64,
  required List<DeliveryOrderInfo> data,
  required Function(String) success,
}) {
  httpPost(
    loading: 'delivery_order_dialog_creating_temporary'.tr,
    method: webApiCreateTemporary,
    body: {
      'EmpCode': userInfo?.number,
      'DeilNoList': [
        for (var group in data)
          for (var item in group.deliSeqList ?? <DeliveryOrderLineInfo>[])
            {
              'ContractNo': item.purchaseOrderNumber,
              'PurchaseOrderLineNumber': item.purchaseDocumentItemNumber,
              'TemporaryReceiveQuantity': item.verifyQty,
              'Remarks': item.remarks,
              'DeliveryNumber': group.deliNo,
              'DeliveryOrderLineNumber': item.deliSeq,
              'Location': group.location,
              'FactoryNo': group.factoryNO,
              'InspectionCode': group.inspector,
              'StorageLocationName': group.locationName,
              'TemporaryNo': '',
              'TemporaryCollectionBankNo': '',
              'SourceOrderType': '送货单',
            }
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
