/// InterID : 44485
/// DispatchNumber : "000000116158"
/// Shift : "白班"
/// Machine : "倒台机01"
/// FactoryType : "MDW221609-3"
/// EmpList : [{"ProcessName":"制底","EmpName":"张功庆","Qty":360.0,"Unit":"双"}]
/// SizeList : [{"Size":"6","BoxesQty":1.000,"DispatchQty":24.000,"LastMantissa":0.0,"Mantissa":0.000,"Qty":24.0,"Capacity":24.00},{"Size":"6.5","BoxesQty":1.000,"DispatchQty":36.000,"LastMantissa":0.0,"Mantissa":0.000,"Qty":36.0,"Capacity":36.00},{"Size":"7","BoxesQty":1.000,"DispatchQty":48.000,"LastMantissa":0.0,"Mantissa":0.000,"Qty":48.0,"Capacity":48.00},{"Size":"7.5","BoxesQty":1.000,"DispatchQty":48.000,"LastMantissa":0.0,"Mantissa":0.000,"Qty":48.0,"Capacity":48.00},{"Size":"8","BoxesQty":1.000,"DispatchQty":48.000,"LastMantissa":0.0,"Mantissa":0.000,"Qty":48.0,"Capacity":48.00},{"Size":"8.5","BoxesQty":1.000,"DispatchQty":48.000,"LastMantissa":0.0,"Mantissa":0.000,"Qty":48.0,"Capacity":48.00},{"Size":"9","BoxesQty":1.000,"DispatchQty":48.000,"LastMantissa":0.0,"Mantissa":0.000,"Qty":48.0,"Capacity":48.00},{"Size":"9.5","BoxesQty":1.000,"DispatchQty":12.000,"LastMantissa":0.0,"Mantissa":0.000,"Qty":12.0,"Capacity":12.00},{"Size":"10","BoxesQty":1.000,"DispatchQty":24.000,"LastMantissa":0.0,"Mantissa":0.000,"Qty":24.0,"Capacity":24.00},{"Size":"11","BoxesQty":1.000,"DispatchQty":24.000,"LastMantissa":0.0,"Mantissa":0.000,"Qty":24.0,"Capacity":24.00}]
/// Status : true

class HandoverReportListInfo {
  HandoverReportListInfo({
      this.interID, 
      this.dispatchNumber, 
      this.shift, 
      this.machine, 
      this.factoryType, 
      this.empList, 
      this.sizeList, 
      this.status,});

  HandoverReportListInfo.fromJson(dynamic json) {
    interID = json['InterID'];
    dispatchNumber = json['DispatchNumber'];
    shift = json['Shift'];
    machine = json['Machine'];
    factoryType = json['FactoryType'];
    if (json['EmpList'] != null) {
      empList = [];
      json['EmpList'].forEach((v) {
        empList?.add(EmpList.fromJson(v));
      });
    }
    if (json['SizeList'] != null) {
      sizeList = [];
      json['SizeList'].forEach((v) {
        sizeList?.add(SizeList.fromJson(v));
      });
    }
    status = json['Status'];
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

/// Size : "6"
/// BoxesQty : 1.000
/// DispatchQty : 24.000
/// LastMantissa : 0.0
/// Mantissa : 0.000
/// Qty : 24.0
/// Capacity : 24.00

class SizeList {
  SizeList({
      this.size, 
      this.boxesQty, 
      this.dispatchQty, 
      this.lastMantissa, 
      this.mantissa, 
      this.qty, 
      this.capacity,});

  SizeList.fromJson(dynamic json) {
    size = json['Size'];
    boxesQty = json['BoxesQty'];
    dispatchQty = json['DispatchQty'];
    lastMantissa = json['LastMantissa'];
    mantissa = json['Mantissa'];
    qty = json['Qty'];
    capacity = json['Capacity'];
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

/// ProcessName : "制底"
/// EmpName : "张功庆"
/// Qty : 360.0
/// Unit : "双"

class EmpList {
  EmpList({
      this.processName, 
      this.empName, 
      this.qty, 
      this.unit,});

  EmpList.fromJson(dynamic json) {
    processName = json['ProcessName'];
    empName = json['EmpName'];
    qty = json['Qty'];
    unit = json['Unit'];
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