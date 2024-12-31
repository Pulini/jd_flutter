import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_wms_reprint_label_info.dart';
import 'package:jd_flutter/utils/web_api.dart';

class SapWmsSplitLabelState {
  var labelList=<ReprintLabelInfo>[].obs;
  SapWmsSplitLabelState() {
    ///Initialize variables
  }
  getLabels({
    required String labelNumber,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在获取贴标信息...',
      method: webApiSapGetNewLabel,
      body: {
        'BQID': labelNumber,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        labelList.value = [
          for (var json in response.data) ReprintLabelInfo.fromJson(json)
        ];
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
