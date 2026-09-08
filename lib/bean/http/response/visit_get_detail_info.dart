
import 'package:jd_flutter/bean/http/response/photo_bean.dart';
import 'package:jd_flutter/utils/extension_util.dart';

// InterID : "2301"
// Number : "LFRY2002301"
// Name : "123"
// IDCard : "330322199408121215"
// Unit : "123"
// Phone : "15267733968"
// VisitedFactory : "金帝集团股份有限公司"
// Gate : "1号门"
// VisitedDept : "123"
// IntervieweeID : "0"
// IntervieweeName : ""
// ActionZone : "一楼会客厅"
// ActionZoneID : "0"
// VisitorNum : "123"
// SubjectMatter : "1234"
// Credentials : "123"
// SecurityStaff : "张幸民"
// DateTime : "2024/3/5 14:51:14"
// LeaveTime : ""
// CarNo : ""
// CarType : ""
// OwnGoods : ""
// CarBottom : "正常"
// CarExterior : "正常"
// CarRear : "正常"
// CarCab : "正常"
// LandingGear : "正常"
// Note : ""
// ExamineID : "张幸民"
// DataSourceType : "0"
// SourceID : "0"
// SubmitType : "0"
// VisitPics : [{"Photo":"https://geapp.goldemperor.com:8084/金帝集团股份有限公司/来访登记表/2020/11/BCRK_LFRY2000002/LFRY2000002_来访_0.jpg"}]
// LeavePics : [{"Photo":"https://geapp.goldemperor.com:8084/金帝集团股份有限公司/来访登记表/2020/11/BCRK_LFRY2000002/LFRY2000002_来访_0.jpg"}]
// PeoPic : ""
// CardPic : ""

class VisitGetDetailInfo {
  VisitGetDetailInfo({
      this.interID, 
      this.number, 
      this.name, 
      this.iDCard, 
      this.unit, 
      this.phone, 
      this.visitedFactory, 
      this.gate, 
      this.visitedDept, 
      this.intervieweeID, 
      this.intervieweeName, 
      this.actionZone, 
      this.actionZoneID, 
      this.visitorNum, 
      this.subjectMatter, 
      this.credentials, 
      this.securityStaff, 
      this.dateTime, 
      this.leaveTime, 
      this.carNo, 
      this.carType, 
      this.ownGoods, 
      this.carBottom, 
      this.carExterior, 
      this.carRear, 
      this.carCab, 
      this.landingGear, 
      this.note, 
      this.examineID, 
      this.dataSourceType, 
      this.sourceID, 
      this.submitType, 
      this.visitPics, 
      this.leavePics, 
      this.peoPic, 
      this.cardPic,});

  VisitGetDetailInfo.fromJson(dynamic json) {
    interID = JsonParse.str(json['InterID']);
    number = JsonParse.str(json['Number']);
    name = JsonParse.str(json['Name']);
    iDCard = JsonParse.str(json['IDCard']);
    unit = JsonParse.str(json['Unit']);
    phone = JsonParse.str(json['Phone']);
    visitedFactory = JsonParse.str(json['VisitedFactory']);
    gate = JsonParse.str(json['Gate']);
    visitedDept = JsonParse.str(json['VisitedDept']);
    intervieweeID = JsonParse.str(json['IntervieweeID']);
    intervieweeName = JsonParse.str(json['IntervieweeName']);
    actionZone = JsonParse.str(json['ActionZone']);
    actionZoneID = JsonParse.str(json['ActionZoneID']);
    visitorNum = JsonParse.str(json['VisitorNum']);
    subjectMatter = JsonParse.str(json['SubjectMatter']);
    credentials = JsonParse.str(json['Credentials']);
    securityStaff = JsonParse.str(json['SecurityStaff']);
    dateTime = JsonParse.str(json['DateTime']);
    leaveTime = JsonParse.str(json['LeaveTime']);
    carNo = JsonParse.str(json['CarNo']);
    carType = JsonParse.str(json['CarType']);
    ownGoods = JsonParse.str(json['OwnGoods']);
    carBottom = JsonParse.str(json['CarBottom']);
    carExterior = JsonParse.str(json['CarExterior']);
    carRear = JsonParse.str(json['CarRear']);
    carCab = JsonParse.str(json['CarCab']);
    landingGear = JsonParse.str(json['LandingGear']);
    note = JsonParse.str(json['Note']);
    examineID = JsonParse.str(json['ExamineID']);
    dataSourceType = JsonParse.str(json['DataSourceType']);
    sourceID = JsonParse.str(json['SourceID']);
    submitType = JsonParse.str(json['SubmitType']);
    visitPics = JsonParse.list(json['VisitPics'], PhotoBean.fromJson);
    leavePics = JsonParse.list(json['LeavePics'], PhotoBean.fromJson);
    peoPic = JsonParse.str(json['PeoPic']);
    cardPic = JsonParse.str(json['CardPic']);
  }
  String? interID;
  String? number;
  String? name;
  String? iDCard;
  String? unit;
  String? phone;
  String? visitedFactory;
  String? gate;
  String? visitedDept;
  String? intervieweeID;
  String? intervieweeName;
  String? actionZone;
  String? actionZoneID;
  String? visitorNum;
  String? subjectMatter;
  String? credentials;
  String? securityStaff;
  String? dateTime;
  String? leaveTime;
  String? carNo;
  String? carType;
  String? ownGoods;
  String? carBottom;  //轮区
  String? carExterior;  //外部
  String? carRear;  //尾部
  String? carCab;  //驾驶室
  String? landingGear;  //起落架
  String? note;
  String? examineID;
  String? dataSourceType;
  String? sourceID;
  String? submitType;
  List<PhotoBean>? visitPics;
  List<PhotoBean>? leavePics;
  String? peoPic;
  String? cardPic;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['InterID'] = interID;
    map['Number'] = number;
    map['Name'] = name;
    map['IDCard'] = iDCard;
    map['Unit'] = unit;
    map['Phone'] = phone;
    map['VisitedFactory'] = visitedFactory;
    map['Gate'] = gate;
    map['VisitedDept'] = visitedDept;
    map['IntervieweeID'] = intervieweeID;
    map['IntervieweeName'] = intervieweeName;
    map['ActionZone'] = actionZone;
    map['ActionZoneID'] = actionZoneID;
    map['VisitorNum'] = visitorNum;
    map['SubjectMatter'] = subjectMatter;
    map['Credentials'] = credentials;
    map['SecurityStaff'] = securityStaff;
    map['DateTime'] = dateTime;
    map['LeaveTime'] = leaveTime;
    map['CarNo'] = carNo;
    map['CarType'] = carType;
    map['OwnGoods'] = ownGoods;
    map['CarBottom'] = carBottom;
    map['CarExterior'] = carExterior;
    map['CarRear'] = carRear;
    map['CarCab'] = carCab;
    map['LandingGear'] = landingGear;
    map['Note'] = note;
    map['ExamineID'] = examineID;
    map['DataSourceType'] = dataSourceType;
    map['SourceID'] = sourceID;
    map['SubmitType'] = submitType;
    if (visitPics != null) {
      map['VisitPics'] = visitPics?.map((v) => v.toJson()).toList();
    }
    if (leavePics != null) {
      map['LeavePics'] = leavePics?.map((v) => v.toJson()).toList();
    }
    map['PeoPic'] = peoPic;
    map['CardPic'] = cardPic;
    return map;
  }

}
