import 'package:collection/collection.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:jd_flutter/bean/http/response/pack_order_list_info.dart';
import 'package:jd_flutter/utils/web_api.dart';

class PartLabelManageState {
  var labelList = <PartLabelInfo>[].obs;

  void getLabelList({
    required String barCode,
    required Function(String msg) error,
  }) {
    httpPost(
      method: webApiGetCardDetail,
      loading: 'part_label_manage_querying_label_info'.tr,
      body: {'CardNo': barCode},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        labelList.addAll(
          response.data
              .map<PartLabelInfo>((item) => PartLabelInfo.fromJson(item))
              .where((l) => labelList.none((v) => v.largeCardNo == l.largeCardNo)),
        );
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  void splitOrMergeLabel({
    required List<String> labels,
    required int splitQty,
    required Function(String, String) success,
    required Function(String) error,
  }) {
    httpPost(
      method: webApiSplitOrMergePackageLabel,
      loading: labels.length > 1
          ? 'part_label_manage_merging_label'.tr
          : 'part_label_manage_splitting_label'.tr,
      body: {
        'OperateType': labels.length > 1 ? 2 : 1,
        'CardNoList': labels,
        'SplitQty': splitQty,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.data['CardNo'], response.message ?? '');
      } else {
        error.call(response.message ?? '');
      }
    });
  }
}
