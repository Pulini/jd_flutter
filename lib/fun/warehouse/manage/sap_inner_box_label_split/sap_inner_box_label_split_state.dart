import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_carton_label_binding_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class SapInnerBoxLabelSplitState {
  SapPrintLabelInfo? originalLabel;
  var splitLabelList = <List<SapLabelSplitInfo>>[].obs;
  var newLabelList = <SapPrintLabelInfo>[].obs;

  getLabelPrintInfo({
    required String code,
    required Function() refresh,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'inner_box_label_split_getting_label_info'.tr,
      method: webApiSapGetPrintLabelListInfo,
      body: {'BQID': code},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        originalLabel = SapPrintLabelInfo.fromJson(response.data[0]);
      } else {
        originalLabel = null;
        error.call(response.message ?? 'query_default_error'.tr);
      }
      refresh.call();
    });
  }

  submitPreSplitLabel({
    required Function() success,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'inner_box_label_split_submit_label_split'.tr,
      method: webApiSapSubmitLabelSplit,
      body: [
        {
          'BQID': originalLabel!.labelID,
          'ZPIECE_NO': originalLabel!.pieceID,
          'USNAM': userInfo?.number,
          'ZNAME_CN': userInfo?.name,
          'ITEM': [
            for (var material in (originalLabel!.subLabel!)
                .where((v) => v.canSplitQty.value > 0))
              {
                'MATNR': material.materialNumber,
                'MENGE': material.canSplitQty.value.toShowString(),
                'MEINS': material.unit,
              }
          ],
        },
        for (var label in splitLabelList)
          {
            'BQID': originalLabel!.labelID,
            'ZPIECE_NO': originalLabel!.pieceID,
            'USNAM': userInfo?.number,
            'ZNAME_CN': userInfo?.name,
            'ITEM': [
              for (var material in label)
                {
                  'MATNR': material.materialNumber,
                  'MENGE': material.qty.toShowString(),
                  'MEINS': material.unit,
                }
            ],
          }
      ],
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        newLabelList.value = [
          for (var json in response.data) SapPrintLabelInfo.fromJson(json)
        ];
        originalLabel = null;
        splitLabelList.clear();
        success.call();
      } else {
        newLabelList.value = [];
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
