import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/forming_collection_info.dart';

class FormingBarcodeCollectionState {
  var dataList = <FormingCollectionInfo>[].obs;
  var showDataList = FormingCollectionInfo().obs; //显示的数据

  var factoryType = ''.obs; //工厂型体
  var group = ''.obs; //当前组别
  var saleOrder = ''.obs; //销售订单
  var customerOrder = ''.obs; //客户订单
  var scanCode = ''.obs; //扫到的条码
}