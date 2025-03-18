import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/bar_code.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_info.dart';
import 'package:jd_flutter/bean/http/response/used_bar_code_info.dart';


class SuppliersScanStoreState {

  var barCodeList = <BarCodeInfo>[].obs; //条码数据
  var usedBarCodeList = <UsedBarCodeInfo>[].obs; //入库过的条码数据
  var handCode = '';
  PalletDetailItem2Info? pallet;
  var palletNumber = ''.obs;  //托盘号
  var peopleName = ''.obs;  //员工名字
  var usedList = <String>[];
  var red = false.obs;

  var peopleNumber = TextEditingController(); //员工工号


  //从数据库读取条码信息
  SuppliersScanStoreState() {
    BarCodeInfo.getSave(
      type: BarCodeReportType.supplierScanInStock.text,
      callback: (list) => barCodeList.value = list,
    );
  }



}