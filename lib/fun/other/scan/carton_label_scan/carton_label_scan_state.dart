import 'package:get/get.dart';
import 'package:jd_flutter/utils/web_api.dart';

import '../../../../bean/http/response/carton_label_scan_info.dart';

class CartonLabelScanState {
  var cartonInsideLabelList = <LinkDataSizeList>[].obs;
  var cartonLabel=''.obs;
  CartonLabelScanInfo? cartonLabelInfo;

  CartonLabelScanState() {
    ///Initialize variables
  }

  queryCartonLabelInfo({
    required String code,
    required Function(dynamic msg) error,
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
        cartonLabel.value=cartonLabelInfo?.outBoxBarCode??'';
        cartonInsideLabelList.value = cartonLabelInfo!.linkDataSizeList ?? [];
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
