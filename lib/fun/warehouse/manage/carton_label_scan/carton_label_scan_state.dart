import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/carton_label_scan_info.dart';
import 'package:jd_flutter/bean/http/response/carton_label_scan_progress_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/dialogs.dart';


class CartonLabelScanState {
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
  CartonLabelScanInfo? priorityCartonLabelInfo;

  queryCartonLabelInfo({
    required String code,
    required Function(String) error,
  }) {
    labelTotal.value=0;
    scannedLabelTotal.value=0;
    httpGet(
      loading:'carton_label_scan_querying_outside_label_detail'.tr  ,
      method: webApiGetCartonLabelInfo,
      params: {
        'CartonBarCode': code,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
          cartonLabelInfo = CartonLabelScanInfo.fromJson(response.data);
          cartonLabel.value = cartonLabelInfo?.outBoxBarCode ?? '';
          cartonInsideLabelList.value = cartonLabelInfo!.linkDataSizeList ?? [];
          labelTotal.value = cartonInsideLabelList.fold(0, (total, next) => total + next.labelCount!);
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  //清理优先级界面数据
  clearPriority(){
    priorityCartonLabelInfo = CartonLabelScanInfo();
    priorityCartonLabel.value = '';
    priorityPo.value='';
    priorityCartonInsideLabelList.value = [];
  }

  //更改优先级
  changePOPriority({
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

  submitScannedCartonLabel({
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



  getCartonLabelScanHistory({
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

  getCartonLabelScanHistoryDetail({
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
}
