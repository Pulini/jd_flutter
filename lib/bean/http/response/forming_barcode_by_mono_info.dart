// BarCode : "80558621445"
// Size : "6"
// ColNo : 22
// InterID : 448920
// EntryID : 1
// EntryType : 1

import 'package:get/get.dart';

class FormingBarcodeByMonoInfo {
  FormingBarcodeByMonoInfo({
      this.barCode, 
      this.size, 
      this.colNo, 
      this.interID, 
      this.entryID, 
      this.entryType,});

  FormingBarcodeByMonoInfo.fromJson(dynamic json) {
    barCode = json['BarCode'];
    size = json['Size'];
    colNo = json['ColNo'];
    interID = json['InterID'];
    entryID = json['EntryID'];
    entryType = json['EntryType'];
  }
  String? barCode;
  String? size;
  int? colNo;
  int? interID;
  int? entryID;
  int? entryType;
  RxBool isSelect = false.obs;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['BarCode'] = barCode;
    map['Size'] = size;
    map['ColNo'] = colNo;
    map['InterID'] = interID;
    map['EntryID'] = entryID;
    map['EntryType'] = entryType;
    return map;
  }

}