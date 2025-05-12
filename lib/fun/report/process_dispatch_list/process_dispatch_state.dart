import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/process_work_card_detail_info.dart';
import 'package:jd_flutter/bean/http/response/process_work_card_list_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/utils.dart';

class ProcessDispatchState{
  var workTicket =''; //工票
  var personalNumber =''; //工号
  var dataList = <ProcessWorkCardListInfo>[].obs;   //工序派工单列表数据
  ProcessWorkCardDetailInfo? workCardDetail;
  var showDetailList = <SizeLists>[].obs;   //详情列表
  var showLabelList = <Barcodes>[].obs;   //贴标列表
  var colorList = <String>[];   //色系
  var instructionList = <String>[];   //指令

  var createLabelQty = '1';
  var submitType = (spGet(processDispatchType) ?? '单码').toString().obs;
  var selectAllList = false.obs;  //列表全选
  var foot = false.obs;  //左右脚
  var selectAll = false.obs; //贴标全选
 }