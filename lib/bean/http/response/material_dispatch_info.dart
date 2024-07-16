import 'package:jd_flutter/utils.dart';

/// SapDecideArea : "驻马店全套外发"
/// ProductName : "DX242256-10"
/// Date : "2024-07-11"
/// PartName : "外筒排、内侧前后筒排"
/// DepName : "贴合课"
/// DrillingCrewName : "贴合课8号机台"
/// MaterialID : "559962"
/// MaterialNumber : "800618233"
/// MaterialName : "0.9mm厚黑1色弹力压花PU复2×3黑色帆布上重胶+PE纸"
/// ProcessNumber : "FH04"
/// ProcessName : "加PE纸"
/// Qty : "1375.719"
/// CodeQty : "652.5"
/// NoCodeQty : "723.219"
/// FinishQty : "181"
/// UnitName : "米"
/// PrintLabel : "1"
/// RouteEntryFIDs : "1744153"
/// BillStyle : "0"
/// StuffNumber : "0218733,013300530,04110218788,120126"
/// Children : [{"BillNo":"J2403330,J2403976,J2403977,J2404036,J2404067,J2407528","GluingTimes":"2","Size":"","Qty":"194.833","CodeQty":"0","NoCodeQty":"194.833","FinishQty":"","SAPColorBatch":"240620C1","WorkProcessNumber":"GXPG24309936","InterID":"1666177","RouteEntryFID":"1744153","RouteEntryFIDs":"1744153","LastProcessNode":"1","ProcessFlowID":"25","PartialWarehousing":"0","BillStyle":"0"},{"BillNo":"J2403330,J2403359,J2403360,J2403976,J2403977,J2404036,J2404067,J2407528","GluingTimes":"2","Size":"","Qty":"1180.886","CodeQty":"652.5","NoCodeQty":"528.386","FinishQty":"181","SAPColorBatch":"240628C1","WorkProcessNumber":"GXPG24309936","InterID":"1666177","RouteEntryFID":"1744153","RouteEntryFIDs":"1744153","LastProcessNode":"1","ProcessFlowID":"25","PartialWarehousing":"1","BillStyle":"0"}]

class MaterialDispatchInfo {
  MaterialDispatchInfo({
    this.sapDecideArea,
    this.productName,
    this.date,
    this.partName,
    this.depName,
    this.drillingCrewName,
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
  });

  MaterialDispatchInfo.fromJson(dynamic json) {
    sapDecideArea = json['SapDecideArea'];
    productName = json['ProductName'];
    date = json['Date'];
    partName = json['PartName'];
    depName = json['DepName'];
    drillingCrewName = json['DrillingCrewName'];
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
  List<Children>? children;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['SapDecideArea'] = sapDecideArea;
    map['ProductName'] = productName;
    map['Date'] = date;
    map['PartName'] = partName;
    map['DepName'] = depName;
    map['DrillingCrewName'] = drillingCrewName;
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
    if (children != null) {
      map['Children'] = children?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// BillNo : "J2403330,J2403976,J2403977,J2404036,J2404067,J2407528"
/// GluingTimes : "2"
/// Size : ""
/// Qty : "194.833"
/// CodeQty : "0"
/// NoCodeQty : "194.833"
/// FinishQty : ""
/// SAPColorBatch : "240620C1"
/// WorkProcessNumber : "GXPG24309936"
/// InterID : "1666177"
/// RouteEntryFID : "1744153"
/// RouteEntryFIDs : "1744153"
/// LastProcessNode : "1"
/// ProcessFlowID : "25"
/// PartialWarehousing : "0"
/// BillStyle : "0"

class Children {
  Children({
    this.billNo,
    this.gluingTimes,
    this.size,
    this.qty,
    this.codeQty,
    this.noCodeQty,
    this.finishQty,
    this.sAPColorBatch,
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
    sAPColorBatch = json['SAPColorBatch'];
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
  String? sAPColorBatch; //配色批次
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
    map['SAPColorBatch'] = sAPColorBatch;
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
