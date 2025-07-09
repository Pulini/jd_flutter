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
