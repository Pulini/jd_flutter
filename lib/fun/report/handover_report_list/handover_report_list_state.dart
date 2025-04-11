import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/handover_report_list_info.dart';
import 'package:jd_flutter/bean/http/response/show_handover_report_list.dart';

class HandoverReportListState {
  var isChecked = false.obs;
  var reportPosition = 0;
  var shiftType = 0;
  var dataList = <ShowHandoverReportList>[].obs;
  var handoverDataList = <HandoverReportListInfo>[];

}