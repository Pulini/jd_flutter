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
    interID = json['InterID'];
    workCardNo = json['WorkCardNo'];
    materialID = json['MaterialID'];
    proMaterialNumber = json['ProMaterialNumber'];
    proMaterialName = json['ProMaterialName'];
    productName = json['ProductName'];
    mtoNo = json['MtoNo'];
    noticeDate = json['NoticeDate'];
    dispatchQty = json['DispatchQty'];
    matReqStatus = json['MatReqStatus'];
    proMaterialID = json['ProMaterialID'];

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
    if (json['Head'] != null) {
      head = [];
      json['Head'].forEach((v) {
        head?.add(Head.fromJson(v));
      });
    }
    if (json['Items'] != null) {
      items = [];
      json['Items'].forEach((v) {
        items?.add(Items.fromJson(v));
      });
    }
    if (json['PicItems'] != null) {
      picItems = [];
      json['PicItems'].forEach((v) {
        picItems?.add(PicItems.fromJson(v));
      });
    }
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
    interID = json['InterID'];
    workCardNo = json['WorkCardNo'];
    materialID = json['MaterialID'];
    productName = json['ProductName'];
    materialNumber = json['MaterialNumber'];
    materialName = json['MaterialName'];
    srcICMOInterID = json['SrcICMOInterID'];
    mtoNo = json['MtoNo'];
    size = json['Size'];
    orderQty = json['OrderQty'];
    qtyReceived = json['QtyReceived'];
    unclaimedQty = json['UnclaimedQty'];
    unitName = json['UnitName'];
    productID = json['ProductID'];
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
    interID = json['InterID'];
    workCardNo = json['WorkCardNo'];
    productName = json['ProductName'];
    proMaterialNumber = json['ProMaterialNumber'];
    proMaterialName = json['ProMaterialName'];
    proMaterialID = json['ProMaterialID'];
    mtoNo = json['MtoNo'];
    unitName = json['UnitName'];
    scWorkCardQty = json['ScWorkCardQty'];
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
    productID = json['ProductID'];
    materialID = json['MaterialID'];
    pictureUrl = json['PictureUrl'];
    pictureThumbnailUrl = json['PictureThumbnailUrl'];

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
    materialID = json['MaterialID'];
    materialNumber = json['MaterialNumber'];
    materialName = json['MaterialName'];
    srcICMOInterID = json['SrcICMOInterID'];
    size = json['Size'];
    barCodeQty = json['BarCodeQty'];

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

