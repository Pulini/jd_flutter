/// FItemID : 11
/// FParentID : 3
/// FName : "材料不良"
/// FDetail : true
/// FExPercentage : 0

class ExceptionTypeInfo {
  ExceptionTypeInfo({
      this.fItemID, 
      this.fParentID, 
      this.fName, 
      this.fDetail, 
      this.fExPercentage,});

  ExceptionTypeInfo.fromJson(dynamic json) {
    fItemID = json['FItemID'];
    fParentID = json['FParentID'];
    fName = json['FName'];
    fDetail = json['FDetail'];
    fExPercentage = json['FExPercentage'];
  }
  int? fItemID;
  int? fParentID;
  String? fName;
  bool? fDetail;
  double? fExPercentage;
  bool select = false;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['FItemID'] = fItemID;
    map['FParentID'] = fParentID;
    map['FName'] = fName;
    map['FDetail'] = fDetail;
    map['FExPercentage'] = fExPercentage;
    return map;
  }

}