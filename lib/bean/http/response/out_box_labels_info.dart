// {
// "InterID": "178329",
// "CustOrderNumber": "12345649",
// "OutBoxBarCode": "00340486681370041355",
// "Mix": 0,
// "DispatchNumber": "P2604612",
// "GUID": "",
// "TailCartonCode": "",
// "MantissaDataSizeList": [
// {
// "PriceBarCode": "4070034901921",
// "Size": "10",
// "LabelCount": 10,
// "ShortQty": 0
// }
// ]
// }
class OutBoxLabelsInfo {
  OutBoxLabelsInfo({
    this.interID,
    this.custOrderNumber,
    this.outBoxBarCode,
    this.tailCartonCode, //件号
    this.mix,
    this.dispatchNumber,
    this.guid,
    this.mantissaDataSizeList,
  });

  OutBoxLabelsInfo.fromJson(dynamic json) {
    interID = json['InterID'];
    custOrderNumber = json['CustOrderNumber'];
    outBoxBarCode = json['OutBoxBarCode'];
    tailCartonCode = json['TailCartonCode'];
    mix = json['Mix'];
    dispatchNumber = json['DispatchNumber'];
    guid = json['GUID'];
    if (json['MantissaDataSizeList'] != null) {
      mantissaDataSizeList = [];
      json['MantissaDataSizeList'].forEach((v) {
        mantissaDataSizeList?.add(MantissaDataSizeList.fromJson(v));
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
  List<MantissaDataSizeList>? mantissaDataSizeList;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['InterID'] = interID;
    map['CustOrderNumber'] = custOrderNumber;
    map['OutBoxBarCode'] = outBoxBarCode;
    map['TailCartonCode'] = tailCartonCode;
    map['Mix'] = mix;
    map['DispatchNumber'] = dispatchNumber;
    map['GUID'] = guid;
    map['TailCartonCode'] = tailCartonCode;
    if (mantissaDataSizeList != null) {
      map['MantissaDataSizeList'] =
          mantissaDataSizeList?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// PriceBarCode : "4070032733678"
/// Size : "4.5"
/// LabelCount : 6
/// ShotQty : 2

class MantissaDataSizeList {
  MantissaDataSizeList({
    this.priceBarCode,
    this.size,
    this.labelCount,
    this.shortQty,
    int? thisShortQty,
  }): thisShortQty = thisShortQty ?? shortQty;

  MantissaDataSizeList.fromJson(dynamic json) {
    priceBarCode = json['PriceBarCode'];
    size = json['Size'];
    labelCount = json['LabelCount'];
    shortQty = json['ShortQty'];
    thisShortQty = shortQty;
  }

  String? priceBarCode;
  String? size;
  int? labelCount;
  int? shortQty; //已扫
  int? thisShortQty; //本次已扫

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['PriceBarCode'] = priceBarCode;
    map['Size'] = size;
    map['LabelCount'] = labelCount;
    map['ShortQty'] = shortQty;
    return map;
  }
}
