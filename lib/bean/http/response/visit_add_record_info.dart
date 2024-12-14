

import 'photoBean.dart';

/// ActionZone : "一楼会客厅"
/// ActionZoneID : "0"
/// CarBottom : ""
/// CarCab : ""
/// CarExterior : ""
/// CarNo : ""
/// CarRear : ""
/// CarType : ""
/// CardPic : ""
/// Credentials : "123"
/// DataSourceType : 0
/// DateTime : "2024-03-14 14:46:34"
/// ExamineID : "138236"
/// Gate : "1号门"
/// IDCard : "330322199408121212"
/// InterID : ""
/// Interviewee : "1446"
/// IntervieweeName : "叶炎堂"
/// LandingGear : ""
/// LeavePics : []
/// Name : "测试"
/// Note : ""
/// OwnGoods : ""
/// PeoPic : ""
/// Phone : "15267733701"
/// SecurityStaff : "138236"
/// SourceID : 0
/// SubjectMatter : "测试"
/// SubmitType : "0"
/// Unit : "测试"
/// VisitPics : []
/// VisitedDept : "DHM制作车间成型课"
/// VisitedFactory : "1"
/// VisitorNum : "2"

class VisitAddRecordInfo {
  VisitAddRecordInfo({
      this.actionZone='',
      this.actionZoneID='',
      this.carBottom='',
      this.carCab='',
      this.carExterior='',
      this.carNo='',
      this.carRear='',
      this.carType='',
      this.cardPic, 
      this.credentials='',
      this.dataSourceType,
      this.dateTime, 
      this.examineID, 
      this.gate='一号门',
      this.iDCard, 
      this.interID='',
      this.interviewee, 
      this.intervieweeName, 
      this.landingGear='',
      this.leavePics, 
      this.name, 
      this.note='',
      this.ownGoods='',
      this.peoPic, 
      this.phone, 
      this.securityStaff, 
      this.securityStaffName='',
      this.sourceID,
      this.subjectMatter, 
      this.submitType, 
      this.unit, 
      this.visitPics, 
      this.visitedDept, 
      this.visitedFactory, 
      this.visitorNum,});

  VisitAddRecordInfo.fromJson(dynamic json) {
    actionZone = json['ActionZone'];
    actionZoneID = json['ActionZoneID'];
    carBottom = json['CarBottom'];
    carCab = json['CarCab'];
    carExterior = json['CarExterior'];
    carNo = json['CarNo'];
    carRear = json['CarRear'];
    carType = json['CarType'];
    cardPic = json['CardPic'];
    credentials = json['Credentials'];
    dataSourceType = json['DataSourceType'];
    dateTime = json['DateTime'];
    examineID = json['ExamineID'];
    gate = json['Gate'];
    iDCard = json['IDCard'];
    interID = json['InterID'];
    interviewee = json['Interviewee'];
    intervieweeName = json['IntervieweeName'];
    landingGear = json['LandingGear'];
    name = json['Name'];
    note = json['Note'];
    ownGoods = json['OwnGoods'];
    peoPic = json['PeoPic'];
    phone = json['Phone'];
    securityStaff = json['SecurityStaff'];
    securityStaffName = json['SecurityStaffName'];
    sourceID = json['SourceID'];
    subjectMatter = json['SubjectMatter'];
    submitType = json['SubmitType'];
    unit = json['Unit'];
    visitedDept = json['VisitedDept'];
    visitedFactory = json['VisitedFactory'];
    visitorNum = json['VisitorNum'];
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
  }
  String? actionZone;
  String? actionZoneID;
  String? carBottom;
  String? carCab;
  String? carExterior;
  String? carNo;
  String? carRear;
  String? carType;
  String? cardPic;
  String? credentials;
  int? dataSourceType;
  String? dateTime;
  String? examineID;
  String? gate;
  String? iDCard;
  String? interID;
  String? interviewee;
  String? intervieweeName;
  String? landingGear;
  List<PhotoBean>? leavePics;
  String? name;
  String? note;
  String? ownGoods='';
  String? peoPic;
  String? phone;
  String? securityStaff;
  String? securityStaffName;
  int? sourceID;
  String? subjectMatter;
  String? submitType;
  String? unit;
  List<PhotoBean>? visitPics;
  String? visitedDept;
  String? visitedFactory;
  String? visitorNum;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ActionZone'] = actionZone;
    map['ActionZoneID'] = actionZoneID;
    map['CarBottom'] = carBottom;
    map['CarCab'] = carCab;
    map['CarExterior'] = carExterior;
    map['CarNo'] = carNo;
    map['CarRear'] = carRear;
    map['CarType'] = carType;
    map['CardPic'] = cardPic;
    map['Credentials'] = credentials;
    map['DataSourceType'] = dataSourceType;
    map['DateTime'] = dateTime;
    map['ExamineID'] = examineID;
    map['Gate'] = gate;
    map['IDCard'] = iDCard;
    map['InterID'] = interID;
    map['Interviewee'] = interviewee;
    map['IntervieweeName'] = intervieweeName;
    map['LandingGear'] = landingGear;
    if (leavePics != null) {
      map['LeavePics'] = leavePics?.map((v) => v.toJson()).toList();
    }
    map['Name'] = name;
    map['Note'] = note;
    map['OwnGoods'] = ownGoods;
    map['PeoPic'] = peoPic;
    map['Phone'] = phone;
    map['SecurityStaff'] = securityStaff;
    map['SecurityStaffName'] = securityStaffName;
    map['SourceID'] = sourceID;
    map['SubjectMatter'] = subjectMatter;
    map['SubmitType'] = submitType;
    map['Unit'] = unit;
    if (visitPics != null) {
      map['VisitPics'] = visitPics?.map((v) => v.toJson()).toList();
    }
    map['VisitedDept'] = visitedDept;
    map['VisitedFactory'] = visitedFactory;
    map['VisitorNum'] = visitorNum;
    return map;
  }

}