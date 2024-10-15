/// InterID : "257283"
/// CustOrderNumber : "4602027696"
/// OutBoxBarCode : "00340486681090872284"
/// Mix : 1
/// IsSoleBarCode : 1
/// LinkDataSizeList : [{"PriceBarCode":"4099686238735","Size":"3","LabelCount":"1.00000000000000000000"},{"PriceBarCode":"4099686238742","Size":"3.5","LabelCount":"3.00000000000000000000"},{"PriceBarCode":"4099686238759","Size":"4","LabelCount":"2.00000000000000000000"}]

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
  int? isSoleBarCode;
  List<LinkDataSizeList>? linkDataSizeList;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['InterID'] = interID;
    map['CustOrderNumber'] = custOrderNumber;
    map['OutBoxBarCode'] = outBoxBarCode;
    map['Mix'] = mix;
    map['IsSoleBarCode'] = isSoleBarCode;
    if (linkDataSizeList != null) {
      map['LinkDataSizeList'] =
          linkDataSizeList?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// PriceBarCode : "4099686238735"
/// Size : "3"
/// LabelCount : "1.00000000000000000000"

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
  int scanned= 0;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['PriceBarCode'] = priceBarCode;
    map['Size'] = size;
    map['LabelCount'] = labelCount;
    return map;
  }
}
