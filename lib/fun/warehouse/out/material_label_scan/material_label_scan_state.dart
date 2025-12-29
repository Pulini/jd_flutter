import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:jd_flutter/bean/http/response/material_label_scan_info.dart';
import 'package:jd_flutter/utils/web_api.dart';

class MaterialLabelState {

  var dataList = <MaterialLabelScanInfo>[].obs;

  var materialListNumber=''; //备料单号

  void getQueryList({
    required String startDate,
    required String endDate,
    required Function(String) error,
  }) {
    httpGet(
      loading: 'material_label_scan_get_material_list'.tr,
      method: webApiGetPickMatList,
      params: {
        'NoticeDateStart': '2025-01-26',
        'NoticeDateEnd': '2025-12-26',
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <MaterialLabelScanInfo>[
          for (var i = 0; i < response.data.length; ++i)
            MaterialLabelScanInfo.fromJson(response.data[i])
        ];

        dataList.value = list;
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}