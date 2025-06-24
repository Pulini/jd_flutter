import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/forming_barcode_by_mono_info.dart';
import 'package:jd_flutter/bean/http/response/forming_collection_info.dart';
import 'package:jd_flutter/bean/http/response/forming_mono_detail_info.dart';
import 'package:jd_flutter/bean/http/response/forming_scan_info.dart';
import 'package:jd_flutter/bean/http/response/work_card_priority_info.dart';

class FormingBarcodeCollectionState {
  var dataList = <FormingCollectionInfo>[].obs;
  var copyDataList = <FormingCollectionInfo>[];
  var showDataList = <ScWorkCardSizeInfos>[].obs; //显示的数据
  var showScanDataList = <ScWorkCardSizeInfos>[].obs; //扫码清尾显示的数据

  var factoryType = ''.obs; //工厂型体
  var saleOrder = ''.obs; //销售订单
  var customerOrder = ''.obs; //客户订单
  var scanCode = ''.obs; //扫到的条码
  var workCardInterID = ''; //派工单ID
  var instruction = ''; //指令ID

  var factoryTypeClear= ''.obs; //工厂型体 ->扫码清尾
  var saleOrderClear= ''.obs; //销售订单 ->扫码清尾
  var customerOrderClear= ''.obs; //客户订单 ->扫码清尾
  var orderNumClear= ''.obs; //订单数量 ->扫码清尾
  var completionNumClear= ''.obs; //累计完成 ->扫码清尾

  var prioriInfoList = <WorkCardPriorityInfo>[].obs;


  var scanInfoDataList = <FormingScanInfo>[].obs;  //历史记录
  var searchDetail = <FormingMonoDetailInfo>[].obs;  //单号详情
  var historyMes = '';  //历史记录  分析报告

  var canScan = true; //可以进行扫描

  var shoeInstruction=''; //鞋盒匹配用到的指令号
  var btnName='补零'.obs; //补零或清零
  var barCodeByMonoData = <FormingBarcodeByMonoInfo>[].obs;

}