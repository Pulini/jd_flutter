import 'package:jd_flutter/utils/extension_util.dart';
// InterID : 44485
// DispatchNumber : "000000116158"
// Shift : "白班"
// Machine : "倒台机01"
// FactoryType : "MDW221609-3"
// EmpList : [{"ProcessName":"制底","EmpName":"张功庆","Qty":360.0,"Unit":"双"}]
// SizeList : [{"Size":"6","BoxesQty":1.000,"DispatchQty":24.000,"LastMantissa":0.0,"Mantissa":0.000,"Qty":24.0,"Capacity":24.00},{"Size":"6.5","BoxesQty":1.000,"DispatchQty":36.000,"LastMantissa":0.0,"Mantissa":0.000,"Qty":36.0,"Capacity":36.00},{"Size":"7","BoxesQty":1.000,"DispatchQty":48.000,"LastMantissa":0.0,"Mantissa":0.000,"Qty":48.0,"Capacity":48.00},{"Size":"7.5","BoxesQty":1.000,"DispatchQty":48.000,"LastMantissa":0.0,"Mantissa":0.000,"Qty":48.0,"Capacity":48.00},{"Size":"8","BoxesQty":1.000,"DispatchQty":48.000,"LastMantissa":0.0,"Mantissa":0.000,"Qty":48.0,"Capacity":48.00},{"Size":"8.5","BoxesQty":1.000,"DispatchQty":48.000,"LastMantissa":0.0,"Mantissa":0.000,"Qty":48.0,"Capacity":48.00},{"Size":"9","BoxesQty":1.000,"DispatchQty":48.000,"LastMantissa":0.0,"Mantissa":0.000,"Qty":48.0,"Capacity":48.00},{"Size":"9.5","BoxesQty":1.000,"DispatchQty":12.000,"LastMantissa":0.0,"Mantissa":0.000,"Qty":12.0,"Capacity":12.00},{"Size":"10","BoxesQty":1.000,"DispatchQty":24.000,"LastMantissa":0.0,"Mantissa":0.000,"Qty":24.0,"Capacity":24.00},{"Size":"11","BoxesQty":1.000,"DispatchQty":24.000,"LastMantissa":0.0,"Mantissa":0.000,"Qty":24.0,"Capacity":24.00}]
// Status : true

class HandoverReportListInfo {
  HandoverReportListInfo({
    this.interID,
    this.dispatchNumber,
    this.shift,
    this.machine,
    this.factoryType,
    this.empList,
    this.sizeList,
    this.status,
  });

  HandoverReportListInfo.fromJson(dynamic json) {
    interID = JsonParse.toInt(json['InterID']);
    dispatchNumber = JsonParse.str(json['DispatchNumber']);
    shift = JsonParse.str(json['Shift']);
    machine = JsonParse.str(json['Machine']);
    factoryType = JsonParse.str(json['FactoryType']);
    empList = JsonParse.list(json['EmpList'], EmpList.fromJson);
    sizeList = JsonParse.list(json['SizeList'], SizeList.fromJson);
    status = JsonParse.toBool(json['Status']);
  }

  int? interID;
  String? dispatchNumber;
  String? shift;
  String? machine;
  String? factoryType;
  List<EmpList>? empList;
  List<SizeList>? sizeList;
  bool? status;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['InterID'] = interID;
    map['DispatchNumber'] = dispatchNumber;
    map['Shift'] = shift;
    map['Machine'] = machine;
    map['FactoryType'] = factoryType;
    if (empList != null) {
      map['EmpList'] = empList?.map((v) => v.toJson()).toList();
    }
    if (sizeList != null) {
      map['SizeList'] = sizeList?.map((v) => v.toJson()).toList();
    }
    map['Status'] = status;
    return map;
  }
}

// Size : "6"
// BoxesQty : 1.000
// DispatchQty : 24.000
// LastMantissa : 0.0
// Mantissa : 0.000
// Qty : 24.0
// Capacity : 24.00

class SizeList {
  SizeList({
    this.size,
    this.boxesQty,
    this.dispatchQty,
    this.lastMantissa,
    this.mantissa,
    this.qty,
    this.capacity,
  });

  SizeList.fromJson(dynamic json) {
    size = JsonParse.str(json['Size']);
    boxesQty = JsonParse.toDouble(json['BoxesQty']);
    dispatchQty = JsonParse.toDouble(json['DispatchQty']);
    lastMantissa = JsonParse.toDouble(json['LastMantissa']);
    mantissa = JsonParse.toDouble(json['Mantissa']);
    qty = JsonParse.toDouble(json['Qty']);
    capacity = JsonParse.toDouble(json['Capacity']);
  }

  String? size;
  double? boxesQty;
  double? dispatchQty;
  double? lastMantissa;
  double? mantissa;
  double? qty;
  double? capacity;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Size'] = size;
    map['BoxesQty'] = boxesQty;
    map['DispatchQty'] = dispatchQty;
    map['LastMantissa'] = lastMantissa;
    map['Mantissa'] = mantissa;
    map['Qty'] = qty;
    map['Capacity'] = capacity;
    return map;
  }
}

// ProcessName : "制底"
// EmpName : "张功庆"
// Qty : 360.0
// Unit : "双"

class EmpList {
  EmpList({
    this.processName,
    this.empName,
    this.qty,
    this.unit,
  });

  EmpList.fromJson(dynamic json) {
    processName = JsonParse.str(json['ProcessName']);
    empName = JsonParse.str(json['EmpName']);
    qty = JsonParse.toDouble(json['Qty']);
    unit = JsonParse.str(json['Unit']);
  }

  String? processName;
  String? empName;
  double? qty;
  String? unit;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ProcessName'] = processName;
    map['EmpName'] = empName;
    map['Qty'] = qty;
    map['Unit'] = unit;
    return map;
  }
}
