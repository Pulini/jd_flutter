/// InterID : 2300
/// Number : "LFRY2002300"
/// Name : "11"
/// IDCard : "330322199408121213"
/// Unit : "11"
/// Phone : "15267733584"
/// VisitedFactory : "金帝集团股份有限公司"
/// VisitedDept : "11"
/// IntervieweeName : "11"
/// VisitorNum : 11
/// SecurityStaff : "叶明杰"
/// DateTime : "2024-02-29 11:05"
/// LeaveTime : null
/// CarNo : ""
/// CarType : ""
/// DataSourceType : 0
/// SourceID : "0"
/// SubmitType : 0

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
    interID = json['InterID'];
    number = json['Number'];
    name = json['Name'];
    iDCard = json['IDCard'];
    unit = json['Unit'];
    phone = json['Phone'];
    visitedFactory = json['VisitedFactory'];
    visitedDept = json['VisitedDept'];
    intervieweeName = json['IntervieweeName'];
    visitorNum = json['VisitorNum'];
    securityStaff = json['SecurityStaff'];
    dateTime = json['DateTime'];
    leaveTime = json['LeaveTime'];
    carNo = json['CarNo'];
    carType = json['CarType'];
    dataSourceType = json['DataSourceType'];
    sourceID = json['SourceID'];
    submitType = json['SubmitType'];
  }
  int? interID;
  String? number;
  String? name;
  String? iDCard;
  String? unit;
  String? phone;
  String? visitedFactory;
  String? visitedDept;
  String? intervieweeName;
  int? visitorNum;
  String? securityStaff;
  String? dateTime;
  dynamic leaveTime;
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