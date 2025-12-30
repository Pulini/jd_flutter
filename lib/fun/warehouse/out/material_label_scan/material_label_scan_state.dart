import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:jd_flutter/bean/http/response/material_label_scan_info.dart';
import 'package:jd_flutter/fun/warehouse/out/material_label_scan/material_label_scan_detail_view.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class MaterialLabelScanState {

  var dataList = <MaterialLabelScanInfo>[].obs;
  var dataDetailList = <MaterialLabelScanDetailInfo>[].obs;

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
        'NoticeDateStart': '2024-01-26',
        'NoticeDateEnd': '2025-12-26',
        'ProductName': '',
        'MaterialNumber': '',
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


  void getQueryDetail({
    required String workCardNo,
  }) {
    httpGet(
      loading: 'material_label_scan_get_material_detail'.tr,
      method: webApiGetPickMatDetail,
      params: {
        'WorkCardNo': workCardNo,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <MaterialLabelScanDetailInfo>[
          for (var i = 0; i < response.data.length; ++i)
            MaterialLabelScanDetailInfo.fromJson(response.data[i])
        ];
        dataDetailList.value = list;
        Get.to(() => const MaterialLabelScanDetailPage());
      } else {
        errorDialog(content: response.message ?? 'query_default_error'.tr);
      }
    });
  }
}