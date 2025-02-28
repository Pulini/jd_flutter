import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';


// WorkCardList : [{"ID":0,"InterID":0,"EntryID":1,"OperPlanningEntryFID":3714871,"EmpID":0,"WorkerCode":"0","WorkerName":"","SourceQty":1463,"MustQty":1463,"PreSchedulingQty":0,"Qty":1463,"FinishQty":0,"SourceEntryID":2,"SourceInterID":213014,"SourceEntryFID":555546,"ProcessNumber":"YT","ProcessName":"沿条","IsOpen":1,"RoutingID":162132}]
// WorkCardTitle : {"FQtyPass":1463,"FQtyProcessPass":0,"DayWorkCardPlanQty":0,"FCardNoReportStatus":0,"PlantBody":"","ProcessBillNumber":"P2048549","DispatchingNumber":1463}

class ProductionDispatchOrderDetailInfo {
  ProductionDispatchOrderDetailInfo({
    this.workCardList,
    this.workCardTitle,
  });

  ProductionDispatchOrderDetailInfo.fromJson(dynamic json) {
    if (json['WorkCardList'] != null) {
      workCardList = [];
      json['WorkCardList'].forEach((v) {
        workCardList?.add(WorkCardList.fromJson(v));
      });
    }
    workCardTitle = json['WorkCardTitle'] != null
        ? WorkCardTitle.fromJson(json['WorkCardTitle'])
        : null;
  }

  List<WorkCardList>? workCardList;
  WorkCardTitle? workCardTitle;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (workCardList != null) {
      map['WorkCardList'] = workCardList?.map((v) => v.toJson()).toList();
    }
    if (workCardTitle != null) {
      map['WorkCardTitle'] = workCardTitle?.toJson();
    }
    return map;
  }
}

// FQtyPass : 1463
// FQtyProcessPass : 0
// DayWorkCardPlanQty : 0
// FCardNoReportStatus : 0
// PlantBody : ""
// ProcessBillNumber : "P2048549"
// DispatchingNumber : 1463

class WorkCardTitle {
  WorkCardTitle({
    this.qtyPass,
    this.qtyProcessPass,
    this.dayWorkCardPlanQty,
    this.cardNoReportStatus,
    this.plantBody,
    this.processBillNumber,
    this.dispatchingNumber,
  });

  WorkCardTitle.fromJson(dynamic json) {
    qtyPass = json['FQtyPass'];
    qtyProcessPass = json['FQtyProcessPass'];
    dayWorkCardPlanQty = json['DayWorkCardPlanQty'];
    cardNoReportStatus = json['FCardNoReportStatus'];
    plantBody = json['PlantBody'];
    processBillNumber = json['ProcessBillNumber'];
    dispatchingNumber = json['DispatchingNumber'];
  }

  double? qtyPass;//已汇报数
  double? qtyProcessPass;//累计计工数
  double? dayWorkCardPlanQty;//今日目标数
  int? cardNoReportStatus;//Status=1委外
  String? plantBody;
  String? processBillNumber;
  double? dispatchingNumber;//派工总数

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['FQtyPass'] = qtyPass;
    map['FQtyProcessPass'] = qtyProcessPass;
    map['DayWorkCardPlanQty'] = dayWorkCardPlanQty;
    map['FCardNoReportStatus'] = cardNoReportStatus;
    map['PlantBody'] = plantBody;
    map['ProcessBillNumber'] = processBillNumber;
    map['DispatchingNumber'] = dispatchingNumber;
    return map;
  }

  getDispatchTotal() => '派工总数：${dispatchingNumber.toShowString()}';

  getTodayGoal() => '今日目标：${dayWorkCardPlanQty.toShowString()}';

  getReported() => '已汇报数：${qtyPass.toShowString()}';

  getUnderCount() => '汇报欠数：${dispatchingNumber.sub(qtyPass!).toShowString()}';

  getAccumulateReportCount() => '累计计工数：${qtyProcessPass.toShowString()}';

  getReportedCount() =>
      '已汇报未计工数：${qtyPass.sub(qtyProcessPass!).toShowString()}';
}

// ID : 0
// InterID : 0
// EntryID : 1
// OperPlanningEntryFID : 3714871
// EmpID : 0
// WorkerCode : "0"
// WorkerName : ""
// SourceQty : 1463
// MustQty : 1463
// PreSchedulingQty : 0
// Qty : 1463
// FinishQty : 0
// SourceEntryID : 2
// SourceInterID : 213014
// SourceEntryFID : 555546
// ProcessNumber : "YT"
// ProcessName : "沿条"
// IsOpen : 1
// RoutingID : 162132

class WorkCardList {
  WorkCardList({
    this.id,
    this.interID,
    this.entryID,
    this.operPlanningEntryFID,
    this.empID,
    this.workerCode,
    this.workerName,
    this.sourceQty,
    this.mustQty,
    this.preSchedulingQty,
    this.qty,
    this.finishQty,
    this.sourceEntryID,
    this.sourceInterID,
    this.sourceEntryFID,
    this.processNumber,
    this.processName,
    this.isOpen,
    this.routingID,
  });

  WorkCardList.fromJson(dynamic json) {
    id = json['ID'];
    interID = json['InterID'];
    entryID = json['EntryID'];
    operPlanningEntryFID = json['OperPlanningEntryFID'];
    empID = json['EmpID'];
    workerCode = json['WorkerCode'];
    workerName = json['WorkerName'];
    sourceQty = json['SourceQty'];
    mustQty = json['MustQty'];
    preSchedulingQty = json['PreSchedulingQty'];
    qty = json['Qty'];
    finishQty = json['FinishQty'];
    sourceEntryID = json['SourceEntryID'];
    sourceInterID = json['SourceInterID'];
    sourceEntryFID = json['SourceEntryFID'];
    processNumber = json['ProcessNumber'];
    processName = json['ProcessName'];
    isOpen = json['IsOpen'];
    routingID = json['RoutingID'];
  }

  int? id; //单据FID
  int? interID; //单据FInterID
  int? entryID; //单据分录ID
  int? operPlanningEntryFID; //工序计划FID
  int? empID; //员工ID
  String? workerCode; //员工工号
  String? workerName; //员工名字
  double? sourceQty; //源单数量
  double? mustQty; //计工的 直接设定应派工数未实派工数, 因为有可能一道工序多个人做
  double? preSchedulingQty; //预排数量
  double? qty; //派工数量
  double? finishQty; //已技工数量
  int? sourceEntryID; //源单分录ID
  int? sourceInterID; //源单InterID
  int? sourceEntryFID; //源单FID
  String? processNumber; //工序编号
  String? processName; //工序名称
  int? isOpen; //1-开启，0-关闭
  int? routingID; //工艺指导书ID

  List<DispatchInfo> dispatch = [];

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

  getProcess() => '< $processNumber > $processName';

  double getTotal() {
    var total = 0.0;
    for (var dis in dispatch) {
      total = total.add(dis.qty ?? 0.0);
    }
    return total;
  }

  getTotalString() => '计工：${getTotal().toShowString()}';

  getFinishQtyString() => '已计工：${finishQty.toShowString()}';

  getSurplusQtyString() => '剩余：${mustQty.toShowString()}';

  isShowWarning() => getTotal() > mustQty!;

  isShowFlag() => getTotal() == mustQty!;
}

class DispatchInfo {
  bool? select;
  bool? resigned;
  String? processName;
  String? processNumber;
  String? number;
  String? name;
  int? empID;
  double? qty;

  double dispatchQty = 0.0;

  DispatchInfo({
    this.select = false,
    this.resigned = false,
    this.processName = '',
    this.processNumber = '',
    this.number = '',
    this.name = '',
    this.empID = 0,
    this.qty = 0.0,
  });

  DispatchInfo.fromJson(dynamic json) {
    select = json['select'];
    resigned = json['resigned'];
    processName = json['processName'];
    processNumber = json['processNumber'];
    number = json['number'];
    name = json['name'];
    empID = json['empID'];
    qty = json['qty'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['select'] = select;
    map['resigned'] = resigned;
    map['processName'] = processName;
    map['processNumber'] = processNumber;
    map['number'] = number;
    map['name'] = name;
    map['empID'] = empID;
    map['qty'] = qty;
    return map;
  }

  String getName() => '<$number>$name';

  String getQty() => qty.toShowString();

  double remainder() => qty.sub(dispatchQty);
}

class ShowDispatch {
  int groupIndex;
  int subIndex;
  String processName;
  String processNumber;
  String name;
  double qty;

  ShowDispatch({
    required this.groupIndex,
    required this.subIndex,
    required this.processName,
    required this.processNumber,
    required this.name,
    required this.qty,
  });
}

class SaveWorkProcedure {
  int? id;
  String? plantBody;
  String? saveTime;
  String? dispatchJson;
  static const tableName = 'work_procedure';
  static const dbCreate = '''
      CREATE TABLE $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      plantBody TEXT NOT NULL,
      saveTime TEXT NOT NULL,
      dispatchJson TEXT NOT NULL
      )
      ''';

  SaveWorkProcedure({
    this.id,
    required this.plantBody,
    required this.saveTime,
    required this.dispatchJson,
  });

  SaveWorkProcedure.fromJson(dynamic json) {
    id = json['id'];
    plantBody = json['plantBody'];
    saveTime = json['saveTime'];
    dispatchJson = json['dispatchJson'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['plantBody'] = plantBody;
    map['saveTime'] = saveTime;
    map['dispatchJson'] = dispatchJson;
    return map;
  }

  save(Function(SaveWorkProcedure) callback) {
    openDb().then((db) {
      db.insert(tableName, toJson()).then((value) {
        db.close();
        callback.call(this);
      }, onError: (e) {
        logger.e('数据库操作异常：$e');
        db.close();
      });
    });
  }

  static getSave(String plantBody, Function(List<SaveWorkProcedure>) callback) {
    openDb().then((db) {
      db.query(
        tableName,
        where: 'plantBody = ?',
        whereArgs: [plantBody],
      ).then((value) {
        db.close();
        var list = <SaveWorkProcedure>[];
        for (var v in value) {
          list.add(SaveWorkProcedure.fromJson(v));
        }
        callback.call(list);
      }, onError: (e) {
        logger.e('数据库操作异常：$e');
        db.close();
        callback.call([]);
      });
    });
  }

  delete(Function() callback) {
    openDb().then((db) {
      db.delete(tableName, where: 'id = ?', whereArgs: [id]).then((value) {
        db.close();
        callback.call();
      }, onError: (e) {
        logger.e('数据库操作异常：$e');
        db.close();
      });
    });
  }
}

class SaveDispatch {
  int? id;
  String? processBillNumber;
  String? cacheJson;
  static const tableName = 'dispatch';
  static const dbCreate = '''
      CREATE TABLE $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      processBillNumber TEXT NOT NULL UNIQUE,
      cacheJson TEXT NOT NULL
      )
      ''';
  static const dbInsertOrReplace = '''
      INSERT OR REPLACE INTO dispatch (
      id, processBillNumber,
      cacheJson
      ) VALUES (?, ?, ?)
      ''';

  SaveDispatch({
    this.id,
    required this.processBillNumber,
    required this.cacheJson,
  });

  SaveDispatch.fromJson(dynamic json) {
    id = json['id'];
    processBillNumber = json['processBillNumber'];
    cacheJson = json['cacheJson'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['processBillNumber'] = processBillNumber;
    map['cacheJson'] = cacheJson;
    return map;
  }

  save(Function(SaveDispatch) callback) {
    openDb().then((db) {
      db.rawInsert(
        dbInsertOrReplace,
        [id, processBillNumber, cacheJson],
      ).then((value) {
        db.close();
        callback.call(this);
      }, onError: (e) {
        logger.e('数据库操作异常：$e');
        db.close();
      });
    });
  }

  static delete({
    required String processBillNumber,
    Function()? callback,
  }) {
    openDb().then((db) {
      db.delete(
        tableName,
        where: 'processBillNumber = ?',
        whereArgs: [processBillNumber],
      ).then((value) {
        db.close();
        callback?.call();
      }, onError: (e) {
        logger.e('数据库操作异常：$e');
        db.close();
      });
    });
  }

  static getSave(
    String processBillNumber,
    Function(SaveDispatch) callback,
  ) {
    openDb().then((db) {
      db.query(
        tableName,
        where: 'processBillNumber = ?',
        whereArgs: [processBillNumber],
      ).then((value) {
        db.close();
        if (value.isNotEmpty) {
          callback.call(SaveDispatch.fromJson(value[0]));
        }
      }, onError: (e) {
        logger.e('数据库操作异常：$e');
        db.close();
      });
    });
  }
}

class CacheJson {
  String? processName;
  String? processNumber;
  List<DispatchInfo>? dispatch;

  CacheJson({
    required this.processName,
    required this.processNumber,
    required this.dispatch,
  });

  CacheJson.fromJson(dynamic json) {
    processName = json['processName'];
    processNumber = json['processNumber'];
    if (json['dispatch'] != null) {
      dispatch = [];
      json['dispatch'].forEach((v) {
        dispatch?.add(DispatchInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['processName'] = processName;
    map['processNumber'] = processNumber;
    map['dispatch'] = dispatch?.map((v) => v.toJson()).toList();
    return map;
  }
}
