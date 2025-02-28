

import 'photo_bean.dart';

class LeaveVisitRecord {
  LeaveVisitRecord({
    this.interID,
    this.leaveTime,
    this.leavePics,
  });

  LeaveVisitRecord.fromJson(dynamic json) {
    interID = json['InterID'];
    leavePics = json['LeaveTime'];
    if (json['LeavePics'] != null) {
      leavePics = [];
      json['LeavePics'].forEach((v) {
        leavePics?.add(PhotoBean.fromJson(v));
      });
    }
  }

  String? interID;
  String? leaveTime;
  List<PhotoBean>? leavePics;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['InterID'] = interID;
    map['LeaveTime'] = leaveTime;
    if (leavePics != null) {
      map['LeavePics'] = leavePics?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

