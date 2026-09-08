import 'package:jd_flutter/utils/extension_util.dart';
class PumaBoxCodeInfo {
  PumaBoxCodeInfo({
    this.fID,
    this.boxNumber,
    this.boxName,
    this.fCommandNumber,
    this.fPO,
    this.fBarCode,
    this.fCreatedBy,
    this.fCreatedOn,

  });

  PumaBoxCodeInfo.fromJson(dynamic json) {
    fID = JsonParse.str(json['FID']);
    boxNumber = JsonParse.str(json['BoxNumber']);
    boxName = JsonParse.str(json['BoxName']);
   fCommandNumber = JsonParse.str(json['FCommandNumber']);
    fPO = JsonParse.str(json['FPO']);
    fBarCode = JsonParse.str(json['FBarCode']);
    fCreatedBy = JsonParse.str(json['FCreatedBy']);
    fCreatedOn = JsonParse.str(json['FCreatedOn']);

  }
  String? fID;
  String? boxNumber;  //箱号
  String? boxName;  //箱子名称
  String? fCommandNumber;  //箱子名称
  String? fPO;  //客户订单
  String? fBarCode;  //条码
  String? fCreatedBy;  //创建人
  String? fCreatedOn;  //创建时间


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['FID'] = fID;
    map['BoxNumber'] = boxNumber;
    map['BoxName'] = boxName;
    map['FCommandNumber'] = fCommandNumber;
    map['FPO'] = fPO;
    map['FBarCode'] = fBarCode;
    map['FCreatedBy'] = fCreatedBy;
    map['FCreatedOn'] = fCreatedOn;

    return map;
  }

}