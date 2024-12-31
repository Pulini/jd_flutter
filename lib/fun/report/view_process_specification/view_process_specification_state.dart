import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/process_specification_info.dart';
import 'package:jd_flutter/utils/web_api.dart';


class ViewProcessSpecificationState {
  RxList<ProcessSpecificationInfo> pdfList = <ProcessSpecificationInfo>[].obs;
  var etTypeBody = '';
  var isShowWeb = false.obs;

  getProcessSpecificationList({
    required Function() success,
    required Function(String msg) error,
  }) {
    if(etTypeBody.isEmpty){
      return;
    }
    httpGet(
      loading: 'view_process_specification_querying'.tr,
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
        success.call();
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
