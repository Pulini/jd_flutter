import 'package:jd_flutter/utils/extension_util.dart';
// {"GuidList":["93080A91-D759-4FFA-89CA-A125F4A4AEF1"],"PickUpCodeList":["2903-20250721-0016"]}

class MaterialDispatchReportSuccessInfo {
  MaterialDispatchReportSuccessInfo({
    this.guidList,
    this.pickUpCodeList,
  });

  MaterialDispatchReportSuccessInfo.fromJson(dynamic json) {
    guidList = JsonParse.strList(json['GuidList']);
    pickUpCodeList = JsonParse.strList(json['PickUpCodeList']);
  }

  List<String>? guidList;
  List<String>? pickUpCodeList;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    map['GuidList'] = guidList;
    map['PickUpCodeList'] = pickUpCodeList;
    return map;
  }
}
