import 'package:jd_flutter/utils/extension_util.dart';
class MaterialLabelScanInfo {
  MaterialLabelScanInfo({
    this.interID,
    this.workCardNo,
    this.materialID,
    this.proMaterialNumber,
    this.proMaterialName,
    this.productName,
    this.mtoNo,
    this.noticeDate,
    this.dispatchQty,
    this.matReqStatus,
    this.proMaterialID,

  });

  MaterialLabelScanInfo.fromJson(dynamic json) {
    interID = JsonParse.toInt(json['InterID']);
    workCardNo = JsonParse.str(json['WorkCardNo']);
    materialID = JsonParse.toInt(json['MaterialID']);
    proMaterialNumber = JsonParse.str(json['ProMaterialNumber']);
    proMaterialName = JsonParse.str(json['ProMaterialName']);
    productName = JsonParse.str(json['ProductName']);
    mtoNo = JsonParse.str(json['MtoNo']);
    noticeDate = JsonParse.str(json['NoticeDate']);
    dispatchQty = JsonParse.toDouble(json['DispatchQty']);
    matReqStatus = JsonParse.toInt(json['MatReqStatus']);
    proMaterialID = JsonParse.toInt(json['ProMaterialID']);

  }

  int? interID;
  String? workCardNo;
  int? materialID;
  String? proMaterialNumber;
  String? proMaterialName;
  String? productName;
  String? mtoNo;
  String? noticeDate;
  double? dispatchQty;
  int? matReqStatus;
  int? proMaterialID;


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['InterID'] = interID;
    map['WorkCardNo'] = workCardNo;
    map['MaterialID'] = materialID;
    map['ProMaterialNumber'] = proMaterialNumber;
    map['ProMaterialName'] = proMaterialName;
    map['ProductName'] = productName;
    map['MtoNo'] = mtoNo;
    map['NoticeDate'] = noticeDate;
    map['DispatchQty'] = dispatchQty;
    map['MatReqStatus'] = matReqStatus;
    map['ProMaterialID'] = proMaterialID;

    return map;
  }
}

/// Head : [{"InterID":213704,"WorkCardNo":"P2049423","ProductName":"PNS26312586-01","MaterialNumber":"58.00006","MaterialName":"火腿内外加大版","MtoNo":"JZ2500120, JZ2500119","UnitName":"双"}]
/// Items : [{"InterID":213704,"WorkCardNo":"P2049423","MaterialID":1060013,"ProductName":"PNS26312586-01","MaterialNumber":"013800874","MaterialName":"0.7mm*1.37m 黑色 P000FMG纹热熔膜热压（无缝切）","SrcICMOInterID":177956,"MtoNo":"JZ2500120","Size":"9","OrderQty":2.69994,"QtyReceived":0.0,"UnclaimedQty":2.69994,"UnitName":"米"}]

class MaterialLabelScanDetailInfo {
  MaterialLabelScanDetailInfo({
    this.head,
    this.items,
    this.picItems,
  });

  MaterialLabelScanDetailInfo.fromJson(dynamic json) {
    head = JsonParse.list(json['Head'], Head.fromJson);
    items = JsonParse.list(json['Items'], Items.fromJson);
    picItems = JsonParse.list(json['PicItems'], PicItems.fromJson);
  }
  List<Head>? head;
  List<Items>? items;
  List<PicItems>? picItems;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (head != null) {
      map['Head'] = head?.map((v) => v.toJson()).toList();
    }
    if (items != null) {
      map['Items'] = items?.map((v) => v.toJson()).toList();
    }
    if (picItems != null) {
      map['PicItems'] = picItems?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// InterID : 213704
/// WorkCardNo : "P2049423"
/// MaterialID : 1060013
/// ProductName : "PNS26312586-01"
/// MaterialNumber : "013800874"
/// MaterialName : "0.7mm*1.37m 黑色 P000FMG纹热熔膜热压（无缝切）"
/// SrcICMOInterID : 177956
/// MtoNo : "JZ2500120"
/// Size : "9"
/// OrderQty : 2.69994
/// QtyReceived : 0.0
/// UnclaimedQty : 2.69994
/// UnitName : "米"

class Items {
  Items({
    this.interID,
    this.workCardNo,
    this.materialID,
    this.productName,
    this.materialNumber,
    this.materialName,
    this.srcICMOInterID,
    this.mtoNo,
    this.size,
    this.orderQty,
    this.qtyReceived,
    this.unclaimedQty,
    this.unitName,
    this.productID,
  });

  Items.fromJson(dynamic json) {
    interID = JsonParse.toInt(json['InterID']);
    workCardNo = JsonParse.str(json['WorkCardNo']);
    materialID = JsonParse.toInt(json['MaterialID']);
    productName = JsonParse.str(json['ProductName']);
    materialNumber = JsonParse.str(json['MaterialNumber']);
    materialName = JsonParse.str(json['MaterialName']);
    srcICMOInterID = JsonParse.toInt(json['SrcICMOInterID']);
    mtoNo = JsonParse.str(json['MtoNo']);
    size = JsonParse.str(json['Size']);
    orderQty = JsonParse.toDouble(json['OrderQty']);
    qtyReceived = JsonParse.toDouble(json['QtyReceived']);
    unclaimedQty = JsonParse.toDouble(json['UnclaimedQty']);
    unitName = JsonParse.str(json['UnitName']);
    productID = JsonParse.toInt(json['ProductID']);
  }
  int? interID;
  String? workCardNo;
  int? materialID;
  String? productName;
  String? materialNumber;
  String? materialName;
  int? srcICMOInterID;
  int? productID;
  String? mtoNo;
  String? size;
  double? orderQty;
  double? qtyReceived;
  double? unclaimedQty;
  String? unitName;
  double? thisTime;
  bool? isScan = false;


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['InterID'] = interID;
    map['WorkCardNo'] = workCardNo;
    map['ProductID'] = productID;
    map['MaterialID'] = materialID;
    map['ProductName'] = productName;
    map['MaterialNumber'] = materialNumber;
    map['MaterialName'] = materialName;
    map['SrcICMOInterID'] = srcICMOInterID;
    map['MtoNo'] = mtoNo;
    map['Size'] = size;
    map['OrderQty'] = orderQty;
    map['QtyReceived'] = qtyReceived;
    map['UnclaimedQty'] = unclaimedQty;
    map['UnitName'] = unitName;
    return map;
  }

}

/// InterID : 213704
/// WorkCardNo : "P2049423"
/// ProductName : "PNS26312586-01"
/// MaterialNumber : "58.00006"
/// MaterialName : "火腿内外加大版"
/// MtoNo : "JZ2500120, JZ2500119"
/// UnitName : "双"

class Head {
  Head({
    this.interID,
    this.workCardNo,
    this.productName,
    this.proMaterialNumber,
    this.proMaterialName,
    this.proMaterialID,
    this.scWorkCardQty,
    this.mtoNo,
    this.unitName,});

  Head.fromJson(dynamic json) {
    interID = JsonParse.toInt(json['InterID']);
    workCardNo = JsonParse.str(json['WorkCardNo']);
    productName = JsonParse.str(json['ProductName']);
    proMaterialNumber = JsonParse.str(json['ProMaterialNumber']);
    proMaterialName = JsonParse.str(json['ProMaterialName']);
    proMaterialID = JsonParse.toInt(json['ProMaterialID']);
    mtoNo = JsonParse.str(json['MtoNo']);
    unitName = JsonParse.str(json['UnitName']);
    scWorkCardQty = JsonParse.toDouble(json['ScWorkCardQty']);
  }
  int? interID;
  String? workCardNo;
  String? productName;
  String? proMaterialNumber;
  int? proMaterialID;
  String? proMaterialName;
  String? mtoNo;
  String? unitName;
  double? scWorkCardQty;


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['InterID'] = interID;
    map['WorkCardNo'] = workCardNo;
    map['ProductName'] = productName;
    map['ProMaterialNumber'] = proMaterialNumber;
    map['ProMaterialName'] = proMaterialName;
    map['ProMaterialID'] = proMaterialID;
    map['MtoNo'] = mtoNo;
    map['UnitName'] = unitName;
    return map;
  }

}

class PicItems {
  PicItems({
    this.productID,
    this.materialID,
    this.pictureUrl,
    this.pictureThumbnailUrl,
});

  PicItems.fromJson(dynamic json) {
    productID = JsonParse.toInt(json['ProductID']);
    materialID = JsonParse.toInt(json['MaterialID']);
    pictureUrl = JsonParse.str(json['PictureUrl']);
    pictureThumbnailUrl = JsonParse.str(json['PictureThumbnailUrl']);

  }
  int? productID;
  int? materialID;
  String? pictureUrl;
  String? pictureThumbnailUrl;



  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ProductID'] = productID;
    map['MaterialID'] = materialID;
    map['PictureUrl'] = pictureUrl;
    map['PictureThumbnailUrl'] = pictureThumbnailUrl;

    return map;
  }

}

class MaterialLabelScanBarCodeInfo {
  MaterialLabelScanBarCodeInfo({
    this.materialID,
    this.materialNumber,
    this.materialName,
    this.srcICMOInterID,
    this.size,
    this.barCodeQty,

  });

  MaterialLabelScanBarCodeInfo.fromJson(dynamic json) {
    materialID = JsonParse.toInt(json['MaterialID']);
    materialNumber = JsonParse.str(json['MaterialNumber']);
    materialName = JsonParse.str(json['MaterialName']);
    srcICMOInterID = JsonParse.toInt(json['SrcICMOInterID']);
    size = JsonParse.str(json['Size']);
    barCodeQty = JsonParse.toDouble(json['BarCodeQty']);

  }

  int? srcICMOInterID;
  int? materialID;
  String? productName;
  String? materialNumber;
  String? materialName;
  String? size;
  double? barCodeQty;


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['SrcICMOInterID'] = srcICMOInterID;
    map['MaterialID'] = materialID;
    map['MaterialNumber'] = materialNumber;
    map['MaterialName'] = materialName;
    map['Size'] = size;
    map['BarCodeQty'] = barCodeQty;


    return map;
  }
}

