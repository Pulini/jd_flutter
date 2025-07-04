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
  String toShow() =>name??'';
}
