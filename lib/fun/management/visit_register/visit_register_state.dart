import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/visit_add_record_info.dart';
import 'package:jd_flutter/bean/http/response/visit_data_list_info.dart';
import 'package:jd_flutter/bean/http/response/visit_get_detail_info.dart';
import 'package:jd_flutter/bean/http/response/visit_photo_bean.dart';

class VisitRegisterState {   //接口数据返回
  var dataList = <VisitDataListInfo>[].obs;  //来访数据
  var dataDetail = VisitGetDetailInfo();  //来访单据详情
  var upAddDetail = VisitAddRecordInfo().obs;  //新增来访单据
  var visitCode = ''.obs;  //邀请码
  var select = ''.obs; //选择查询的条件
  var searchMes = ''; //用来查询人员信息的内容
  var lastAdd = false; //是不是最后一次离场记录

  var cardPicture = ''.obs;  //身份证照片
  var facePicture = ''.obs;  //正脸照片
  var comePicture = <String>[].obs;  //来访照片详情
  var upLeavePicture = <VisitPhotoBean>[].obs;  //离场照片上传
  var upComePicture = <VisitPhotoBean>[].obs;  //来访照片上传
  var carType = "".obs;  //车辆类型
  var doorType = "1号门".obs;  //门号

  var  checkCarBottom =  false;  //轮区检查 checkBox
  var  checkCarExterior =  false;  //外部检查 checkBox
  var  checkCarRear =  false;  //尾部检查 checkBox
  var  checkCarCab =  false;  //驾驶室检查 checkBox
  var  checkCarLandingGear=  false;  //起落架检查 checkBox

  var canInput = false.obs;   //是否可以输入
  var showWeight = false.obs;   //是否显示拖车内容
  var showCarNumber = false.obs;   //是否显示车牌号

  //新增界面拖车的检查控制
  var  checkCarBottomValue =  false.obs;  //轮区检查 checkBox
  var  checkCarExteriorValue =  false.obs;  //外部检查 checkBox
  var  checkCarRearValue =  false.obs;  //尾部检查 checkBox
  var  checkCarCabValue =  false.obs;  //驾驶室检查 checkBox
  var  checkCarLandingGearValue=  false.obs;  //起落架检查 checkBox
}
