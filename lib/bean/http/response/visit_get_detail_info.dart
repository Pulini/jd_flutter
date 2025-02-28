
import 'package:jd_flutter/bean/http/response/photo_bean.dart';

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
    interID = json['InterID'];
    number = json['Number'];
    name = json['Name'];
    iDCard = json['IDCard'];
    unit = json['Unit'];
    phone = json['Phone'];
    visitedFactory = json['VisitedFactory'];
    gate = json['Gate'];
    visitedDept = json['VisitedDept'];
    intervieweeID = json['IntervieweeID'];
    intervieweeName = json['IntervieweeName'];
    actionZone = json['ActionZone'];
    actionZoneID = json['ActionZoneID'];
    visitorNum = json['VisitorNum'];
    subjectMatter = json['SubjectMatter'];
    credentials = json['Credentials'];
    securityStaff = json['SecurityStaff'];
    dateTime = json['DateTime'];
    leaveTime = json['LeaveTime'];
    carNo = json['CarNo'];
    carType = json['CarType'];
    ownGoods = json['OwnGoods'];
    carBottom = json['CarBottom'];
    carExterior = json['CarExterior'];
    carRear = json['CarRear'];
    carCab = json['CarCab'];
    landingGear = json['LandingGear'];
    note = json['Note'];
    examineID = json['ExamineID'];
    dataSourceType = json['DataSourceType'];
    sourceID = json['SourceID'];
    submitType = json['SubmitType'];
    if (json['VisitPics'] != null) {
      visitPics = [];
      json['VisitPics'].forEach((v) {
        visitPics?.add(PhotoBean.fromJson(v));
      });
    }
    if (json['LeavePics'] != null) {
      leavePics = [];
      json['LeavePics'].forEach((v) {
        leavePics?.add(PhotoBean.fromJson(v));
      });
    }
    peoPic = json['PeoPic'];
    cardPic = json['CardPic'];
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
