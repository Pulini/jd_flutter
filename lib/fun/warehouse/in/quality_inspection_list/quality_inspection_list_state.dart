import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/stuff_quality_inspection_detail_info.dart';
import 'package:jd_flutter/bean/http/response/quality_inspection_receipt_info.dart';
import 'package:jd_flutter/bean/http/response/quality_inspection_show_color.dart';
import 'package:jd_flutter/bean/http/response/stuff_quality_inspection_info.dart';

class QualityInspectionListState {
  var typeBody = ''; //型体
  var materialCode = ''; //物料编码
  var instruction = ''; //指令
  var inspectionOrder = ''; //检验单号
  var temporaryReceipt = ''; //暂收单号
  var receiptVoucher = ''; //入库凭证
  var trackingNumber = ''; //跟踪号

  var dataList = <StuffQualityInspectionInfo>[];
  var showDataList = <List<StuffQualityInspectionInfo>>[].obs;
  var showDetailDataList = <StuffQualityInspectionInfo>[].obs;
  var locationList = <StuffQualityInspectionDetailInfo>[]; //品检单详情，用于修改货位信息
  var colorList = <StuffColorSeparationList>[]; //分色信息
  var receiptList = <QualityInspectionReceiptInfo>[].obs; //分色接口信息
  var showReceiptColorList = <QualityInspectionShowColor>[].obs; //分色展示信息

  var btnShowStore = true.obs; //入库按钮
  var btnShowDelete = true.obs; //删除按钮
  var btnShowChange= true.obs; //修改按钮
  var btnShowLocation= true.obs; //货位按钮
  var btnShowColor = true.obs; //分色按钮
  var btnShowReverse = false.obs; //冲销









}
