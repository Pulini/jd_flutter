import 'package:get/get_rx/get_rx.dart';
import 'package:jd_flutter/bean/http/response/timely_inventory_show_info.dart';

class TimelyInventoryState {

  var instructionNumber=""; //指令号
  var batch=""; //批次
  var materialCode=""; //物料编码
  var dataList = <TimelyInventoryShowInfo>[].obs;

}