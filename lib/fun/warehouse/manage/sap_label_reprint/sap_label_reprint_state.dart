import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_carton_label_binding_info.dart';
import 'package:jd_flutter/utils/web_api.dart';

class SapLabelReprintState {
  var labelList = <SapPrintLabelInfo>[].obs;
  var isMaterialLabel = true.obs;
  var labelHasNots = true.obs;
  var printInsNo = true.obs;

  getLabelList({
    String? piece,
    String? code,
    required Function(List<SapPrintLabelInfo>) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'label_reprint_getting_label_info'.tr,
      method: webApiSapGetPrintLabelListInfo,
      body: {
        'BQID': code??'',
        'ZPIECE_NO': piece??'',
        'OPERATE': '',
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(
            [for (var json in response.data) SapPrintLabelInfo.fromJson(json)]);
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
