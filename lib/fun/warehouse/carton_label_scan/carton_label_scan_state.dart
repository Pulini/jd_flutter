import 'package:get/get.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

import '../../../../bean/http/response/carton_label_scan_info.dart';

class CartonLabelScanState {
  var cartonInsideLabelList = <LinkDataSizeList>[].obs;
  var cartonLabel = ''.obs;
  CartonLabelScanInfo? cartonLabelInfo;

  CartonLabelScanState() {
    ///Initialize variables
  }

  queryCartonLabelInfo({
    required String code,
    required Function(String) error,
  }) {
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
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
