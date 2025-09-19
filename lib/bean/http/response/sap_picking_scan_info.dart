//{
//   "ZZCQ": "2025-05-10",
//   "MATNR": "090200555",
//   "ZMAKTG": "PUMA外箱",
//   "ERFMG": 10.0,
//   "VRKME": "个",
//   "ZTRACKNO": "2025050002",
//   "DUTY_FREE": "",
//   "MATERIALLIST": [
//     {
//       "ZPIECE_NO": "20250516002",
//       "CLABS": 1.0,
//       "BQID": "20250516002",
//       "ERFMG": 10.0,
//       "ERFME": "个"
//     }
//   ]
// }
import 'package:get/get.dart';
import 'package:jd_flutter/utils/extension_util.dart';

class SapPackingScanMaterialInfo {
  String? isDutyFree; //是否免税 DUTY_FREE
  double? quality; //预排数量  ERFMG
  String? materialNumber; //物料编号 MATNR
  String? materialName; //物料名称 ZMAKTG
  String? unit; //单位 VRKME
  String? plannedShippingSchedule; //计划船期  ZZCQ
  String? trackNo; //跟踪号 ZTRACKNO
  List<SapPackingScanLabelInfo>? labelList; //标签列表  MATERIALLIST

  SapPackingScanMaterialInfo({
    this.isDutyFree,
    this.quality,
    this.materialNumber,
    this.materialName,
    this.unit,
    this.plannedShippingSchedule,
    this.trackNo,
    this.labelList,
  });

  SapPackingScanMaterialInfo.fromJson(dynamic json) {
    isDutyFree = json['DUTY_FREE'];
    quality = json['ERFMG'].toString().toDoubleTry();
    materialNumber = json['MATNR'];
    materialName = json['ZMAKTG'];
    unit = json['VRKME'];
    plannedShippingSchedule = json['ZZCQ'];
    trackNo = json['ZTRACKNO'];
    labelList = [
      if (json['MATERIALLIST'] != null)
        for (var item in json['MATERIALLIST'])
          SapPackingScanLabelInfo.fromJson(item)
    ];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['DUTY_FREE'] = isDutyFree;
    map['ERFMG'] = quality;
    map['MATNR'] = materialNumber;
    map['ZMAKTG'] = materialName;
    map['VRKME'] = unit;
    map['ZZCQ'] = plannedShippingSchedule;
    map['ZTRACKNO'] = trackNo;
    map['MATERIALLIST'] = labelList?.map((v) => v.toJson()).toList();
    return map;
  }

  String materialID() => '$materialNumber$materialName$unit$trackNo';

  double scannedCount() => labelList?.where((v) => v.isScanned.value).map((v)=>v.quality??0).reduce((a,b)=>a.add(b))??0;

  bool search(String text) =>
      (materialNumber ?? '').contains(text) ||
      (materialName ?? '').contains(text) ||
      (trackNo ?? '').contains(text) ||
      labelList!.any((v3) => (v3.pieceNumber ?? '').contains(text));
}

class SapPackingScanLabelInfo {
  RxBool isScanned = false.obs;
  String? labelNumber; //标签号 BQID
  double? pieceQuality; //件数 CLABS
  String? unit; //单位 ERFME
  double? quality; //数量  ERFMG
  String? pieceNumber; //件号  ZPIECE_NO

  SapPackingScanLabelInfo({
    this.labelNumber,
    this.pieceQuality,
    this.unit,
    this.quality,
    this.pieceNumber,
  });

  SapPackingScanLabelInfo.fromJson(dynamic json) {
    labelNumber = json['BQID'];
    pieceQuality = json['CLABS'];
    unit = json['ERFME'];
    quality = json['ERFMG'].toString().toDoubleTry();
    pieceNumber = json['ZPIECE_NO'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['BQID'] = labelNumber;
    map['CLABS'] = pieceQuality;
    map['ERFME'] = unit;
    map['ERFMG'] = quality;
    map['ZPIECE_NO'] = pieceNumber;
    return map;
  }

  String labelID() => '$labelNumber$pieceNumber';
}

class PieceMaterialInfo {
  RxBool isSelected = false.obs;
  List<SapPackingScanMaterialInfo> materials = [];
  String pieceId;

  PieceMaterialInfo({required this.pieceId,required this.materials});
}

class SapPackingScanSubmitAbnormalInfo {
  String? factory; //工厂 WERKS
  String? plannedDate; //计划船期 ZZCQ
  String? destination; //目的地  ZADGE_RCVER
  String? cabinetNumber; //实际柜号 ZZKHXH1
  String? warehouse; //存储位置 LGORT
  String? labelNumber; //标签ID BQID
  String? postingDate; //过账日期 BUDAT_MKPF
  String? user; //用户名 USNAM
  String? userName; //用户中文名 ZNAME_CN
  String? date; //输入日期  CPUDT
  String? time; //输入时间  CPUTM
  String? message; //说明（200字符）  MESSAGE

  SapPackingScanSubmitAbnormalInfo({
    this.factory,
    this.plannedDate,
    this.destination,
    this.cabinetNumber,
    this.warehouse,
    this.labelNumber,
    this.postingDate,
    this.user,
    this.userName,
    this.date,
    this.time,
    this.message,
  });

  SapPackingScanSubmitAbnormalInfo.fromJson(dynamic json) {
    factory = json['WERKS'];
    plannedDate = json['ZZCQ'];
    destination = json['ZADGE_RCVER'];
    cabinetNumber = json['ZZKHXH1'];
    warehouse = json['LGORT'];
    labelNumber = json['BQID'];
    postingDate = json['BUDAT_MKPF'];
    user = json['USNAM'];
    userName = json['ZNAME_CN'];
    date = json['CPUDT'];
    time = json['CPUTM'];
    message = json['MESSAGE'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['WERKS'] = factory;
    map['ZZCQ'] = plannedDate;
    map['ZADGE_RCVER'] = destination;
    map['ZZKHXH1'] = cabinetNumber;
    map['LGORT'] = warehouse;
    map['BQID'] = labelNumber;
    map['BUDAT_MKPF'] = postingDate;
    map['USNAM'] = user;
    map['ZNAME_CN'] = userName;
    map['CPUDT'] = date;
    map['CPUTM'] = time;
    map['MESSAGE'] = message;
    return map;
  }
}

class SapPackingScanAbnormalInfo {
  RxBool isSelected = false.obs;
  String? labelNumber; //标签ID BQID
  String? date; //过账日期  BUDAT_MKPF"
  String? warehouse; //存储位置 LGORT
  String? factory; //工厂 WERKS
  String? destination; //目的地  ZADGE_RCVER
  String? plannedDate; //计划船期 ZZCQ
  String? containerNumber; //实际柜号 ZZKHXH1
  String? orderLine; //行项目  BQITEM
  String? unit; //单位  ERFME
  double? quality; //预排数量 ERFMG
  String? materialNumber; //物料编号  MATNR
  String? materialName; //物料名称  ZMAKTG
  String? pieceNumber; //件号 ZPIECE_NO
  String? trackNo; //跟踪号  ZTRACKNO

  SapPackingScanAbnormalInfo({
    this.labelNumber,
    this.date,
    this.warehouse,
    this.factory,
    this.destination,
    this.plannedDate,
    this.containerNumber,
    this.orderLine,
    this.unit,
    this.quality,
    this.materialNumber,
    this.materialName,
    this.pieceNumber,
    this.trackNo,
  });

  SapPackingScanAbnormalInfo.fromJson(dynamic json) {
    labelNumber = json['BQID'];
    date = json['BUDAT_MKPF'];
    warehouse = json['LGORT'];
    factory = json['WERKS'];
    destination = json['ZADGE_RCVER'];
    plannedDate = json['ZZCQ'];
    containerNumber = json['ZZKHXH1'];
    orderLine = json['BQITEM'];
    unit = json['ERFME'];
    quality = json['ERFMG'].toString().toDoubleTry();
    materialNumber = json['MATNR'];
    materialName = json['ZMAKTG'];
    pieceNumber = json['ZPIECE_NO'];
    trackNo = json['ZTRACKNO'];
  }

  bool search(String text) =>
      (materialNumber ?? '').contains(text) ||
      (materialName ?? '').contains(text) ||
      (pieceNumber ?? '').contains(text) ||
      (trackNo ?? '').contains(text);
  String materialId()=>'($materialNumber)$materialName';

}
class SapPackingScanReverseLabelInfo{
  String labelId='';//标签ID
  String? pieceId;//件ID  ZPIECE_NO
  double? pieceNo;//件数  CLABS
  String? deliveryOrderNo;//交货单号  VBELN_VL
  List<SapPackingScanReverseLabelMaterialInfo>? materialList;//物料列表 MATERIALLIST

  SapPackingScanReverseLabelInfo({
    this.pieceId,
    this.pieceNo,
    this.materialList,
  });
  SapPackingScanReverseLabelInfo.fromJson(dynamic json) {
    pieceId = json['ZPIECE_NO'];
    pieceNo = json['CLABS'].toString().toDoubleTry();
    deliveryOrderNo = json['VBELN_VL'];
    materialList = [
      if(json['MATERIALLIST'] != null)
      for (var item in json['MATERIALLIST'])
        SapPackingScanReverseLabelMaterialInfo.fromJson(item)
    ];
  }

}
class SapPackingScanReverseLabelMaterialInfo{
  String? materialNumber;//物料编码 MATNR
  String? materialName;//物料编码 ZMAKTG
  String? trackNo;//跟踪号  ZTRACKNO
  double? commonQty; //常用数量 ERFMG
  String? commonUnit; //常用单位  ERFME

  SapPackingScanReverseLabelMaterialInfo({
    this.materialNumber,
    this.materialName,
    this.trackNo,
    this.commonQty,
    this.commonUnit,
  });
  SapPackingScanReverseLabelMaterialInfo.fromJson(dynamic json) {
    materialNumber = json['MATNR'];
    materialName = json['ZMAKTG'];
    trackNo = json['ZTRACKNO'];
    commonQty = json['ERFMG'].toString().toDoubleTry();
    commonUnit = json['ERFME'];
  }
}
class PickingScanDeliveryOrderInfo{
  String? orderNo;//交货单号  VBELN_VL
  String? orderDate;//交货日期  WADAT_IST

  PickingScanDeliveryOrderInfo({
    this.orderNo,
    this.orderDate,
  });
  PickingScanDeliveryOrderInfo.fromJson(dynamic json) {
    orderNo = json['VBELN_VL'];
    orderDate = json['WADAT_IST'];
  }
}