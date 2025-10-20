import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/bar_code.dart';
import 'package:jd_flutter/bean/http/response/check_code_info.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_info.dart';

class ProductionScanWarehouseState {


  var barCodeList = <BarCodeInfo>[].obs; //条码数据
  var usedBarCodeList = <UsedBarCodeInfo>[].obs; //入库过的条码数据
  var red = false.obs;  //是否红冲
  var palletNumber = ''.obs;  //托盘号
  var usedList = <String>[];
  PalletDetailItem2Info? pallet; //托盘信息
  var peopleName = ''.obs;  //员工名字

  var peopleNumber = TextEditingController(); //员工工号

  var codeDataInfo = CheckCodeInfo().obs;


  //从数据库读取条码信息
  ProductionScanWarehouseState() {
    BarCodeInfo.getSave(
      type: BarCodeReportType.productionScanInStock.text,
      callback: (list) => barCodeList.value = list,
    );
  }

}