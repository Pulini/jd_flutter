import '../../production_dispatch.dart';
import '../response/production_dispatch_order_detail_info.dart';

class ProductionDispatch {
  int? userID;
  List<ProductionDispatchSub>? list;

  ProductionDispatch({
    required this.userID,
    required this.list,
  });

  ProductionDispatch.fromJson(dynamic json) {
    userID = json['UserID'];
    list = json['List'];
    if (json['List'] != null) {
      list = [];
      json['List'].forEach((v) {
        list?.add(ProductionDispatchSub.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['UserID'] = userID;
    map['List'] = list?.map((v) => v.toJson()).toList();
    return map;
  }
}

class ProductionDispatchSub {
  int? id; // 单据FID
  int? interID; // 单据FInterID
  int? entryID; // 单据分录ID
  int? operPlanningEntryFID; // 工序计划FID
  int? empID; // 员工ID
  String? workerCode; // 员工工号
  String? workerName; // 员工名字
  double? sourceQty; // 源单数量
  double? mustQty; // 计工的 直接设定应派工数未实派工数, 因为有可能一道工序多个人做
  double? preSchedulingQty; // 预排数量
  double? qty; // 派工数量
  double? finishQty; // 已技工数量
  int? sourceEntryID; // 源单分录ID
  int? sourceInterID; // 源单InterID
  int? sourceEntryFID; // 源单FID
  String? processNumber; // 工序编号
  String? processName; // 工序名称
  int? isOpen; // 1-开启，0-关闭
  int? routingID;

  ProductionDispatchSub({
    required this.id,
    required this.interID,
    required this.entryID,
    required this.operPlanningEntryFID,
    required this.empID,
    required this.workerCode,
    required this.workerName,
    required this.sourceQty,
    required this.mustQty,
    required this.preSchedulingQty,
    required this.qty,
    required this.finishQty,
    required this.sourceEntryID,
    required this.sourceInterID,
    required this.sourceEntryFID,
    required this.processNumber,
    required this.processName,
    required this.isOpen,
    required this.routingID,
  }); // 工艺指导书ID

  ProductionDispatchSub.of({
    required DispatchInfo di,
    required WorkCardList wc,
  }) {
    empID = di.empID ?? 0;
    workerCode = di.number ?? '';
    workerName = di.name ?? '';
    qty = di.qty ?? 0;
    id = wc.id ?? 0;
    interID = wc.interID ?? 0;
    entryID = wc.entryID ?? 0;
    operPlanningEntryFID = wc.operPlanningEntryFID ?? 0;
    sourceQty = wc.sourceQty ?? 0;
    mustQty = wc.mustQty ?? 0;
    preSchedulingQty = wc.preSchedulingQty ?? 0;
    finishQty = wc.finishQty ?? 0;
    sourceEntryID = wc.sourceEntryID ?? 0;
    sourceInterID = wc.sourceInterID ?? 0;
    sourceEntryFID = wc.sourceEntryFID ?? 0;
    processNumber = wc.processNumber ?? '';
    processName = wc.processName ?? '';
    isOpen = wc.isOpen ?? 0;
    routingID = wc.routingID ?? 0;
  }

  ProductionDispatchSub.fromJson(dynamic json) {
    id=json['Id'];
    interID=json['InterID'];
    entryID=json['EntryID'];
    operPlanningEntryFID=json['OperPlanningEntryFID'];
    empID=json['EmpID'];
    workerCode=json['WorkerCode'];
    workerName=json['WorkerName'];
    sourceQty=json['SourceQty'];
    mustQty=json['MustQty'];
    preSchedulingQty=json['PreSchedulingQty'];
    qty=json['Qty'];
    finishQty=json['FinishQty'];
    sourceEntryID=json['SourceEntryID'];
    sourceInterID=json['SourceInterID'];
    sourceEntryFID=json['SourceEntryFID'];
    processNumber=json['ProcessNumber'];
    processName=json['ProcessName'];
    isOpen=json['IsOpen'];
    routingID=json['RoutingID'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ID'] = id;
    map['InterID'] = interID;
    map['EntryID'] = entryID;
    map['OperPlanningEntryFID'] = operPlanningEntryFID;
    map['EmpID'] = empID;
    map['WorkerCode'] = workerCode;
    map['WorkerName'] = workerName;
    map['SourceQty'] = sourceQty;
    map['MustQty'] = mustQty;
    map['PreSchedulingQty'] = preSchedulingQty;
    map['Qty'] = qty;
    map['FinishQty'] = finishQty;
    map['SourceEntryID'] = sourceEntryID;
    map['SourceInterID'] = sourceInterID;
    map['SourceEntryFID'] = sourceEntryFID;
    map['ProcessNumber'] = processNumber;
    map['ProcessName'] = processName;
    map['IsOpen'] = isOpen;
    map['RoutingID'] = routingID;
    return map;
  }
}
