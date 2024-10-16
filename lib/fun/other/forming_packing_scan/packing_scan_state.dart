
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/packing_shipment_scan_info.dart';

import '../../../../bean/http/response/container_scanner_info.dart';

class PackingScanState {

  var dataList = <ContainerScanner>[].obs;  //来访数据
  PackingShipmentScanInfo? packingShipmentScanInfo;//成型集装箱出货信息
  var outMessage = PackingShipmentScanInfo().GT_ITEMS;  //汇总拣货


  var cabinetNumber = ''.obs;//柜号


}