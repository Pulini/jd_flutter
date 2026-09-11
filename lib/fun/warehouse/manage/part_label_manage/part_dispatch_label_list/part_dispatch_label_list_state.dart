import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:jd_flutter/bean/http/response/pack_order_list_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class PartDispatchLabelListState {
  var labelList = <PartLabelInfo>[].obs;

  void getLabelList({
    String? partIds,
    int? packOrderId,
    required Function() success,
    required Function(String msg) error,
  }) {
    httpGet(
      method: webApiGetLargeCardNoList,
      loading: 'part_dispatch_label_getting_label_list'.tr,
      body: {
        'WorkCardEntryFIDs': partIds ?? '',
        'OrderPackageID': packOrderId ?? 0,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        labelList.value = [
          for (var item in response.data) PartLabelInfo.fromJson(item)
        ];
        success.call();
      } else {
        labelList.value = [];
        error.call(response.message ?? '');
      }
    });
  }

  void deleteLabelList({
    required List<String> labelList,
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    httpPost(
      method: webApiDeletePartProductionDispatchLabels,
      loading: 'part_dispatch_label_deleting_label'.tr,
      body: {'CardNos': labelList},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  void lockOrUnLockLabelList({
    required bool isLock,
    required List<String> labelList,
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    httpPost(
      method: webApiPackageLabelLockOrUnLock,
      loading: isLock
          ? 'part_dispatch_label_print_locking'.tr
          : 'part_dispatch_label_print_unlocking'.tr,
      body: {
        'UserID': userInfo?.userID,
        'IsLock': isLock,
        'orderPackageSubEntryItems': [
          for (var item in labelList) {'CardNo': item}
        ],
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? '');
      }
    });
  }
}
