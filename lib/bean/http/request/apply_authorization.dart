import 'package:jd_flutter/utils.dart';

class ApplyAuthorization {
  ApplyAuthorization({
    this.reason,
  }){
    requestUser=userInfo?.userID;
    empNumber=userInfo?.number;
    empName=userInfo?.name;
    code=getDeviceID();
    requestMachineName=getDeviceName();
    requestNotes='';
  }

  ApplyAuthorization.fromJson(dynamic json) {
    reason = json['Reason'];
    requestUser = json['RequestUser'];
    empNumber = json['EmpNumber'];
    empName = json['EmpName'];
    code = json['Code'];
    requestMachineName = json['RequestMachineName'];
    requestNotes = json['RequestNotes'];
  }

  String? reason;
  int? requestUser;
  String? empNumber;
  String? empName;
  String? code;
  String? requestMachineName;
  String? requestNotes;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Reason'] = reason;
    map['RequestUser'] = requestUser;
    map['EmpNumber'] = empNumber;
    map['EmpName'] = empName;
    map['Code'] = code;
    map['RequestMachineName'] = requestMachineName;
    map['RequestNotes'] = requestNotes;
    return map;
  }

}
