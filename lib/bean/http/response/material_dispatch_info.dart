import 'package:jd_flutter/utils/extension_util.dart';

// SapDecideArea : "驻马店全套外发"
// ProductName : "DX242256-10"
// Date : "2024-07-11"
// PartName : "外筒排、内侧前后筒排"
// DepName : "贴合课"
// DrillingCrewName : "贴合课8号机台"
// MaterialID : "559962"
// MaterialNumber : "800618233"
// MaterialName : "0.9mm厚黑1色弹力压花PU复2×3黑色帆布上重胶+PE纸"
// ProcessNumber : "FH04"
// ProcessName : "加PE纸"
// Qty : "1375.719"
// CodeQty : "652.5"
// NoCodeQty : "723.219"
// FinishQty : "181"
// UnitName : "米"
// PrintLabel : "1"
// RouteEntryFIDs : "1744153"
// BillStyle : "0"
// StuffNumber : "0218733,013300530,04110218788,120126"
// Children : [{"BillNo":"J2403330,J2403976,J2403977,J2404036,J2404067,J2407528","GluingTimes":"2","Size":"","Qty":"194.833","CodeQty":"0","NoCodeQty":"194.833","FinishQty":"","SAPColorBatch":"240620C1","WorkProcessNumber":"GXPG24309936","InterID":"1666177","RouteEntryFID":"1744153","RouteEntryFIDs":"1744153","LastProcessNode":"1","ProcessFlowID":"25","PartialWarehousing":"0","BillStyle":"0"},{"BillNo":"J2403330,J2403359,J2403360,J2403976,J2403977,J2404036,J2404067,J2407528","GluingTimes":"2","Size":"","Qty":"1180.886","CodeQty":"652.5","NoCodeQty":"528.386","FinishQty":"181","SAPColorBatch":"240628C1","WorkProcessNumber":"GXPG24309936","InterID":"1666177","RouteEntryFID":"1744153","RouteEntryFIDs":"1744153","LastProcessNode":"1","ProcessFlowID":"25","PartialWarehousing":"1","BillStyle":"0"}]

class MaterialDispatchInfo {
  MaterialDispatchInfo({
    this.sapDecideArea,
    this.productName,
    this.date,
    this.partName,
    this.depName,
    this.drillingCrewName,
    this.drillingCrewID,
    this.materialID,
    this.materialNumber,
    this.materialName,
    this.processNumber,
    this.processName,
    this.qty,
    this.codeQty,
    this.noCodeQty,
    this.finishQty,
    this.unitName,
    this.printLabel,
    this.routeEntryFIDs,
    this.billStyle,
    this.stuffNumber,
    this.children,
    this.mustEnter,
    this.factoryID,
    this.cusdeclaraType,
    this.exitLabelType,
    this.sapSupplierNumber,
    this.description,
    this.sourceFactoryName,

  });

  MaterialDispatchInfo.fromJson(dynamic json) {
    sapDecideArea = json['SapDecideArea'];
    productName = json['ProductName'];
    date = json['Date'];
    partName = json['PartName'];
    depName = json['DepName'];
    drillingCrewName = json['DrillingCrewName'];
    drillingCrewID = json['DrillingCrewID'];
    materialID = json['MaterialID'];
    materialNumber = json['MaterialNumber'];
    materialName = json['MaterialName'];
    processNumber = json['ProcessNumber'];
    processName = json['ProcessName'];
    qty = (json['Qty'] as String).toDoubleTry().toShowString();
    codeQty = (json['CodeQty'] as String).toDoubleTry().toShowString();
    noCodeQty = (json['NoCodeQty'] as String).toDoubleTry().toShowString();
    finishQty = (json['FinishQty'] as String).toDoubleTry().toShowString();
    unitName = json['UnitName'];
    printLabel = json['PrintLabel'];
    routeEntryFIDs = json['RouteEntryFIDs'];
    billStyle = json['BillStyle'];
    stuffNumber = json['StuffNumber'];
    mustEnter = json['MustEnter'];
    factoryID = json['FactoryID'];
    cusdeclaraType = json['CusdeclaraType'];
    exitLabelType = json['ExitLabelType'];
    sapSupplierNumber = json['SAPSupplierNumber'];
    description = json['Description'];
    sourceFactoryName = json['SourceFactoryName'];
    if (json['Children'] != null) {
      children = [];
      json['Children'].forEach((v) {
        children?.add(Children.fromJson(v));
      });
    }
  }

  String? sapDecideArea; //厂区
  String? productName; //工厂型体
  String? date; //派工日期
  String? partName; //部位
  String? depName; //机台组别
  String? drillingCrewName; //机台名称
  String? drillingCrewID; //机台ID
  String? materialID; //物料ID
  String? materialNumber; //物料代码
  String? materialName; //物料名称
  String? processNumber; //工序编码
  String? processName; //工序名称
  String? qty; //生成贴标数量
  String? codeQty; //生成贴标数量
  String? noCodeQty; //未生成贴标数量
  String? finishQty; //完成数量
  String? unitName; //单位
  String? printLabel; //1.需要打印贴标 0.不用打印贴标
  String? routeEntryFIDs; //工艺路线分录IDs
  String? billStyle; //正单补单
  String? stuffNumber; //材料代码
  String? mustEnter; //是否需要必填
  String? factoryID; //工厂ID
  String? cusdeclaraType;
  String? exitLabelType; //打标类型
  String? sapSupplierNumber; //供应商
  String? description; //品名，批文
  String? sourceFactoryName; //工厂名字
  List<Children>? children;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['SapDecideArea'] = sapDecideArea;
    map['ProductName'] = productName;
    map['Date'] = date;
    map['PartName'] = partName;
    map['DepName'] = depName;
    map['DrillingCrewName'] = drillingCrewName;
    map['DrillingCrewID'] = drillingCrewID;
    map['MaterialID'] = materialID;
    map['MaterialNumber'] = materialNumber;
    map['MaterialName'] = materialName;
    map['ProcessNumber'] = processNumber;
    map['ProcessName'] = processName;
    map['Qty'] = qty;
    map['CodeQty'] = codeQty;
    map['NoCodeQty'] = noCodeQty;
    map['FinishQty'] = finishQty;
    map['UnitName'] = unitName;
    map['PrintLabel'] = printLabel;
    map['RouteEntryFIDs'] = routeEntryFIDs;
    map['BillStyle'] = billStyle;
    map['StuffNumber'] = stuffNumber;
    map['MustEnter'] = mustEnter;
    map['FactoryID'] = factoryID;
    map['CusdeclaraType'] = cusdeclaraType;
    map['ExitLabelType'] = exitLabelType;
    map['SAPSupplierNumber'] = sapSupplierNumber;
    map['Description'] = description;
    map['SourceFactoryName'] = sourceFactoryName;
    if (children != null) {
      map['Children'] = children?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

// BillNo : "J2403330,J2403976,J2403977,J2404036,J2404067,J2407528"
// GluingTimes : "2"
// Size : ""
// Qty : "194.833"
// CodeQty : "0"
// NoCodeQty : "194.833"
// FinishQty : ""
// SAPColorBatch : "240620C1"
// WorkProcessNumber : "GXPG24309936"
// InterID : "1666177"
// RouteEntryFID : "1744153"
// RouteEntryFIDs : "1744153"
// LastProcessNode : "1"
// ProcessFlowID : "25"
// PartialWarehousing : "0"
// BillStyle : "0"

class Children {
  Children({
    this.billNo,
    this.gluingTimes,
    this.size,
    this.qty,
    this.codeQty,
    this.noCodeQty,
    this.finishQty,
    this.sapColorBatch,
    this.workProcessNumber,
    this.interID,
    this.routeEntryFID,
    this.routeEntryFIDs,
    this.lastProcessNode,
    this.processFlowID,
    this.partialWarehousing,
    this.billStyle,
  });

  Children.fromJson(dynamic json) {
    billNo = json['BillNo'];
    gluingTimes = json['GluingTimes'];
    size = json['Size'];
    qty = (json['Qty'] as String).toDoubleTry().toShowString();
    codeQty = (json['CodeQty'] as String).toDoubleTry().toShowString();
    noCodeQty = (json['NoCodeQty'] as String).toDoubleTry().toShowString();
    finishQty = (json['FinishQty'] as String).toDoubleTry().toShowString();
    sapColorBatch = json['SAPColorBatch'];
    workProcessNumber = json['WorkProcessNumber'];
    interID = json['InterID'];
    routeEntryFID = json['RouteEntryFID'];
    routeEntryFIDs = json['RouteEntryFIDs'];
    lastProcessNode = json['LastProcessNode'];
    processFlowID = json['ProcessFlowID'];
    partialWarehousing = json['PartialWarehousing'];
    billStyle = json['BillStyle'];
  }

  String? billNo; //指令号
  String? gluingTimes; //次数
  String? size; //尺码
  String? qty; //数量
  String? codeQty; //生成贴标数量
  String? noCodeQty; //未生成贴标数量
  String? finishQty; //完成数量
  String? sapColorBatch; //配色批次
  String? workProcessNumber; //工序派工单号
  String? interID; //工序派工主键ID
  String? routeEntryFID; //工艺路线分录ID
  String? routeEntryFIDs; //工艺路线分录IDs
  String? lastProcessNode; //末道工序
  String? processFlowID; //
  String? partialWarehousing; //1.部分入库 0.不显示
  String? billStyle; //

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['BillNo'] = billNo;
    map['GluingTimes'] = gluingTimes;
    map['Size'] = size;
    map['Qty'] = qty;
    map['CodeQty'] = codeQty;
    map['NoCodeQty'] = noCodeQty;
    map['FinishQty'] = finishQty;
    map['SAPColorBatch'] = sapColorBatch;
    map['WorkProcessNumber'] = workProcessNumber;
    map['InterID'] = interID;
    map['RouteEntryFID'] = routeEntryFID;
    map['RouteEntryFIDs'] = routeEntryFIDs;
    map['LastProcessNode'] = lastProcessNode;
    map['ProcessFlowID'] = processFlowID;
    map['PartialWarehousing'] = partialWarehousing;
    map['BillStyle'] = billStyle;
    return map;
  }
}

// Number : "021800294"
// Name : "0.22mm*1.5m白色JY28可特（针织布/100%涤纶）"
// UnitName : "米"
// Batch : ""
// NeedQty : 27.41

class MaterialInfo {
  MaterialInfo({
    this.number,
    this.name,
    this.unitName,
    this.batch,
    this.needQty,
  });

  MaterialInfo.fromJson(dynamic json) {
    number = json['Number'];
    name = json['Name'];
    unitName = json['UnitName'];
    batch = json['Batch'];
    needQty = json['NeedQty'];
  }

  String? number;
  String? name;
  String? unitName;
  String? batch;
  double? needQty;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Number'] = number;
    map['Name'] = name;
    map['UnitName'] = unitName;
    map['Batch'] = batch;
    map['NeedQty'] = needQty;
    return map;
  }
}

// DrillingCrewName : "湖北贴合1号机台"
// GUID : "68983AA7-64EC-4B4F-8028-0FE4E17E4972"
// PickUpCode : "1104-20240722-0016"
// BillInterID : 3189111
// OutPutNumber : "GXHB24484990"
// InsertDateTime : "2024-07-22 14:45:52"
// SAPColorBatch : ""
// Qty : 30.0
// Status : "已报工"
// ReportStatus : "1"
// PalletNumber : ""
// Location : "A101"

class LabelInfo {
  LabelInfo({
    this.drillingCrewName,
    this.guid,
    this.pickUpCode,
    this.billInterID,
    this.outPutNumber,
    this.insertDateTime,
    this.sapColorBatch,
    this.qty,
    this.status,
    this.reportStatus,
    this.palletNumber,
    this.location,
    this.length,
    this.width,
    this.height,
    this.gw,
    this.nw,
  });

  LabelInfo.fromJson(dynamic json) {
    drillingCrewName = json['DrillingCrewName'];
    guid = json['GUID'];
    pickUpCode = json['PickUpCode'];
    billInterID = json['BillInterID'];
    outPutNumber = json['OutPutNumber'];
    insertDateTime = json['InsertDateTime'];
    sapColorBatch = json['SAPColorBatch'];
    qty = json['Qty'];
    status = json['Status'];
    reportStatus = json['ReportStatus'];
    palletNumber = json['PalletNumber'];
    location = json['Location'];
    length = json['Length'];
    width = json['Width'];
    height = json['Height'];
    gw = json['GW'];
    nw = json['NW'];
  }

  String? drillingCrewName;
  String? guid;
  String? pickUpCode;
  int? billInterID;
  String? outPutNumber;
  String? insertDateTime;
  String? sapColorBatch;
  double? qty;
  String? status;
  String? reportStatus;
  String? palletNumber;
  String? location;
  double? length;
  double? width;
  double? height;
  double? gw;
  double? nw;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['DrillingCrewName'] = drillingCrewName;
    map['GUID'] = guid;
    map['PickUpCode'] = pickUpCode;
    map['BillInterID'] = billInterID;
    map['OutPutNumber'] = outPutNumber;
    map['InsertDateTime'] = insertDateTime;
    map['SAPColorBatch'] = sapColorBatch;
    map['Qty'] = qty;
    map['Status'] = status;
    map['ReportStatus'] = reportStatus;
    map['PalletNumber'] = palletNumber;
    map['Location'] = location;
    map['Length'] = length;
    map['Width'] = width;
    map['Height'] = height;
    map['GW'] = gw;
    map['NW'] = nw;
    return map;
  }
}
