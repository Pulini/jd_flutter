import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/sap_wms_reprint_label_info.dart';
import 'package:jd_flutter/utils/web_api.dart';

class SapWmsSplitLabelState {
  var labelList = <ReprintLabelInfo>[].obs;
  ReprintLabelInfo? originalLabel;
  var hasOriginalLabel = false.obs;

  void dataFormat(BaseData response) {
    List<ReprintLabelInfo> list = [
      for (var json in response.data) ReprintLabelInfo.fromJson(json)
    ];
    List<ReprintLabelInfo> newLabel = [];
    for (var v in list) {
      if (v.isNewLabel == 'X') {
        newLabel.add(v);
      } else {
        originalLabel = v;
      }
    }
    labelList.value = newLabel;
    hasOriginalLabel.value = originalLabel != null;
  }

  void getLabels({
    required String labelNumber,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'sap_wms_split_label_getting_label_info'.tr,
      method: webApiSapGetNewLabel,
      body: {
        'BQID': labelNumber,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        dataFormat(response);
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void submitSplit({
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    sapPost(
      loading: 'sap_wms_split_label_splitting_label'.tr,
      method: webApiSapGetNewLabel,
      body: [
        {
          'BQID': originalLabel?.labelNumber,
          'ITEM': [
            {
              'KDAUF': originalLabel?.instructionNo,
              'SIZE1_ATINN': originalLabel?.size,
              'MENGE': originalLabel?.quantity,
            },
            for (var item in labelList)
              {
                'KDAUF': item.instructionNo,
                'SIZE1_ATINN': item.size,
                'MENGE': item.quantity,
              }
          ]
        }
      ],
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call('sap_wms_split_label_split_label_complete'.tr);
        dataFormat(response);
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
