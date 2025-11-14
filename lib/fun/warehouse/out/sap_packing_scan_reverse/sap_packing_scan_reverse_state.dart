import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_scan_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class SapPackingScanReverseState {
  var reverseLabelList = <SapPackingScanReverseLabelInfo>[].obs;

  void getReverseLabelInfo({
    required String code,
    required Function(SapPackingScanReverseLabelInfo) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在获取标签信息...',
      method: webApiSapGetReverseLabelInfo,
      body: {'BQID': code},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(SapPackingScanReverseLabelInfo.fromJson(response.data)
          ..labelId = code);
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void reverseLabel({
    required Function(String) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在提交冲销标签...',
      method: webApiSapReverseLabel,
      body: {
        'ZBUDAT_MKPF': '',
        'USNAM': userInfo?.number,
        'ZNAME_CN': userInfo?.name,
        'BQIDS': [
          for (var item in reverseLabelList)
            {
              'BQID': item.labelId,
            }
        ],
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        reverseLabelList.clear();
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
