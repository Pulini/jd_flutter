import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/carton_label_scan_clear_tail_info.dart';
import 'package:jd_flutter/bean/http/response/carton_label_scan_info.dart';
import 'package:jd_flutter/bean/http/response/carton_label_scan_progress_info.dart';
import 'package:jd_flutter/bean/http/response/out_box_labels_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class CartonLabelScanState {
  var isCheckingCartonBarCode = false;
  var cartonInsideLabelList = <LinkDataSizeList>[].obs;
  var cartonLabel = ''.obs;
  CartonLabelScanInfo? cartonLabelInfo;
  var labelTotal = 0.obs;
  var scannedLabelTotal = 0.obs;
  var progress = <CartonLabelScanProgressInfo>[].obs;
  var progressDetail = <List<CartonLabelScanProgressDetailInfo>>[].obs;

  var priorityCartonInsideLabelList = <LinkDataSizeList>[].obs;
  var priorityCartonLabel = ''.obs;
  var priorityPo = ''.obs;
  var dispatchNumber = ''.obs;
  CartonLabelScanInfo? priorityCartonLabelInfo;
  CartonLabelScanClearTailInfo? cartonLabelScanClearTailInfo;
  var factoryBody = ''.obs; //型体
  var groupName = ''.obs; //组别
  var salesOrder = ''.obs; //销售订单
  var customerOrderNumber = ''.obs; //客户订单

  var outBoxList = <OutBoxLabelsInfo>[].obs; //外箱数据
  var outBoxDetail = <LinkDataSizeLists>[].obs; //外箱数据内标数据
  var add = false.obs; // 新增
  var change = false.obs; // 修改

  void queryCartonLabelInfo({
    required String code,
    required Function(CartonLabelScanInfo) success,
    required Function(String) error,
  }) {
    if (isCheckingCartonBarCode) {
      return;
    }
    isCheckingCartonBarCode = true;
    httpGet(
      loading: 'carton_label_scan_querying_outside_label_detail'.tr,
      method: webApiGetCartonLabelInfo,
      params: {
        'CartonBarCode': code,
        'DispatchNumber': dispatchNumber.value,
        'DispatchNumber':dispatchNumber.value,
        'OrganizeID': userInfo?.organizeID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(CartonLabelScanInfo.fromJson(response.data));
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
      isCheckingCartonBarCode=false;
    });
  }

  //清理优先级界面数据
  void clearPriority(){
    priorityCartonLabelInfo = CartonLabelScanInfo();
    priorityCartonLabel.value = '';
    priorityPo.value='';
    priorityCartonInsideLabelList.value = [];
  }

  //更改优先级
  void changePOPriority({
    required String poNumber,
    required Function(String) success,
  }) {
    httpPost(
      loading: 'carton_label_scan_submitting_change_priority'.tr,
      method: webApiChangePOPriority,
      params: {
        'PO': poNumber,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
       success.call(response.message ?? 'carton_label_scan_change_successful'.tr);
      } else {
        errorDialog(content: response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void submitScannedCartonLabel({
    required Function(String) success,
    required Function(String) error,
  }) {
    httpPost(
      loading: 'carton_label_scan_submitting_scan_progress'.tr,
      method: webApiSubmitScannedCartonLabel,
      body: {
        'InterID': cartonLabelInfo?.interID,
        'CustOrderNumber': cartonLabelInfo?.custOrderNumber,
        'CartonBarCode': cartonLabelInfo?.outBoxBarCode,
        'Mix': cartonLabelInfo?.mix,
        'UserID': userInfo?.userID,
        'DispatchNumber': dispatchNumber.value,
        'OutBoxSizeList': [
          for (var data in cartonInsideLabelList)
            {
              'PriceBarCode': data.priceBarCode,
              'Size': data.size,
              'LabelCount': data.scanned,
            }
        ]
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        labelTotal.value=0;
        scannedLabelTotal.value=0;
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }



  void getCartonLabelScanHistory({
    required String orderNo,
    required Function(String) error,
  }) {
    httpGet(
      loading: 'carton_label_scan_querying_outside_label_detail'.tr,
      method: webApiGetCartonLabelScanHistory,
      params: {'BillorPO': orderNo},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        progress.value = [
          for (var json in response.data)
            CartonLabelScanProgressInfo.fromJson(json)
        ];
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void getCartonLabelScanHistoryDetail({
    required int id,
    required Function() success,
    required Function(String) error,
  }) {
    httpGet(
      loading: 'carton_label_scan_querying_outside_label_detail'.tr,
      method: webApiGetCartonLabelScanHistoryDetail,
      params: {
        'InterID': id,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list =<CartonLabelScanProgressDetailInfo> [
          for (var json in response.data)
            CartonLabelScanProgressDetailInfo.fromJson(json)
        ];
        var group = <List<CartonLabelScanProgressDetailInfo>>[];
        groupBy(list, (v) => v.size ?? '').forEach((k, v) {
          group.add(v);
        });
        progressDetail.value=group;
        success.call();
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void getMantissaData({
    required String barCode,
    required String dispatchNumber,
    required Function(String) success,
    required Function(String) error,
  }) {
    httpGet(
      loading: 'carton_label_scan_order_get_last_detail'.tr,
      method: webApiGetMantissaData,
      params: {
        'CartonBarCode': barCode,
        'DispatchNumber': dispatchNumber,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        cartonLabelScanClearTailInfo =
            CartonLabelScanClearTailInfo.fromJson(response.data);
        factoryBody.value =
            cartonLabelScanClearTailInfo!.factoryBody.toString();
        groupName.value = cartonLabelScanClearTailInfo!.groupName.toString();
        salesOrder.value = cartonLabelScanClearTailInfo!.salesOrder.toString();
        customerOrderNumber.value =
            cartonLabelScanClearTailInfo!.customerOrderNumber.toString();
      } else {
        factoryBody.value = '';
        groupName.value = '';
        salesOrder.value = '';
        customerOrderNumber.value = '';
        errorDialog(content: response.message ?? 'query_default_error'.tr);
      }
    });
  }

  //为每一个工单添加合计行
  // void setDataList() {
  //   for (var data in showDataList) {
  //     data.scWorkCardSizeInfos?.add(ScWorkCardSizeInfos(
  //       size: '合计',
  //       qty: data.scWorkCardSizeInfos
  //           ?.map((v) => v.qty ?? 0.0)
  //           .reduce((a, b) => a.add(b)),
  //       scannedQty: data.scWorkCardSizeInfos
  //           ?.map((v) => v.scannedQty ?? 0.0)
  //           .reduce((a, b) => a.add(b)),
  //       todayScannedQty: data.scWorkCardSizeInfos
  //           ?.map((v) => v.todayScannedQty ?? 0.0)
  //           .reduce((a, b) => a.add(b)),
  //     ));
  //   }
  // }

  //查询不满箱
  void queryNotFullBox({
    required String barCode,
    required String dispatchNumber,
  }) {
    httpGet(
      loading: 'carton_label_scan_order_get_last_detail'.tr,
      method: webApiGetMantissaData,
      params: {
        'CartonBarCode': barCode,
        'DispatchNumber': dispatchNumber,
        'IsAddData': add.value || !change.value,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        outBoxList.value = [
          for (var i = 0; i < response.data.length; ++i)
            OutBoxLabelsInfo.fromJson(response.data[i])
        ];
      } else {
        outBoxList.value = [];
        errorDialog(content: response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
