import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/people_message_info.dart';
import 'package:jd_flutter/bean/http/response/quality_inspection_detail_info.dart';
import 'package:jd_flutter/bean/http/response/quality_inspection_info.dart';
import 'package:jd_flutter/bean/http/response/quality_inspection_receipt_info.dart';
import 'package:jd_flutter/bean/http/response/quality_inspection_show_color.dart';
import 'package:jd_flutter/bean/http/response/show_color_batch.dart';
import 'package:jd_flutter/bean/http/response/visit_photo_bean.dart';

class QualityInspectionListState {
  var typeBody = ''; //型体
  var materialCode = ''; //物料编码
  var instruction = ''; //指令
  var inspectionOrder = ''; //检验单号
  var temporaryReceipt = ''; //暂收单号
  var receiptVoucher = ''; //入库凭证
  var trackingNumber = ''; //跟踪号

  var dataList = <QualityInspectionInfo>[];
  var showDataList = <List<QualityInspectionInfo>>[].obs;
  var showDetailDataList = <QualityInspectionInfo>[].obs;
  var locationList = <QualityInspectionDetailInfo>[]; //品检单详情，用于修改货位信息
  var colorList = <ColorSeparationList>[]; //分色信息
  var receiptList = <QualityInspectionReceiptInfo>[].obs; //分色接口信息
  var showReceiptColorList = <QualityInspectionShowColor>[].obs; //分色展示信息

  var btnShowStore = false.obs; //入库按钮
  var btnShowDelete = false.obs; //删除按钮
  var btnShowChange= false.obs; //修改按钮
  var btnShowLocation= false.obs; //货位按钮
  var btnShowColor = false.obs; //分色按钮
  var btnShowReverse = false.obs; //冲销









}
