import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/process_plan_detail_info.dart';
import 'package:jd_flutter/bean/http/response/show_process_barcode_info.dart';
import 'package:jd_flutter/bean/http/response/show_process_plan_detail_info.dart';

class InjectionScanReportState {

  var showDataList = <ShowProcessPlanDetailInfo>[].obs;
  var showBarCodeList = <ShowProcessBarcodeInfo>[].obs;
  var dispatchNumber = "".obs;   //派工单号
  var machine = "".obs;  //机台
  var factoryType = "".obs;   //型体
  var dataBean = ProcessPlanDetailInfo();

}