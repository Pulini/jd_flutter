import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils/dio_manager.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/dialogs.dart';


class ViewInstructionDetailsState {
  // 是否已成功加载并显示 html 内容（控制 WebView 显隐）
  var showHtml = false.obs;


  void getInstructionDetailsFile({
    required String processFlowID,
    required String instruction,
    required Function(Uri uri) success,
    required Function(String msg) error,
  }) {
    httpGet(
      loading: 'view_instruction_details_querying'.tr,
      method: webApiGetInstructionDetailsFile,
      params: {
        'MoNo': instruction,
        'ProcessFlowID': processFlowID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(Uri.parse(response.data));
      } else {
        errorDialog(content: response.message ?? 'query_default_error'.tr);
      }
    });
  }
  void getFile({
    required String processFlowID,
    required String instruction,
    required Function(String html) success,
    required Function(String msg) error,
  }) {
    // 网络请求期间即显示loading，覆盖"服务端拼HTML + WebView渲染"全过程，
    // 避免无提示的2-3秒空白等待；loading由onPageFinished统一dismiss
    loadingShow('view_instruction_details_querying'.tr);
    Dio()
      ..interceptors.add(DioManager.simpleInterceptors)
      ..post(
        isTestUrl()
            ? 'http://192.168.99.103:9095/m'
            : 'https://erp.goldemperor.com:9051/m',
        queryParameters: {
          'xwl': 'public/interfaces/app/getOrderSheet',
        },
        data: {
          'orderNo': instruction,
          'processFlow':processFlowID,
          'language':language,
        },
      ).then((response) {
        loadingDismiss();
        var json=jsonDecode(response.data);
        if (json['successed']) {
          success.call(json['data']);
        } else {
          error.call(json['message']?? '');
        }
      }).catchError((e) {
        loadingDismiss();
        error.call(e.toString());
      });
  }
}
