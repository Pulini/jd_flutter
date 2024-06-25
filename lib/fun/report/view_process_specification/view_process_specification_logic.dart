import 'dart:convert';
import 'package:get/get.dart';

import '../../../bean/http/response/process_specification_info.dart';
import '../../../web_api.dart';
import '../../../widget/dialogs.dart';
import 'view_process_specification_state.dart';

class ViewProcessSpecificationLogic extends GetxController {
  final ViewProcessSpecificationState state = ViewProcessSpecificationState();


  queryProcessSpecification() {
    if (state.etTypeBody.isEmpty) {
      errorDialog(content: '请输入型体');
      return;
    }
    httpGet(
      loading: '正在查询工艺说明书...',
      method: webApiGetProcessSpecificationList,
      params: {
        'Product': state.etTypeBody,
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
