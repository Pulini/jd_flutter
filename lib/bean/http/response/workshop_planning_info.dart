import 'package:get/get.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/picker/picker_item.dart';
import 'package:jd_flutter/utils/web_api.dart';

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
     data['EmpID']=empID;
     data['Number']=number;
     data['Name']=name;
     data['TypeOfWork']=typeOfWork;
     data['BeginHireDate']=beginHireDate;
     data['DayWorkTime']=dayWorkTime;
     data['Base']=base;
     data['MinBase']=minBase;
     data['MaxBase']=maxBase;
     data['LeaveDate']=leaveDate;
     data['LeaveStatus']=leaveStatus;
     data['AttendanceStatus']=attendanceStatus;
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
  String? group;
  String? day;
  String? data;

  WorkshopPlanningWorkersCache({
    this.id,
    this.group,
    this.day,
    this.data,
  });

  WorkshopPlanningWorkersCache.fromJson(dynamic json) {
    id = json['ID'];
    group = json['Group'];
    day = json['Day'];
    data = json['Data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ID'] = id;
    data['Group'] = group;
    data['Day'] = day;
    data['Data'] = data;
    return data;
  }

  static const tableName = 'workshop_planning_workers_cache';
  static const dbCreate = '''
      CREATE TABLE $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      Group TEXT,
      Day TEXT,
      Data TEXT
      )
      ''';
  static const dbInsertOrReplace = '''
      INSERT OR REPLACE INTO $tableName (
      id, Group,
      Day,
      Data
      ) VALUES (?, ?, ?)
      ''';
  // save() {
  //   openDb().then((db) async {
  //     await db.insert(tableName, toJson());
  //     db.close();
  //   });
  // }
  save() {
    openDb().then((db) {
      db.rawInsert(
        dbInsertOrReplace,
        [id, group,day,data],
      ).then((value) {
        db.close();
        logger.e('数据保存成功：$value');
      }, onError: (e) {
        logger.e('数据库操作异常：$e');
        db.close();
      });
    });
  }

  static getSave({
    required String type,
    required Function(WorkshopPlanningWorkersCache) callback,
  }) {
    // openDb().then((db) {
    //   db.query(
    //     tableName,
    //     where: 'type = ?',
    //     whereArgs: [type],
    //   ).then((value) {
    //     db.close();
    //     callback.call([for (var v in value) BarCodeInfo.fromJson(v)]);
    //   }, onError: (e) {
    //     logger.e('数据库操作异常：$e');
    //     db.close();
    //     callback.call([]);
    //   });
    // });
  }
  delete({required Function() callback}) {
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

