import 'package:get/get.dart';
import 'package:jd_flutter/utils/web_api.dart';

class CartonLabelScanState {
  var cartonLabel=''.obs;
  var cartonInsideLabelList=<String>[].obs;
  CartonLabelScanState() {
    ///Initialize variables
  }


   queryCartonLabelInfo({required Function(dynamic msg) error}) {
     httpGet(
       loading:'正在查询外箱标签明细...',
       method: webApiGetPrdDayReport,
       params: {
         'barCode': cartonLabel.value,
       },
     ).then((response) {
       if (response.resultCode == resultSuccess) {
         // tableData.value = [
         //   for (var item in response.data) ProductionDayReportInfo.fromJson(item)
         // ];
         // Get.back(closeOverlays: true);
       } else {
         error.call(response.message ?? 'query_default_error'.tr);
       }
     });
   }
}
