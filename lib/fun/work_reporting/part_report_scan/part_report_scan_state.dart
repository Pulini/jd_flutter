import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/component_code_info.dart';
import 'package:jd_flutter/bean/http/response/part_report_error_info.dart';
import 'package:jd_flutter/bean/http/response/report_details_info.dart';

class PartReportScanState{
    var modifyCode =''; //手动录入的条码
    var buttonType = true.obs;   //新增或删除
    var dataList = <ComponentCodeInfo>[].obs;  //条码列表
    var reportInfo = <SummaryLists>[].obs;
    var productName = ''.obs;
    var errorInfo =PartReportErrorInfo();
}