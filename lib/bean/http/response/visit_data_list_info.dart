import 'package:jd_flutter/utils/extension_util.dart';
// InterID : 2300
// Number : "LFRY2002300"
// Name : "11"
// IDCard : "330322199408121213"
// Unit : "11"
// Phone : "15267733584"
// VisitedFactory : "金帝集团股份有限公司"
// VisitedDept : "11"
// IntervieweeName : "11"
// VisitorNum : 11
// SecurityStaff : "叶明杰"
// DateTime : "2024-02-29 11:05"
// LeaveTime : null
// CarNo : ""
// CarType : ""
// DataSourceType : 0
// SourceID : "0"
// SubmitType : 0

class VisitDataListInfo {
  VisitDataListInfo({
      this.interID, 
      this.number, 
      this.name, 
      this.iDCard, 
      this.unit, 
      this.phone, 
      this.visitedFactory, 
      this.visitedDept, 
      this.intervieweeName, 
      this.visitorNum, 
      this.securityStaff, 
      this.dateTime, 
      this.leaveTime, 
      this.carNo, 
      this.carType, 
      this.dataSourceType, 
      this.sourceID, 
      this.submitType,});

  VisitDataListInfo.fromJson(dynamic json) {
    interID = JsonParse.str(json['InterID']);
    number = JsonParse.str(json['Number']);
    name = JsonParse.str(json['Name']);
    iDCard = JsonParse.str(json['IDCard']);
    unit = JsonParse.str(json['Unit']);
    phone = JsonParse.str(json['Phone']);
    visitedFactory = JsonParse.str(json['VisitedFactory']);
    visitedDept = JsonParse.str(json['VisitedDept']);
    intervieweeName = JsonParse.str(json['IntervieweeName']);
    visitorNum = json['VisitorNum'] is String
        ? int.tryParse(json['VisitorNum'])
        : json['VisitorNum'];
    securityStaff = JsonParse.str(json['SecurityStaff']);
    dateTime = JsonParse.str(json['DateTime']);
    leaveTime = JsonParse.str(json['LeaveTime']);
    carNo = JsonParse.str(json['CarNo']);
    carType = JsonParse.str(json['CarType']);
    dataSourceType = JsonParse.toInt(json['DataSourceType']);
    sourceID = JsonParse.str(json['SourceID']);
    submitType = JsonParse.toInt(json['SubmitType']);
  }
  String? interID;
  String? number;
  String? name;
  String? iDCard;
  String? unit;
  String? phone;
  String? visitedFactory;
  String? visitedDept;
  String? intervieweeName;
  dynamic visitorNum;
  String? securityStaff;
  String? dateTime;
  String? leaveTime;
  String? carNo;
  String? carType;
  int? dataSourceType;
  String? sourceID;
  int? submitType;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['InterID'] = interID;
    map['Number'] = number;
    map['Name'] = name;
    map['IDCard'] = iDCard;
    map['Unit'] = unit;
    map['Phone'] = phone;
    map['VisitedFactory'] = visitedFactory;
    map['VisitedDept'] = visitedDept;
    map['IntervieweeName'] = intervieweeName;
    map['VisitorNum'] = visitorNum;
    map['SecurityStaff'] = securityStaff;
    map['DateTime'] = dateTime;
    map['LeaveTime'] = leaveTime;
    map['CarNo'] = carNo;
    map['CarType'] = carType;
    map['DataSourceType'] = dataSourceType;
    map['SourceID'] = sourceID;
    map['SubmitType'] = submitType;
    return map;
  }

}