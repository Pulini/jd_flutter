

import 'photo_bean.dart';
import 'package:jd_flutter/utils/extension_util.dart';

class LeaveVisitRecord {
  LeaveVisitRecord({
    this.interID,
    this.leaveTime,
    this.leavePics,
  });

  LeaveVisitRecord.fromJson(dynamic json) {
    interID = JsonParse.str(json['InterID']);
    leavePics = json['LeaveTime'];
    leavePics = JsonParse.list(json['LeavePics'], PhotoBean.fromJson);
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

