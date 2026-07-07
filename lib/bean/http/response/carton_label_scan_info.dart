// InterID : "257283"
// CustOrderNumber : "4602027696"
// OutBoxBarCode : "00340486681090872284"
// Mix : 1
// IsSoleBarCode : 1
// LinkDataSizeList : [{"PriceBarCode":"4099686238735","Size":"3","LabelCount":"1.00000000000000000000"},{"PriceBarCode":"4099686238742","Size":"3.5","LabelCount":"3.00000000000000000000"},{"PriceBarCode":"4099686238759","Size":"4","LabelCount":"2.00000000000000000000"}]

import 'package:get/get.dart';

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
    interID = json['InterID'];
    custOrderNumber = json['CustOrderNumber'];
    outBoxBarCode = json['OutBoxBarCode'];
    mix = json['Mix'];
    dispatchNumber = json['DispatchNumber'];
    isSoleBarCode = json['IsSoleBarCode'];
    if (json['LinkDataSizeList'] != null) {
      linkDataSizeList = [];
      json['LinkDataSizeList'].forEach((v) {
        linkDataSizeList?.add(LinkDataSizeList.fromJson(v));
      });
    }
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
    this.isUniqueBarCode,
    this.linkDataSizeList,
  });

  CartonLabelScanNewInfo.fromJson(dynamic json) {
    interID = json['InterID'];
    custOrderNumber = json['CustOrderNumber'];
    outBoxBarCode = json['OutBoxBarCode'];
    mix = json['Mix'];
    dispatchNumber = json['DispatchNumber'];
    isSoleBarCode = json['IsSoleBarCode'];
    piece = json['Piece'];
    scannedCount = json['ScannedCount'];
    isUniqueBarCode = json['IsUniqueBarCode'];
    if (json['LinkDataSizeList'] != null) {
      linkDataSizeList = [];
      json['LinkDataSizeList'].forEach((v) {
        linkDataSizeList?.add(LinkDataSizeNewList.fromJson(v));
      });
    }
  }

  String? interID;
  String? custOrderNumber;
  String? outBoxBarCode;
  int? mix;
  String? dispatchNumber;
  int? isSoleBarCode;
  int? piece;
  int? scannedCount;
  bool? isUniqueBarCode;
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
    map['IsUniqueBarCode'] = isUniqueBarCode;
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
    priceBarCode = json['PriceBarCode'];
    size = json['Size'];
    labelCount = json['LabelCount'];
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
    priceBarCode = json['PriceBarCode'];
    size = json['Size'];
    labelCount = json['LabelCount'];
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
