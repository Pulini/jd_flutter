import 'dart:ui';

import 'package:get/get.dart';
import 'package:jd_flutter/web_api.dart';
import 'package:jd_flutter/utils.dart';

import '../../../bean/http/request/update_porperty.dart';
import '../../../bean/http/response/property_detail_info.dart';
import '../../../bean/http/response/property_info.dart';
import '../../../widget/custom_widget.dart';

enum AuditedType { audited, unAudited, underAudit }

class PropertyState {
  var tabColors = <AuditedType, Color>{
    AuditedType.audited: const Color(0xff191970),
    AuditedType.unAudited: const Color(0xff40826d),
    AuditedType.underAudit: const Color(0xff007ba7),
  };
  Rx<AuditedType> selectedTab = AuditedType.audited.obs;
  RxList<PropertyInfo> propertyList = <PropertyInfo>[].obs;
  var detail = PropertyDetailInfo();
  var participatorName = ''.obs;
  var custodianName = ''.obs;
  var liableEmpName = ''.obs;
  var assetPicture = ''.obs;
  var ratingPlatePicture = ''.obs;
  bool canModify = false;
  var etPropertyNumber = '';
  var etPropertyName = '';
  var etSerialNumber = '';
  var etInvoiceNumber = '';
  var etName = '';
  var etWorkerNumber = '';
  PropertyState() {
    ///Initialize variables
  }

  setParticipator({String empCode = '', String empName = '', int empID = -1}) {
    detail.participatorCode = empCode;
    detail.participatorName = empName;
    detail.participator = empID;
    participatorName.value = empName;
  }

  setCustodian({String empCode = '', String empName = '', int empID = -1}) {
    detail.custodianCode = empCode;
    detail.custodianName = empName;
    custodianName.value = empName;
  }

  setLiable({String empCode = '', String empName = '', int empID = -1}) {
    detail.liableEmpCode = empCode;
    detail.liableEmpName = empName;
    detail.liableEmpID = empID;
    liableEmpName.value = empName;
  }

  bool checkData() {
    logger.f(detail.toJson());
    if (detail.name?.isEmpty == true) {
      showSnackBar(title: '缺少数据', message: '请输入名称',isWarning: true);
      return false;
    }
    if (detail.number?.isEmpty == true) {
      showSnackBar(title: '缺少数据', message: '请输入编号',isWarning: true);
      return false;
    }
    if (detail.model?.isEmpty == true) {
      showSnackBar(title: '缺少数据', message: '请输入规格型号',isWarning: true);
      return false;
    }
    if (detail.price != null && detail.price! <= 0) {
      showSnackBar(title: '缺少数据', message: '请输入单价',isWarning: true);
      return false;
    }
    if (detail.orgVal != null && detail.orgVal! <= 0) {
      showSnackBar(title: '缺少数据', message: '请输入原值',isWarning: true);
      return false;
    }
    if (detail.manufacturer?.isEmpty == true) {
      showSnackBar(title: '缺少数据', message: '请输入制造商',isWarning: true);
      return false;
    }
    if (detail.guaranteePeriod?.isEmpty == true) {
      showSnackBar(title: '缺少数据', message: '请输入保修期限(月)',isWarning: true);
      return false;
    }
    if (detail.expectedLife != null && detail.expectedLife! <= 0) {
      showSnackBar(title: '缺少数据', message: '请输入预计使用时长(月)',isWarning: true);
      return false;
    }
    if (detail.participator != null && detail.participator! == -1) {
      showSnackBar(title: '缺少数据', message: '请输入参检人工号',isWarning: true);
      return false;
    }
    if (detail.keepEmpID != null && detail.keepEmpID! == -1) {
      showSnackBar(title: '缺少数据', message: '请输入保管人工号',isWarning: true);
      return false;
    }
    if (detail.liableEmpID != null && detail.liableEmpID! == -1) {
      showSnackBar(title: '缺少数据', message: '请输入监管人工号',isWarning: true);
      return false;
    }
    if (detail.writeDate?.isEmpty == true) {
      showSnackBar(title: '缺少数据', message: '请选择登记日期',isWarning: true);
      return false;
    }
    if (detail.address?.isEmpty == true) {
      showSnackBar(title: '缺少数据', message: '请输入存放地点',isWarning: true);
      return false;
    }
    if (assetPicture.isEmpty) {
      showSnackBar(title: '缺少数据', message: '请拍摄现场照片',isWarning: true);
      return false;
    }
    if (ratingPlatePicture.isEmpty) {
      showSnackBar(title: '缺少数据', message: '请拍摄铭牌照片',isWarning: true);
      return false;
    }
    return true;
  }

  upDatePropertyBody() {
   var upDataBody= UpdateProperty()
      ..address = detail.address
      ..assetPicture = assetPicture.value
      ..ratingPlatePicture = ratingPlatePicture.value
      ..deptID = detail.deptID
      ..guaranteePeriod = detail.guaranteePeriod
      ..expectedLife = detail.expectedLife
      ..interID = detail.interID
      ..keepEmpID = detail.keepEmpID
      ..liableEmpID = detail.liableEmpID
      ..manufacturer = detail.manufacturer
      ..model = detail.model
      ..name = detail.name
      ..notes = detail.notes
      ..number = detail.number
      ..orgVal = detail.orgVal.toShowString()
      ..participator = detail.participator
      ..price = detail.price.toShowString()
      ..registrationerID = userInfo?.empID
      ..writeDate = detail.writeDate
      ..buyDate = detail.buyDate
      ..reviceDate = detail.reviceDate;
   logger.f(upDataBody.toJson());
    return upDataBody;
  }
}
