import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../http/response/process_specification_info.dart';
import '../../../http/web_api.dart';
import '../../../widget/dialogs.dart';
import 'view_process_specification_state.dart';

class ViewProcessSpecificationLogic extends GetxController {
  final ViewProcessSpecificationState state = ViewProcessSpecificationState();
  var textControllerTypeBody = TextEditingController();

  queryProcessSpecification() {
    if (textControllerTypeBody.text.trim().isEmpty) {
      errorDialog(content: '请输入型体');
      return;
    }
    httpGet(
      loading: '正在查询工艺说明书...',
      method: webApiGetProcessSpecificationList,
      query: {
        'Product': textControllerTypeBody.text,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        Get.back();
        var list = <ProcessSpecificationInfo>[];
        for (var item in jsonDecode(response.data)) {
          list.add(ProcessSpecificationInfo.fromJson(item));
        }
        state.pdfList.value = list;

      } else {
        errorDialog(content: response.message ?? 'query_default_error'.tr);
      }
    });
  }


}
