import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';

import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:jd_flutter/bean/http/response/material_label_scan_info.dart';
import 'package:jd_flutter/fun/warehouse/out/material_label_scan/material_label_scan_detail_view.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class MaterialLabelScanState {
  var dataList = <MaterialLabelScanInfo>[].obs;
  var dataDetailList = <MaterialLabelScanDetailInfo>[].obs;
  var scanDetailList = <MaterialLabelScanBarCodeInfo>[];
  var commandNumber = ''.obs; //指令号
  var allQty = ''.obs; //订单总量
  var canScan = true; //是否能扫描

  var materialListNumber = ''; //备料单号

  //备料任务清单
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

  //备料任务详情
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
        allQty.value = list
            .map((v) => v.orderQty ?? 0.0)
            .reduce((a, b) => a.add(b))
            .toShowString();
        list.add(MaterialLabelScanDetailInfo(
            size: '合计',
            orderQty:
                list.map((v) => v.orderQty ?? 0.0).reduce((a, b) => a.add(b)),
            qtyReceived: list
                .map((v) => v.qtyReceived ?? 0.0)
                .reduce((a, b) => a.add(b)),
            unclaimedQty: list
                .map((v) => v.unclaimedQty ?? 0.0)
                .reduce((a, b) => a.add(b))));
        var nameList = <String>[];
        for (var c in list) {
          if (!nameList.contains(c.mtoNo) && c.mtoNo != null) {
            nameList.add(c.mtoNo.toString());
          }
        }
        var command = '';
        for (var s in nameList) {
          command += '$s,';
        }
        if (command.isNotEmpty) {
          command = command.substring(0, command.length - 1);
        }
        commandNumber.value = command;
        dataDetailList.value = list;
        Get.to(() => const MaterialLabelScanDetailPage());
      } else {
        errorDialog(content: response.message ?? 'query_default_error'.tr);
      }
    });
  }

  //备料通过条码获取指令尺码数量信息
  void getQueryBarCodeDetail({
    required String barCode,
    required Function() success,
    required Function(String) error,
  }) {
    httpGet(
      loading: 'material_label_scan_detail_get_barcode_message'.tr,
      method: webApiPickGetBarCodeInfo,
      params: {
        'BarCode': '2049423001196.5/3001',
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <MaterialLabelScanBarCodeInfo>[
          for (var i = 0; i < response.data.length; ++i)
            MaterialLabelScanBarCodeInfo.fromJson(response.data[i])
        ];
        setScanDetail(
            lists: list,
            success: () {
              success.call();
            });
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  //设置扫码信息
  void setScanDetail({
    required List<MaterialLabelScanBarCodeInfo> lists,
    required Function() success,
  }) {
    for (var c in lists) {
      for (var d in dataDetailList) {
        if (d.size == c.size) {
          d.thisTime = c.barCodeQty;
          d.isScan = true;
        }
      }
    }
    success.call();
  }

  //备料提交领料
  void submitCodeDetail({
    required Function() success,
    required Function(String) error,
  }) {
    httpPost(
      loading: 'material_label_scan_detail_submit_message'.tr,
      method: webApiSubmitPickMatDetail,
      body: {
        'WorkCardInterID': '',
        'UserID': userInfo!.userID,
        'pickMatDetailItems': [
          for (var c in dataDetailList..where((v) => v.size != '合计').toList())
            {
              'SrcICMOInterID': '',
              'MaterialID': '',
              'Size': '',
              'SubmitQty': '',
            }
        ]
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <MaterialLabelScanBarCodeInfo>[
          for (var i = 0; i < response.data.length; ++i)
            MaterialLabelScanBarCodeInfo.fromJson(response.data[i])
        ];
        setScanDetail(
            lists: list,
            success: () {
              success.call();
            });
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
