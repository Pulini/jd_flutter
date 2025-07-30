// {"GuidList":["93080A91-D759-4FFA-89CA-A125F4A4AEF1"],"PickUpCodeList":["2903-20250721-0016"]}

class MaterialDispatchReportSuccessInfo {
  MaterialDispatchReportSuccessInfo({
    this.guidList,
    this.pickUpCodeList,
  });

  MaterialDispatchReportSuccessInfo.fromJson(dynamic json) {
    guidList = json['GuidList'] != null ? json['GuidList'].cast<String>() : [];
    pickUpCodeList = json['PickUpCodeList'] != null
        ? json['PickUpCodeList'].cast<String>()
        : [];
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
