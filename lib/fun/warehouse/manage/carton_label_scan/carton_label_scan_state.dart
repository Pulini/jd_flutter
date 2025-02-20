import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/carton_label_scan_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';


class CartonLabelScanState {
  var cartonInsideLabelList = <LinkDataSizeList>[].obs;
  var cartonLabel = ''.obs;
  CartonLabelScanInfo? cartonLabelInfo;
  var labelTotal = 0.obs;
  var scannedLabelTotal = 0.obs;

  CartonLabelScanState() {
    //Initialize variables
  }

  queryCartonLabelInfo({
    required String code,
    required Function(String) error,
  }) {
    labelTotal.value=0;
    scannedLabelTotal.value=0;
    httpGet(
      loading: '正在查询外箱标签明细...',
      method: webApiGetCartonLabelInfo,
      params: {
        'CartonBarCode': code,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        cartonLabelInfo = CartonLabelScanInfo.fromJson(response.data);
        cartonLabel.value = cartonLabelInfo?.outBoxBarCode ?? '';
        cartonInsideLabelList.value = cartonLabelInfo!.linkDataSizeList ?? [];
        labelTotal.value = cartonInsideLabelList.fold(
            0, (total, next) => total + next.labelCount!);
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  submitScannedCartonLabel({
    required Function(String) success,
    required Function(String) error,
  }) {
    httpPost(
      loading: '正在提交扫码进度...',
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
}
