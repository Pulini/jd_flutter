import 'package:get/get.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/picker/picker_item.dart';

class ResponsibleDepartmentInfo extends PickerItem {
  int? departmentID;
  String? name;
  String? sapNumber;

  ResponsibleDepartmentInfo({this.departmentID, this.name, this.sapNumber});

  factory ResponsibleDepartmentInfo.fromJson(dynamic json) {
    return ResponsibleDepartmentInfo(
      departmentID: json['DepartmentID'].toString().toIntTry(),
      name: json['Name'],
      sapNumber: json['SAPNumber'],
    );
  }

  @override
  String pickerId() => departmentID.toString();

  @override
  String pickerName() => name ?? '';

  @override
  String toShow() => name ?? '';
}

//{
//   "ID": "14709043",
//   "FlowProcessID": "50",
//   "IsGroupWork": true,
//   "AllowEdit": true,
//   "PlanTrackingNumber": "JC2510014539",
//   "MaterialCode": "060401554",
//   "MaterialName": "PNW大底(HE1186模)深棕021-29-09 RB底(硬度57±2 耐磨80)",
//   "ProcessCode": "RB04",
//   "ProcessName": "RB打料",
//   "ProcessQty": 729.0,
//   "Price": 0.09767,
//   "SizeLists": [
//     {
//       "Size": "",
//       "ProcessQty": 729.0,
//       "FinishQty": 729.0,
//       "UnFinishQty": 0.0,
//       "Qty": 0.0
//     }
//   ]
// }
class WorkshopPlanningInfo {
  String? id;
  String? flowProcessID;
  bool? isGroupWork;
  bool? allowEdit;
  String? planTrackingNumber;
  String? materialCode;
  String? materialName;
  String? processCode;
  String? processName;
  double? processQty;
  double? price;
  List<WorkshopPlanningSizeInfo>? sizeLists;

  WorkshopPlanningInfo({
    this.id,
    this.flowProcessID,
    this.isGroupWork,
    this.allowEdit,
    this.planTrackingNumber,
    this.materialCode,
    this.materialName,
    this.processCode,
    this.processName,
    this.processQty,
    this.price,
    this.sizeLists,
  });

  factory WorkshopPlanningInfo.fromJson(dynamic json) {
    return WorkshopPlanningInfo(
      id: json['ID'],
      flowProcessID: json['FlowProcessID'],
      isGroupWork: json['IsGroupWork'],
      allowEdit: json['AllowEdit'],
      planTrackingNumber: json['PlanTrackingNumber'],
      materialCode: json['MaterialCode'],
      materialName: json['MaterialName'],
      processCode: json['ProcessCode'],
      processName: json['ProcessName'],
      processQty: json['ProcessQty'].toString().toDoubleTry(),
      price: json['Price'].toString().toDoubleTry(),
      sizeLists: [
        if (json['SizeLists'] != null)
          for (var item in json['SizeLists'])
            WorkshopPlanningSizeInfo.fromJson(item)
      ],
    );
  }

  WorkshopPlanningInfo deepCopy() => WorkshopPlanningInfo(
        id: id,
        flowProcessID: flowProcessID,
        isGroupWork: isGroupWork,
        allowEdit: allowEdit,
        planTrackingNumber: planTrackingNumber,
        materialCode: materialCode,
        materialName: materialName,
        processCode: processCode,
        processName: processName,
        processQty: processQty,
        price: price,
        sizeLists: [
          for (WorkshopPlanningSizeInfo item in (sizeLists ?? []))
            item.deepCopy()
        ],
      );
}

class WorkshopPlanningSizeInfo {
  String? size;
  double? processQty;
  double? finishQty;
  double? unFinishQty;
  double? qty;

  WorkshopPlanningSizeInfo({
    this.size,
    this.processQty,
    this.finishQty,
    this.unFinishQty,
    this.qty,
  });

  factory WorkshopPlanningSizeInfo.fromJson(dynamic json) {
    return WorkshopPlanningSizeInfo(
      size: json['Size'],
      processQty: json['ProcessQty'].toString().toDoubleTry(),
      finishQty: json['FinishQty'].toString().toDoubleTry(),
      unFinishQty: json['UnFinishQty'].toString().toDoubleTry(),
      qty: json['Qty'].toString().toDoubleTry(),
    );
  }

  WorkshopPlanningSizeInfo deepCopy() => WorkshopPlanningSizeInfo(
        size: size,
        processQty: processQty,
        finishQty: finishQty,
        unFinishQty: unFinishQty,
        qty: qty,
      );
}

//{
//   "EmpID": 246223,
//   "Number": "045683",
//   "Name": "刘富万",
//   "TypeOfWork": "组底普工",
//   "BeginHireDate": "2025-06-07",
//   "DayWorkTime": 11.0,
//   "Base": 13.5,
//   "MinBase": 13.5,
//   "MaxBase": 13.5,
//   "LeaveDate": "",
//   "LeaveStatus": false,
//   "AttendanceStatus": true
// },
class WorkshopPlanningWorkerInfo {
  RxDouble money = (0.0).obs;
  String? empID;
  String? number;
  String? name;
  String? typeOfWork;
  String? beginHireDate;
  double? dayWorkTime;
  double? base;
  double? minBase;
  double? maxBase;
  String? leaveDate;
  bool? leaveStatus;
  bool? attendanceStatus;

  WorkshopPlanningWorkerInfo({
    this.empID,
    this.number,
    this.name,
    this.typeOfWork,
    this.beginHireDate,
    this.dayWorkTime,
    this.base,
    this.minBase,
    this.maxBase,
    this.leaveDate,
    this.leaveStatus,
    this.attendanceStatus,
  });

  factory WorkshopPlanningWorkerInfo.fromJson(dynamic json) {
    return WorkshopPlanningWorkerInfo(
      empID: json['EmpID'].toString(),
      number: json['Number'],
      name: json['Name'],
      typeOfWork: json['TypeOfWork'],
      beginHireDate: json['BeginHireDate'],
      dayWorkTime: json['DayWorkTime'].toString().toDoubleTry(),
      base: json['Base'].toString().toDoubleTry(),
      minBase: json['MinBase'].toString().toDoubleTry(),
      maxBase: json['MaxBase'].toString().toDoubleTry(),
      leaveDate: json['LeaveDate'],
      leaveStatus: json['LeaveStatus'],
      attendanceStatus: json['AttendanceStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['EmpID'] = empID;
    data['Number'] = number;
    data['Name'] = name;
    data['TypeOfWork'] = typeOfWork;
    data['BeginHireDate'] = beginHireDate;
    data['DayWorkTime'] = dayWorkTime;
    data['Base'] = base;
    data['MinBase'] = minBase;
    data['MaxBase'] = maxBase;
    data['LeaveDate'] = leaveDate;
    data['LeaveStatus'] = leaveStatus;
    data['AttendanceStatus'] = attendanceStatus;
    return data;
  }

  WorkshopPlanningWorkerInfo deepCopy() => WorkshopPlanningWorkerInfo(
        empID: empID,
        number: number,
        name: name,
        typeOfWork: typeOfWork,
        beginHireDate: beginHireDate,
        dayWorkTime: dayWorkTime,
        base: base,
        minBase: minBase,
        maxBase: maxBase,
        leaveDate: leaveDate,
        leaveStatus: leaveStatus,
        attendanceStatus: attendanceStatus,
      );

  double efficiency() => base.mul(dayWorkTime ?? 0);
}

class WorkshopPlanningWorkTypeInfo {
  String? typeOfWork;
  double? base;
  double? minBase;
  double? maxBase;

  WorkshopPlanningWorkTypeInfo({
    this.typeOfWork,
    this.base,
    this.minBase,
    this.maxBase,
  });

  factory WorkshopPlanningWorkTypeInfo.fromJson(dynamic json) {
    return WorkshopPlanningWorkTypeInfo(
      typeOfWork: json['TypeOfWork'],
      base: json['Base'].toString().toDoubleTry(),
      minBase: json['MinBase'].toString().toDoubleTry(),
      maxBase: json['MaxBase'].toString().toDoubleTry(),
    );
  }

  @override
  toString() {
    return typeOfWork ?? '';
  }
}

//    val Date: String,
//     val FinishQty: Double,
//     val GroupPayInterID: Int,
//     val MaterialName: String,
//     val Number: String,
//     val OutputInterID: Int,
//     val PlanTrackingNumber: String,
//     val ProcessName: String
class WorkshopPlanningReportInfo {
  String? date;
  double? finishQty;
  int? groupPayInterID;
  String? materialName;
  String? number;
  int? outputInterID;
  String? planTrackingNumber;
  String? processName;

  WorkshopPlanningReportInfo({
    this.date,
    this.finishQty,
    this.groupPayInterID,
    this.materialName,
    this.number,
    this.outputInterID,
    this.planTrackingNumber,
    this.processName,
  });

  WorkshopPlanningReportInfo.fromJson(dynamic json) {
    date = json['Date'];
    finishQty = json['FinishQty'].toString().toDoubleTry();
    groupPayInterID = json['GroupPayInterID'];
    materialName = json['MaterialName'];
    number = json['Number'];
    outputInterID = json['OutputInterID'];
    planTrackingNumber = json['PlanTrackingNumber'];
    processName = json['ProcessName'];
  }
}
//    val CreatorID: Int,
//     val Date: String,
//     val DepartmentID: Int,
//     val EmpInfoReqList: MutableList<TeamSalaryReportDetailWorkerBean>,
//     val GroupPayInterID: Int,
//     val ID: Int,
//     val IsGroupWork: Boolean,
//     val SizeLists: MutableList<TeamSalaryReportDetailSizeBean>,
//     val WorkShift: Int

class WorkshopPlanningReportDetailInfo {
  int? creatorID;
  String? date;
  int? departmentID;
  List<WorkshopPlanningWorkerInfo>? empInfoReqList;
  int? groupPayInterID;
  int? id;
  bool? isGroupWork;
  List<WorkshopPlanningSizeInfo>? sizeLists;
  int? workShift;

  WorkshopPlanningReportDetailInfo({
    this.creatorID,
    this.date,
    this.departmentID,
    this.empInfoReqList,
    this.groupPayInterID,
    this.id,
    this.isGroupWork,
    this.sizeLists,
    this.workShift,
  });

  WorkshopPlanningReportDetailInfo.fromJson(dynamic json) {
    creatorID = json['CreatorID'];
    date = json['Date'];
    departmentID = json['DepartmentID'];
    empInfoReqList = [
      if (json['EmpInfoReqList'] != null)
        for (var item in json['EmpInfoReqList'])
          WorkshopPlanningWorkerInfo.fromJson(item)
    ];
    groupPayInterID = json['GroupPayInterID'];
    id = json['ID'];
    isGroupWork = json['IsGroupWork'];
    sizeLists = [
      if (json['SizeLists'] != null)
        for (var item in json['SizeLists'])
          WorkshopPlanningSizeInfo.fromJson(item)
    ];
    workShift = json['WorkShift'];
  }
}

class WorkshopPlanningWorkersCache {
  int? id;
  String? departmentID;
  String? day;
  String? data;

  WorkshopPlanningWorkersCache({
    this.id,
    this.departmentID,
    this.day,
    this.data,
  });

  WorkshopPlanningWorkersCache.fromJson(dynamic json) {
    id = json['id'];
    departmentID = json['departmentID'];
    day = json['day'];
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['departmentID'] = departmentID;
    data['day'] = day;
    data['data'] = data;
    return data;
  }

  static const tableName = 'workshop_planning_workers_cache';
  static const dbCreate = '''
      CREATE TABLE $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      departmentID TEXT NOT NULL UNIQUE,
      day TEXT,
      data TEXT
      )
      ''';
  static const dbInsertOrReplace = '''
      INSERT OR REPLACE INTO $tableName (
      id, 
      departmentID,
      day,
      data
      ) VALUES (?,?,?,?)
      ''';

  save(Function()callback) {
    openDb().then((db) {
      db.rawInsert(
        dbInsertOrReplace,
        [id, departmentID, day, data],
      ).then((value) {
        db.close();
        logger.e('数据保存成功：$value');
        callback.call();
      }, onError: (e) {
        logger.e('数据库操作异常：$e');
        db.close();
      });
    });
  }

  static getSave({
    required String departmentID,
    required Function(List<WorkshopPlanningWorkersCache>) callback,
  }) {
    openDb().then((db) {
      db.query(
        tableName,
        where: 'DepartmentID = ?',
        whereArgs: [departmentID],
      ).then((value) {
        db.close();
        callback.call([
          for (var v in value) WorkshopPlanningWorkersCache.fromJson(v),
        ]);
      }, onError: (e) {
        logger.e('数据库操作异常：$e');
        db.close();
        callback.call([]);
      });
    });
  }

  delete({required Function() callback}) {
    openDb().then((db) {
      db.delete(tableName, where: 'ID = ?', whereArgs: [id]).then((value) {
        db.close();
        callback.call();
      }, onError: (e) {
        logger.e('数据库操作异常：$e');
        db.close();
      });
    });
  }
}

//   "ItemID": 1028316,
//   "Number": "062200952",
//   "Name": "PDS大底(MO1217模)黑色 中底 IP:Grippy IMEVA(52±2C)+黑色 RB底片(57±2A耐磨100)"

class WorkshopPlanningMaterialInfo{
  int? itemID;
  String? number;
  String? name;
  WorkshopPlanningMaterialInfo({
    this.itemID,
    this.number,
    this.name,
  });
  WorkshopPlanningMaterialInfo.fromJson(dynamic json) {
    itemID = json['ItemID'];
    number = json['Number'];
    name = json['Name'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ItemID'] = itemID;
    data['Number'] = number;
    data['Name'] = name;
    return data;
  }
}
//  "PlanTrackingNumber": "J2504104",
//   "ID": "131334150",
//   "Size": "10",
//   "ProcessQty": 40.0,
//   "FinishQty": 0.0,
//   "UnFinishQty": 40.0,
//   "Qty": 40.0,
//   "Price": 2.195
class WorkshopPlanningLastProcessInfo{
  String? planTrackingNumber;
  String? id;
  String? size;
  double? processQty;
  double? finishQty;
  double? unFinishQty;
  double? qty;
  double? price;
  WorkshopPlanningLastProcessInfo({
    this.planTrackingNumber,
    this.id,
    this.size,
    this.processQty,
    this.finishQty,
    this.unFinishQty,
    this.qty,
    this.price,
  });
  WorkshopPlanningLastProcessInfo.fromJson(dynamic json) {
    planTrackingNumber = json['PlanTrackingNumber'];
    id = json['ID'];
    size = json['Size'];
    processQty = json['ProcessQty'].toString().toDoubleTry();
    finishQty = json['FinishQty'].toString().toDoubleTry();
    unFinishQty = json['UnFinishQty'].toString().toDoubleTry();
    qty = json['Qty'].toString().toDoubleTry();
    price = json['Price'].toString().toDoubleTry();
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['PlanTrackingNumber'] = planTrackingNumber;
    data['ID'] = id;
    data['Size'] = size;
    data['ProcessQty'] = processQty;
    data['FinishQty'] = finishQty;
    data['UnFinishQty'] = unFinishQty;
    data['Qty'] = qty;
    data['Price'] = price;
    return data;
  }
  double getMoney()=>qty.mul(price??0);
}
// "GroupPayInterID": 4156766,
//  "Number": "GXTJ2518760",
//  "Date": "2025-07-21",
//  "FinishQty": 1708.0
class LastProcessGroupPayInfo{
  int? groupPayInterID;
  String? number;
  String? date;
  double? finishQty;
  LastProcessGroupPayInfo({
    this.groupPayInterID,
    this.number,
    this.date,
    this.finishQty,
  });
  LastProcessGroupPayInfo.fromJson(dynamic json) {
    groupPayInterID = json['GroupPayInterID'];
    number = json['Number'];
    date = json['Date'];
    finishQty = json['FinishQty'].toString().toDoubleTry();
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['GroupPayInterID'] = groupPayInterID;
    data['Number'] = number;
    data['Date'] = date;
    data['FinishQty'] = finishQty;
    return data;
  }
}
//    val CreatorID: Int,
//     val Date: String,
//     val DepartmentID: Int,
//     val GroupPayInterID: Int,
//     val ID: Int,
//     val IsGroupWork: Boolean,
//     val AllowEdit: Boolean,
//     val WorkShift: Int,
//     val SizeList: MutableList<TeamSalaryBarCodeModel>,
//     val EmpInfoReqList: MutableList<TeamSalaryReportDetailWorkerBean>,
//     val MaterialInfoReqList: MutableList<TeamSalaryReportDetailMaterial>,
class LastProcessReportInfo{
  int? creatorID;
  String? date;
  int? departmentID;
  int? groupPayInterID;
  int? id;
  bool? isGroupWork;
  bool? allowEdit;
  int? workShift;
  List<WorkshopPlanningLastProcessInfo>? sizeList;
  List<WorkshopPlanningWorkerInfo>? empInfoReqList;
  List<LastProcessReportMaterialInfo>? materialInfoReqList;
  LastProcessReportInfo({
    this.creatorID,
    this.date,
    this.departmentID,
    this.groupPayInterID,
    this.id,
    this.isGroupWork,
    this.allowEdit,
    this.workShift,
    this.sizeList,
    this.empInfoReqList,
    this.materialInfoReqList,
  });
  LastProcessReportInfo.fromJson(dynamic json) {
    creatorID = json['CreatorID'];
    date = json['Date'];
    departmentID = json['DepartmentID'];
    groupPayInterID = json['GroupPayInterID'];
    id = json['ID'];
    isGroupWork = json['IsGroupWork'];
    allowEdit = json['AllowEdit'];
    workShift = json['WorkShift'];
    sizeList=[
      if(json['SizeList']!=null)
        for (var v in json['SizeList']) WorkshopPlanningLastProcessInfo.fromJson(v)
    ];
    empInfoReqList=[
      if(json['EmpInfoReqList']!=null)
        for (var v in json['EmpInfoReqList']) WorkshopPlanningWorkerInfo.fromJson(v)
    ];
    materialInfoReqList=[
      if(json['MaterialInfoReqList']!=null)
        for (var v in json['MaterialInfoReqList']) LastProcessReportMaterialInfo.fromJson(v)
    ];
  }
}

//   val MaterialID: Int,
//     val Number: String,
//     val Name: String,
//     val Used: Boolean
class LastProcessReportMaterialInfo{
  int? materialID;
  String? number;
  String? name;
  bool? used;
  LastProcessReportMaterialInfo({
    this.materialID,
    this.number,
    this.name,
    this.used,
  });
  LastProcessReportMaterialInfo.fromJson(dynamic json) {
    materialID = json['MaterialID'];
    number = json['Number'];
    name = json['Name'];
    used = json['Used'];
  }
}