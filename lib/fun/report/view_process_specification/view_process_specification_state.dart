import 'package:get/get.dart';

import '../../../bean/http/response/process_specification_info.dart';
import '../../../web_api.dart';

class ViewProcessSpecificationState {
  RxList<ProcessSpecificationInfo> pdfList = <ProcessSpecificationInfo>[].obs;
  var etTypeBody = '';
  var isShowWeb = false.obs;

  getProcessSpecificationList({
    required Function() success,
    required Function(String msg) error,
  }) {
    httpGet(
      loading: '正在查询工艺说明书...',
      method: webApiGetProcessSpecificationList,
      params: {
        'Product': etTypeBody,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        pdfList.value = [
          for (var item in response.data)
            ProcessSpecificationInfo.fromJson(item)
        ];
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
