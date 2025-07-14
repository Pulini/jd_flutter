import 'package:get/get.dart';
import 'package:jd_flutter/utils/utils.dart';
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
class WorkshopPlanningWorkerInfo{
  RxDouble money=(0.0).obs;
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
  WorkshopPlanningWorkerInfo deepCopy()=>WorkshopPlanningWorkerInfo(
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
  double efficiency()=>base.mul(dayWorkTime??0);
}

class WorkshopPlanningWorkTypeInfo{
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
    return typeOfWork??'';
  }
}

