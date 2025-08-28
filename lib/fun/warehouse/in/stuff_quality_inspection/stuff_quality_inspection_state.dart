import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/people_message_info.dart';
import 'package:jd_flutter/bean/http/response/show_color_batch.dart';
import 'package:jd_flutter/bean/http/response/stuff_quality_inspection_info.dart';
import 'package:jd_flutter/bean/http/response/stuff_quality_inspection_label_info.dart';
import 'package:jd_flutter/bean/http/response/temporary_order_info.dart';
import 'package:jd_flutter/bean/http/response/visit_photo_bean.dart';

class StuffQualityInspectionState {
  var inspectionColorList = <ShowColorBatch>[].obs; //品检分色信息
  var unColorQty = ''.obs; //未分色数量
  var picture = <VisitPhotoBean>[].obs; //照片上传
  var compromise = false.obs; //是否让步
  var showColor = false.obs; //是否显示分色按钮
  var showAllBtn = false.obs; //是否显示全部按钮
  var showAllBtnName = '全部合格'.obs; //是否显示全部按钮

  var inspectionTypeEnable = true.obs; //sp检验方式是否能点击
  var typeEnable = true.obs; //sp类别是否能点击
  var groupTypeEnable = false.obs; //sp受理单位是否能点击

  var inspectionEnable = true.obs; //检验数量输入框是否能点击
  var waitInputInspectionEnable = true.obs; //待检验数量输入框是否能点击
  var unqualifiedQuantityEnable = true.obs; //不合格数量输入框是否能点击
  var shortQuantityEnable = true.obs; //短码数量输入框是否能点击
  var abnormalExplanationEnable = true.obs; //异常说明
  var processingMethodEnable = true.obs; //处理方法

  var peoPleInfo = PeopleMessageInfo().obs; //员工详情

  var inspectionType = '无'.obs; //检验类型
  var type = '无'.obs; //类别
  var groupType = '无'.obs; //受理单位

  var isShowTips = false.obs; //是否显示提示

  var toCreateOrderMes = ''; //来源编号

  var list1 = ['无', '抽检', '全检'];
  var list2 = ['无', '面料', '里料', '底料', '针辅', '包材', '楦头', '模具'];
  var list3 = ['无', '面部采购课', '底部采购课', '采购中心'];

  var inspectionsListData = <StuffQualityInspectionInfo>[]; //品检单列表带过来的数据

  var isSameCode = true; //是否是同一物料

  var hadSplit = false; //是否能分色

  var defaultReviewer = ''; //默认审核人

  var fromInspectionType = '1'; //品检来源 //1 品检单列表  2 暂收单详情

  //--------------// 暂收单详情
  TemporaryOrderDetailInfo? detailInfo;

  var deliveryNoteNumberToSelect = ''; //送货单号
  var inspectionNumberToSelect = ''; //暂收单号
  var labelData = <StuffQualityInspectionLabelInfo>[].obs; //提交品检获取的贴标信息
  var labelUnQty = 0.0; //贴标合格
  var labelShortQty = 0.0; //贴标短码
}
