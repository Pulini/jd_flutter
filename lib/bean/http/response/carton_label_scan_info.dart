// InterID : "257283"
// CustOrderNumber : "4602027696"
// OutBoxBarCode : "00340486681090872284"
// Mix : 1
// IsSoleBarCode : 1
// LinkDataSizeList : [{"PriceBarCode":"4099686238735","Size":"3","LabelCount":"1.00000000000000000000"},{"PriceBarCode":"4099686238742","Size":"3.5","LabelCount":"3.00000000000000000000"},{"PriceBarCode":"4099686238759","Size":"4","LabelCount":"2.00000000000000000000"}]

import 'package:get/get.dart';
import 'package:jd_flutter/utils/extension_util.dart';

class CartonLabelScanInfo {
  CartonLabelScanInfo({
    this.interID,
    this.custOrderNumber,
    this.outBoxBarCode,
    this.mix,
    this.isSoleBarCode,
    this.linkDataSizeList,
  });

  CartonLabelScanInfo.fromJson(dynamic json) {
    interID = JsonParse.str(json['InterID']);
    custOrderNumber = JsonParse.str(json['CustOrderNumber']);
    outBoxBarCode = JsonParse.str(json['OutBoxBarCode']);
    mix = JsonParse.toInt(json['Mix']);
    dispatchNumber = JsonParse.str(json['DispatchNumber']);
    isSoleBarCode = JsonParse.toInt(json['IsSoleBarCode']);
    linkDataSizeList = JsonParse.list(json['LinkDataSizeList'], LinkDataSizeList.fromJson);
  }

  String? interID;
  String? custOrderNumber;
  String? outBoxBarCode;
  int? mix;
  String? dispatchNumber;
  int? isSoleBarCode;
  List<LinkDataSizeList>? linkDataSizeList;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['InterID'] = interID;
    map['CustOrderNumber'] = custOrderNumber;
    map['OutBoxBarCode'] = outBoxBarCode;
    map['Mix'] = mix;
    map['DispatchNumber'] = dispatchNumber;
    map['IsSoleBarCode'] = isSoleBarCode;
    if (linkDataSizeList != null) {
      map['LinkDataSizeList'] =
          linkDataSizeList?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
class CartonLabelScanNewInfo {
  CartonLabelScanNewInfo({
    this.interID,
    this.custOrderNumber,
    this.outBoxBarCode,
    this.mix,
    this.isSoleBarCode,
    this.piece,
    this.scannedCount,
    this.isNeedInnerBoxLabel,
    this.linkDataSizeList,
  });

  CartonLabelScanNewInfo.fromJson(dynamic json) {
    interID = JsonParse.str(json['InterID']);
    custOrderNumber = JsonParse.str(json['CustOrderNumber']);
    outBoxBarCode = JsonParse.str(json['OutBoxBarCode']);
    mix = JsonParse.toInt(json['Mix']);
    dispatchNumber = JsonParse.str(json['DispatchNumber']);
    isSoleBarCode = JsonParse.toInt(json['IsSoleBarCode']);
    piece = JsonParse.toInt(json['Piece']);
    scannedCount = JsonParse.toInt(json['ScannedCount']);
    isNeedInnerBoxLabel = JsonParse.toBool(json['IsNeedInnerBoxLabel']);
    linkDataSizeList = JsonParse.list(json['LinkDataSizeList'], LinkDataSizeNewList.fromJson);
  }

  String? interID;
  String? custOrderNumber;
  String? outBoxBarCode;
  int? mix;
  String? dispatchNumber;
  int? isSoleBarCode;
  int? piece;
  int? scannedCount;
  bool? isNeedInnerBoxLabel;   //是否需要扫内盒
  RxInt scanned=1.obs;

  List<LinkDataSizeNewList>? linkDataSizeList;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['InterID'] = interID;
    map['CustOrderNumber'] = custOrderNumber;
    map['OutBoxBarCode'] = outBoxBarCode;
    map['Mix'] = mix;
    map['DispatchNumber'] = dispatchNumber;
    map['IsSoleBarCode'] = isSoleBarCode;
    map['Piece'] = piece;
    map['ScannedCount'] = scannedCount;
    map['IsNeedInnerBoxLabel'] = isNeedInnerBoxLabel;
    if (linkDataSizeList != null) {
      map['LinkDataSizeList'] =
          linkDataSizeList?.map((v) => v.toJson()).toList();
    }

    return map;
  }

  int maxScanned()=>(piece??0)-(scannedCount??0);
}

// PriceBarCode : "4099686238735"
// Size : "3"
// LabelCount : "1.00000000000000000000"

class LinkDataSizeList {
  LinkDataSizeList({
    this.priceBarCode,
    this.size,
    this.labelCount,
  });

  LinkDataSizeList.fromJson(dynamic json) {
    priceBarCode = JsonParse.str(json['PriceBarCode']);
    size = JsonParse.str(json['Size']);
    labelCount = JsonParse.toInt(json['LabelCount']);
  }

  String? priceBarCode;
  String? size;
  int? labelCount;
  int scanned = 0;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['PriceBarCode'] = priceBarCode;
    map['Size'] = size;
    map['LabelCount'] = labelCount;
    return map;
  }

}
class LinkDataSizeNewList {
  LinkDataSizeNewList({
    this.priceBarCode,
    this.size,
    this.labelCount,
  });

  LinkDataSizeNewList.fromJson(dynamic json) {
    priceBarCode = JsonParse.str(json['PriceBarCode']);
    size = JsonParse.str(json['Size']);
    labelCount = JsonParse.toInt(json['LabelCount']);
  }

  String? priceBarCode;  //标签
  String? size;  //尺码
  int? labelCount;  //内盒数量
  int scanned = 0;  //已次扫码

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['PriceBarCode'] = priceBarCode;
    map['Size'] = size;
    map['LabelCount'] = labelCount;
    return map;
  }

}
