import 'package:get/get.dart';
import 'package:jd_flutter/utils/socket_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

//{
//   "WOFNR": "3000000004",
//   "WERKS": "1000",
//   "WERKS_NAME": "GOLD EMPEROR GROUP CO., LTD",
//   "ZZXTNO": "PDW25308979-10",
//   "ZCOLORNAM": "杨选栋",
//   "ZCOLORDAT": "2025-01-07",
//   "ZMIXNTGEW": 5.9,
//   "ZMENG2": 0,
//   "MENGE": 0,
//   "ZMIXNTGEW_AFT": 0,
//   "AUSCH": 0,
//   "MATERIAL": [
//     {
//       "MATNR": "120900001",
//       "ZMAKTG": "丁酮165KG/桶",
//       "ZNTGEW_BEF": 5.0,
//       "ZNTGEW_AFT": 4.0,
//       "ZMENG3": 1.0,
//       "MEINS": "KG"
//     },
//   ]
// },
class SapInkColorMatchOrderInfo {
  String? orderNumber; //WOFNR  调色单号
  String? factoryNumber; //WERKS  工厂
  String? factoryName; //WERKS_NAME 工厂描述
  String? typeBody; //ZZXTNO 型体
  String? inkMaster; //ZCOLORNAM 油墨师
  String? mixDate; //ZCOLORDAT  调色日期
  double? mixtureWeight; //ZMIXNTGEW  混合物重量
  double? unitUsage; //ZMENG2  单位用量
  double? trialQty; //MENGE  试做数量
  double? mixtureTheoreticalWeight; //ZMIXNTGEW_AFT 混合物理论重量
  double? loss; //AUSCH  损耗
  List<SapInkColorMatchMaterialInfo>? materialList; //MATERIAL 物料列表

  SapInkColorMatchOrderInfo({
    this.orderNumber,
    this.factoryNumber,
    this.factoryName,
    this.typeBody,
    this.inkMaster,
    this.mixDate,
    this.mixtureWeight,
    this.unitUsage,
    this.trialQty,
    this.mixtureTheoreticalWeight,
    this.loss,
    this.materialList,
  });

  SapInkColorMatchOrderInfo.fromJson(dynamic json) {
    orderNumber = json['WOFNR'];
    factoryNumber = json['WERKS'];
    factoryName = json['WERKS_NAME'];
    typeBody = json['ZZXTNO'];
    inkMaster = json['ZCOLORNAM'];
    mixDate = json['ZCOLORDAT'];
    mixtureWeight = json['ZMIXNTGEW'];
    unitUsage = json['ZMENG2'].toString().toDoubleTry();
    trialQty = json['MENGE'].toString().toDoubleTry();
    mixtureTheoreticalWeight = json['ZMIXNTGEW_AFT'].toString().toDoubleTry();
    loss = json['AUSCH'].toString().toDoubleTry();
    if (json['MATERIAL'] != null) {
      materialList = [];
      json['MATERIAL'].forEach((v) {
        materialList?.add(SapInkColorMatchMaterialInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['WOFNR'] = orderNumber;
    map['WERKS'] = factoryNumber;
    map['WERKS_NAME'] = factoryName;
    map['ZZXTNO'] = typeBody;
    map['ZCOLORNAM'] = inkMaster;
    map['ZCOLORDAT'] = mixDate;
    map['ZMIXNTGEW'] = mixtureWeight;
    map['ZMENG2'] = unitUsage;
    map['MENGE'] = trialQty;
    map['ZMIXNTGEW_AFT'] = mixtureTheoreticalWeight;
    map['AUSCH'] = loss;
    if (materialList != null) {
      map['MATERIAL'] = materialList?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class SapInkColorMatchMaterialInfo {
  String? materialCode; //MATNR  物料编码
  String? materialName; //ZMAKTG 物料描述
  String? materialColor; //ZCOLOR 物料颜色
  double? weightBeforeColorMix; //ZNTGEW_BEF  调色前重量
  double? weightAfterColorMix; //ZNTGEW_AFT  调色后重量
  double? consumption; //ZMENG3  耗量
  String? unit; //MEINS 单位
  double? ratio; //ZPROPORTION  配比

  SapInkColorMatchMaterialInfo({
    this.materialCode,
    this.materialName,
    this.materialColor,
    this.weightBeforeColorMix,
    this.weightAfterColorMix,
    this.consumption,
    this.unit,
    this.ratio,
  });

  SapInkColorMatchMaterialInfo.fromJson(dynamic json) {
    materialCode = json['MATNR'];
    materialName = json['ZMAKTG'];
    materialColor = json['ZCOLOR'];
    weightBeforeColorMix = json['ZNTGEW_BEF'].toString().toDoubleTry();
    weightAfterColorMix = json['ZNTGEW_AFT'].toString().toDoubleTry();
    consumption = json['ZMENG3'].toString().toDoubleTry();
    unit = json['MEINS'];
    ratio = json['ZPROPORTION'].toString().toDoubleTry();
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['MATNR'] = materialCode;
    map['ZMAKTG'] = materialName;
    map['ZCOLOR'] = materialColor;
    map['ZNTGEW_BEF'] = weightBeforeColorMix;
    map['ZNTGEW_AFT'] = weightAfterColorMix;
    map['ZMENG3'] = consumption;
    map['MEINS'] = unit;
    map['ZPROPORTION'] = ratio;
    return map;
  }
}

class SapInkColorMatchTypeBodyInfo {
  String? serverIp; //SERVERIP
  List<SapInkColorMatchTypeBodyScalePortInfo>? scalePorts; //SCALEPORTS
  List<SapInkColorMatchTypeBodyMaterialInfo>? materials; //MATERIALS

  SapInkColorMatchTypeBodyInfo({
    this.serverIp,
    this.scalePorts,
    this.materials,
  });

  SapInkColorMatchTypeBodyInfo.fromJson(dynamic json) {
    serverIp = json['SERVERIP'];
    if (json['SCALEPORTS'] != null) {
      scalePorts = [];
      json['SCALEPORTS'].forEach((v) {
        scalePorts?.add(SapInkColorMatchTypeBodyScalePortInfo.fromJson(v));
      });
    }
    if (json['MATERIALS'] != null) {
      materials = [];
      json['MATERIALS'].forEach((v) {
        materials?.add(SapInkColorMatchTypeBodyMaterialInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['SERVERIP'] = serverIp;
    if (scalePorts != null) {
      map['SCALEPORTS'] = scalePorts?.map((v) => v.toJson()).toList();
    }
    if (materials != null) {
      map['MATERIALS'] = materials?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class SapInkColorMatchTypeBodyMaterialInfo {
  String? materialCode; //MATNR  物料编码
  String? materialName; //ZMAKTG 物料描述
  String? materialColor; //ZCOLOR 物料颜色

  SapInkColorMatchTypeBodyMaterialInfo({
    this.materialCode,
    this.materialName,
    this.materialColor,
  });

  SapInkColorMatchTypeBodyMaterialInfo.fromJson(dynamic json) {
    materialCode = json['MATNR'];
    materialName = json['ZMAKTG'];
    materialColor = json['ZCOLOR'];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['MATNR'] = materialCode;
    map['ZMAKTG'] = materialName;
    map['ZCOLOR'] = materialColor;
    return map;
  }
}

class SapInkColorMatchTypeBodyScalePortInfo {
  RxDouble weight = 0.0.obs; //重量

  int? scalePort; //ZPORT  串口号
  String? deviceName; //DEVICENAME  串口设备名称
  String? isMix; //zmix  是否混合物秤

  SapInkColorMatchTypeBodyScalePortInfo({
    this.scalePort,
    this.deviceName,
    this.isMix,
  });

  SapInkColorMatchTypeBodyScalePortInfo.fromJson(dynamic json) {
    scalePort = json['ZPORT'];
    deviceName = json['DEVICENAME'];
    isMix = json['ZMIX'];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['ZPORT'] = scalePort;
    map['DEVICENAME'] = deviceName;
    map['ZMIX'] = isMix;
    return map;
  }
}

class SapInkColorMatchItemInfo {
  String deviceName;
  String deviceIp;
  int scalePort;
  String materialCode;
  String materialName;
  String materialColor;


  bool isNewItem;

  RxBool weightBeforeLock = true.obs;
  RxDouble weightBeforeColorMix = 0.0.obs;

  RxBool weightAfterLock = true.obs;
  RxDouble weightAfterColorMix = 0.0.obs;

  SocketClientUtil? scu;
  RxBool errorUnit = false.obs;
  RxBool isConnect = false.obs;
  RxBool isConnecting = false.obs;
  RxDouble weight = 0.0.obs;
  RxString unit='kg'.obs;
  RxDouble mixWeight = 0.0.obs;

  SapInkColorMatchItemInfo({
    this.isNewItem = false,
    this.deviceName = '',
    this.deviceIp = '',
    this.scalePort = 0,
    weightBeforeColorMix = 0.0,
    weightAfterColorMix = 0.0,
    required this.materialCode,
    required this.materialName,
    required this.materialColor,
  }) {
    this.weightBeforeColorMix.value = weightBeforeColorMix;
    this.weightAfterColorMix.value = weightAfterColorMix;
    if(isNewItem){
      weightBeforeLock.value=false;
      scu = SocketClientUtil(
        ip: deviceIp,
        port: scalePort,
        weightListener: (weight, unit) {
          errorUnit.value = unit != 'kg';
          this.unit.value=unit;
          this.weight.value = weight;
        },
        connectListener: (c) {
          isConnecting.value = false;
          isConnect.value = c;
          logger.f('$deviceName ${c?'连接成功':'连接失败'}');
        },
      );
    }
  }
 double consumption()=>weightBeforeColorMix.value.sub(weightAfterColorMix.value);


  connect() {
    if (!isConnect.value && !isConnecting.value) {
      isConnecting.value = true;
      logger.f('连接设备---Name:$deviceName Ip:$deviceIp Port:$scalePort');
      scu?.connect();
    }
  }

  close() {
    scu?.close();
    isConnect.value = false;
  }
}
