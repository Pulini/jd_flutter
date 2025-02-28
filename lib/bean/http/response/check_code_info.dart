// Items : [{"BarCode":"L24000000000004","NormalBarCodeList":["20488670007940/007","20488670007941/008"]}]

class CheckCodeInfo {
  CheckCodeInfo({
      this.items,});

  CheckCodeInfo.fromJson(dynamic json) {
    if (json['Items'] != null) {
      items = [];
      json['Items'].forEach((v) {
        items?.add(Items.fromJson(v));
      });
    }
  }
  List<Items>? items;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (items != null) {
      map['Items'] = items?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

// BarCode : "L24000000000004"
// NormalBarCodeList : ["20488670007940/007","20488670007941/008"]

class Items {
  Items({
      this.barCode, 
      this.normalBarCodeList,});

  Items.fromJson(dynamic json) {
    barCode = json['BarCode'];
    normalBarCodeList = json['NormalBarCodeList'] != null ? json['NormalBarCodeList'].cast<String>() : [];
  }
  String? barCode;
  List<String>? normalBarCodeList;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['BarCode'] = barCode;
    map['NormalBarCodeList'] = normalBarCodeList;
    return map;
  }

}