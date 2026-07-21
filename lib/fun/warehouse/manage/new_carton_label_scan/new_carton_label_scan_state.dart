import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/carton_label_scan_info.dart';
import 'package:jd_flutter/bean/http/response/carton_label_scan_progress_info.dart';
import 'package:jd_flutter/bean/http/response/out_box_labels_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class NewCartonLabelScanState {
  var isAutoSubmit = true.obs;

  var isCheckingCartonBarCode = false;
  var cartonInsideLabelList = <LinkDataSizeNewList>[].obs;
  var cartonLabel = ''.obs;
  CartonLabelScanNewInfo? cartonLabelInfo;
  var labelTotal = 0.obs;
  var scannedLabelTotal = 0.obs;
  var progress = <CartonLabelScanProgressInfo>[].obs;
  var progressDetail = <List<CartonLabelScanProgressDetailInfo>>[].obs;

  var priorityCartonInsideLabelList = <LinkDataSizeNewList>[].obs;
  var priorityCartonLabel = ''.obs;
  var priorityPo = ''.obs;
  var dispatchNumber = ''.obs;
  var tailDispatchNumber = ''.obs;
  var dhmDispatchNumber = ''.obs;
  CartonLabelScanNewInfo? priorityCartonLabelInfo;

  var outBoxList = <OutBoxLabelsInfo>[].obs; //外箱数据
  var showIndex = 0;
  var add = true.obs; // 新增
  var tailLabelTotal = 0.obs; //清尾用的到统计
  var tailScannedLabelTotal = 0.obs; //清尾用的到扫了的统计
  var tailController = TextEditingController();

  void queryCartonLabelInfo({
    required String code,
    required Function(CartonLabelScanNewInfo) success,
    required Function(String) error,
  }) {
    if (isCheckingCartonBarCode) {
      return;
    }
    isCheckingCartonBarCode = true;
    httpGet(
      loading: 'carton_label_scan_querying_outside_label_detail'.tr,
      method: webApiGetCartonLabelInfoNew,
      params: {
        'CartonBarCode': code,
        'DispatchNumber': dispatchNumber.value,
        'OrganizeID': userInfo?.organizeID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(CartonLabelScanNewInfo.fromJson(response.data));
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
      isCheckingCartonBarCode = false;
    });
  }

  //清理优先级界面数据
  void clearPriority() {
    priorityCartonLabelInfo = CartonLabelScanNewInfo();
    priorityCartonLabel.value = '';
    priorityPo.value = '';
    priorityCartonInsideLabelList.value = [];
  }

  //更改优先级
  void changePOPriority({
    required String poNumber,
    required Function(String) success,
  }) {
    httpPost(
      loading: 'carton_label_scan_submitting_change_priority'.tr,
      method: webApiChangePOPriorityNew,
      params: {
        'PO': poNumber,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success
            .call(response.message ?? 'carton_label_scan_change_successful'.tr);
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
      method: webApiSubmitScannedCartonLabelNew,
      body: {
        'InterID': cartonLabelInfo?.interID,
        'CustOrderNumber': cartonLabelInfo?.custOrderNumber,
        'CartonBarCode': cartonLabelInfo?.outBoxBarCode,
        'Mix': cartonLabelInfo?.mix,
        'UserID': userInfo?.userID,
        'DispatchNumber': dispatchNumber.value,
        'Piece': cartonLabelInfo?.scanned.value,
        'OutBoxSizeList': [
          for (var data in cartonInsideLabelList)
            {
              'PriceBarCode': data.priceBarCode,
              'Size': data.size,
              'LabelCount': isAutoSubmit.value ? data.scanned : data.labelCount,
            }
        ]
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        labelTotal.value = 0;
        scannedLabelTotal.value = 0;
        isAutoSubmit.value = true;
        cartonLabelInfo = null;
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
      method: webApiGetCartonLabelScanHistoryNew,
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
      method: webApiGetCartonLabelScanHistoryDetailNew,
      params: {
        'InterID': id,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <CartonLabelScanProgressDetailInfo>[
          for (var json in response.data)
            CartonLabelScanProgressDetailInfo.fromJson(json)
        ];
        var group = <List<CartonLabelScanProgressDetailInfo>>[];
        groupBy(list, (v) => v.size ?? '').forEach((k, v) {
          group.add(v);
        });
        progressDetail.value = group;
        success.call();
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  //查询不满箱
  void queryNotFullBox({
    required String barCode,
  }) {
    httpGet(
      loading: 'carton_label_scan_order_get_last_detail'.tr,
      method: webApiGetMantissaDataNew,
      params: {
        'CartonBarCode': barCode,
        'DispatchNumber': tailDispatchNumber.value,
        'IsAddData': add.value,
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

  //不满箱提交
  void subMantissaData({
    required Function(String) success,
    required Function(String) error,
  }) {
    httpPost(
      loading: 'carton_label_scan_order_submit_last_detail'.tr,
      method: webApiSubMantissaDataNew,
      body: {
        'GUID': outBoxList[showIndex].guid,
        'InterID': outBoxList[showIndex].interID,
        'CustOrderNumber': outBoxList[showIndex].custOrderNumber,
        'CartonBarCode': outBoxList[showIndex].outBoxBarCode,
        'Mix': outBoxList[showIndex].mix,
        'UserID': getUserInfo()!.userID,
        'DispatchNumber': outBoxList[showIndex].dispatchNumber,
        'TailCartonCode': outBoxList[showIndex].tailCartonCode,
        'InnerBoxSizeList': [
          for (var list in outBoxList[showIndex].mantissaDataSizeList!)
            {
              'PriceBarCode': list.priceBarCode,
              'Size': list.size,
              'LabelCount': list.labelCount,
              'ShortQty': outBoxList[showIndex].guid!.isNotEmpty
                  ? list.thisShortQty! - list.shortQty!
                  : list.thisShortQty,
            }
        ]
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? 'process_report_success_submit'.tr);
      } else {
        error.call(response.message ?? 'process_report_error_submit'.tr);
      }
    });
  }

  //线别分析报告
  void getAnalyze() {
    httpGet(
      loading: 'forming_code_collection_getting'.tr,
      method: webApiGetDeptDistributeInfoNew,
      params: {
        'DeptmentID': getUserInfo()!.departmentID,
        'Date': '',
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        msgDialog(content: response.data);
      } else {
        errorDialog(content: response.message ?? 'query_default_error'.tr);
      }
    });
  }

  //确认条码
  void confirmTag({
    required Function(String) success,
    required String command,
  }) {
    httpGet(
      loading: 'carton_label_scan_verifying_label_barcode'.tr,
      method: webApiConfirmTag,
      params: {
        'MtoNo': command,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        errorDialog(content: response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
