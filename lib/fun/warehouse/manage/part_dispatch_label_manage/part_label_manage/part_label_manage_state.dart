import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:jd_flutter/bean/http/response/pack_order_list_info.dart';
import 'package:jd_flutter/utils/web_api.dart';

class PartLabelManageState {
  var barCode = '';
  var selectAll = false.obs;
  var isPrinted = false.obs;
  var searchText = ''.obs;
  var labelList = <PartLabelInfo>[].obs;

  void getLabelList({
    required String barCode,
    Function()? noPackingMethod,
    required Function(String msg) error,
  }) {
    this.barCode = barCode;
    httpGet(
      method: webApiGetOrderPackageDetail,
      loading: 'part_dispatch_label_getting_label_list'.tr,
      params: {'processCardNo': barCode},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = [
          for (var item in response.data) PartLabelInfo.fromJson(item)
        ];
        if (list.isEmpty) {
          noPackingMethod?.call();
        } else {
          labelList.value = list;
        }
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

  void updateLabelPrintState({
    required List<String> labelList,
    required Function() success,
    required Function(String msg) error,
  }) {
    httpPost(
      method: webApiUpdatePrintData,
      loading: 'part_dispatch_label_updating_label'.tr,
      body: {'BarCodeList': labelList},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call();
      } else {
        error.call(response.message ?? '');
      }
    });
  }
}
