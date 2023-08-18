import 'package:jd_flutter/http/response/picker_item.dart';

class PickerSupplier extends PickerItem {
  PickerSupplier({required this.name, required this.supplierNumber});

  PickerSupplier.fromJson(dynamic json) {
    name = json['Name'];
    supplierNumber = json['SAPSupplierNumber'];
  }

  String? name;
  String? supplierNumber;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Name'] = name;
    map['SAPSupplierNumber'] = supplierNumber;
    return map;
  }

  @override
  String pickerId() {
    return supplierNumber ?? "";
  }

  @override
  String pickerName() {
    return name ?? "";
  }
}
