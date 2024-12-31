import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_wms_reprint_label_info.dart';
import 'package:jd_flutter/utils/web_api.dart';

class SapWmsReprintLabelsState {
  var palletNumber = ''.obs;
  var labelList = <ReprintLabelInfo>[].obs;

  SapWmsReprintLabelsState() {
    ///Initialize variables
  }

  getLabels({
    required String warehouse,
    String? palletNumber,
    String? labelNumber,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在提交上架信息...',
      method: webApiSAPGetLabels,
      body: {
        'WERKS': '1500',
        'LGORT': '',
        'ITEM': [
          {
            'ZFTRAYNO': palletNumber ?? '',
            'BQID': labelNumber ?? '',
          }
        ]
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        labelList.value = [
          for (var json in response.data) ReprintLabelInfo.fromJson(json)
        ];
        this.palletNumber.value = labelList[0].palletNumber ?? '';
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
