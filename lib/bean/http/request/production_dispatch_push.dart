
class ProductionDispatchPush {
  int? organizeID;
  int? userID;
  int? departmentID;
  List<ProductionDispatchPushSub>? workCardItems;

  ProductionDispatchPush({
    required this.organizeID,
    required this.userID,
    required this.departmentID,
    required this.workCardItems,
  });

  ProductionDispatchPush.fromJson(dynamic json) {
    userID = json['OrganizeID'];
    userID = json['UserID'];
    userID = json['DepartmentID'];
    if (json['WorkCardItems'] != null) {
      workCardItems = [];
      json['WorkCardItems'].forEach((v) {
        workCardItems?.add(ProductionDispatchPushSub.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['OrganizeID'] = organizeID;
    map['UserID'] = userID;
    map['DepartmentID'] = departmentID;
    map['WorkCardItems'] = workCardItems?.map((v) => v.toJson()).toList();
    return map;
  }
}

class ProductionDispatchPushSub {
  int? interID; // 单据FInterID
  int? entryID; // 单据FID

  ProductionDispatchPushSub({
    required this.entryID,
    required this.interID,
  }); // 工艺指导书ID


  ProductionDispatchPushSub.fromJson(dynamic json) {
    entryID=json['EntryID'];
    interID=json['InterID'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['EntryID'] = entryID;
    map['InterID'] = interID;
    return map;
  }
}
