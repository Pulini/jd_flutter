import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_carton_label_binding_info.dart';
import 'package:jd_flutter/utils/web_api.dart';

class SapLabelReprintState {
  var labelList = <SapPrintLabelInfo>[].obs;

  getLabelList({required String code, required Function(String) error}) {
    sapPost(
      loading: 'label_reprint_getting_label_info'.tr,
      method: webApiSapGetPrintLabelListInfo,
      body: {
        'BQID': code,
        'OPERATE': '10',
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        labelList.value = [
          for (var json in response.data) SapPrintLabelInfo.fromJson(json)
        ];
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
