import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/sap_wms_reprint_label_info.dart';
import 'package:jd_flutter/utils/web_api.dart';

class SapWmsSplitLabelState {
  var labelList = <ReprintLabelInfo>[].obs;
  ReprintLabelInfo? originalLabel;
  var hasOriginalLabel = false.obs;

  SapWmsSplitLabelState() {
    ///Initialize variables
  }

  dataFormat(BaseData response) {
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
        dataFormat(response);
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  submitSplit({
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    sapPost(
      loading: '正在拆分贴标...',
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
        success.call('贴标拆分完成');
        dataFormat(response);
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
