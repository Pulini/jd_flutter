import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/dispatch_info.dart';

class ProcessReportState{

  //接口数据
  var dataList = <DispatchInfo>[].obs;
  //条码总数
  var allQty=0.0.obs;
}