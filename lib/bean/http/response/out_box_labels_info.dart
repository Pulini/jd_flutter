// InterID : "574066"
// CustOrderNumber : "4602886122"
// OutBoxBarCode : "00340486681721457255"
// TailCartonCode : "1"
// Mix : 1
// DispatchNumber : "P26116320"
// GUID : "E7C7D28D-1F52-4ECF-B409-00407651EB63"
// LinkDataSizeList : [{"PriceBarCode":"4070032733678","Size":"4.5","LabelCount":6,"ShotQty":2},{"PriceBarCode":"4070032733623","Size":"5","LabelCount":3,"ShotQty":2},{"PriceBarCode":"4070032733685","Size":"5.5","LabelCount":1,"ShotQty":1}]

class OutBoxLabelsInfo {
  OutBoxLabelsInfo({
      this.interID, 
      this.custOrderNumber, 
      this.outBoxBarCode, 
      this.tailCartonCode, 
      this.mix, 
      this.dispatchNumber, 
      this.guid, 
      this.linkDataSizeList,});

  OutBoxLabelsInfo.fromJson(dynamic json) {
    interID = json['InterID'];
    custOrderNumber = json['CustOrderNumber'];
    outBoxBarCode = json['OutBoxBarCode'];
    tailCartonCode = json['TailCartonCode'];
    mix = json['Mix'];
    dispatchNumber = json['DispatchNumber'];
    guid = json['GUID'];
    if (json['LinkDataSizeList'] != null) {
      linkDataSizeList = [];
      json['LinkDataSizeList'].forEach((v) {
        linkDataSizeList?.add(LinkDataSizeLists.fromJson(v));
      });
    }
  }
  String? interID;
  String? custOrderNumber;
  String? outBoxBarCode;
  String? tailCartonCode;
  int? mix;
  String? dispatchNumber;
  String? guid;
  List<LinkDataSizeLists>? linkDataSizeList;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['InterID'] = interID;
    map['CustOrderNumber'] = custOrderNumber;
    map['OutBoxBarCode'] = outBoxBarCode;
    map['TailCartonCode'] = tailCartonCode;
    map['Mix'] = mix;
    map['DispatchNumber'] = dispatchNumber;
    map['GUID'] = guid;
    if (linkDataSizeList != null) {
      map['LinkDataSizeLists'] = linkDataSizeList?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// PriceBarCode : "4070032733678"
/// Size : "4.5"
/// LabelCount : 6
/// ShotQty : 2

class LinkDataSizeLists {
  LinkDataSizeLists({
      this.priceBarCode, 
      this.size, 
      this.labelCount, 
      this.shotQty,});

  LinkDataSizeLists.fromJson(dynamic json) {
    priceBarCode = json['PriceBarCode'];
    size = json['Size'];
    labelCount = json['LabelCount'];
    shotQty = json['ShotQty'];
  }
  String? priceBarCode;
  String? size;
  int? labelCount;
  int? shotQty;   //已扫

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['PriceBarCode'] = priceBarCode;
    map['Size'] = size;
    map['LabelCount'] = labelCount;
    map['ShotQty'] = shotQty;
    return map;
  }

}