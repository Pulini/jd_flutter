class ScanBarcodeReportedReportInfo {
  ScanBarcodeReportedReportInfo({
    this.empList,
    this.reportList,
    this.barCodeList,
  });

  ScanBarcodeReportedReportInfo.fromJson(dynamic json) {
    if (json['EmpList'] != null) {
      empList = [];
      json['EmpList'].forEach((v) {
        empList?.add(EmpInfo.fromJson(v));
      });
    }
    if (json['ReportList'] != null) {
      reportList = [];
      json['ReportList'].forEach((v) {
        reportList?.add(ReportInfo.fromJson(v));
      });
    }
    if (json['BarCodeList'] != null) {
      barCodeList = [];
      json['BarCodeList'].forEach((v) {
        barCodeList?.add(BarCodeInfo.fromJson(v));
      });
    }
  }

  List<EmpInfo>? empList;
  List<ReportInfo>? reportList;
  List<BarCodeInfo>? barCodeList;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (empList != null) {
      map['SizeList'] = empList?.map((v) => v.toJson()).toList();
    }
    if (reportList != null) {
      map['SizeList'] = reportList?.map((v) => v.toJson()).toList();
    }
    if (barCodeList != null) {
      map['BarCodeList'] = barCodeList?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class EmpInfo {
  EmpInfo({
    this.processName,
    this.partName,
    this.empID,
    this.empNumber,
    this.empName,
    this.qty,
  });

  String? processName; //工序
  String? partName; //部件
  int? empID; //员工ID
  String? empNumber; //员工工号
  String? empName; //员工姓名
  double? qty; //报工数量

  EmpInfo.fromJson(dynamic json) {
    processName = json['ProcessName'];
    partName = json['PartName'];
    empID = json['EmpID'];
    empNumber = json['EmpNumber'];
    empName = json['EmpName'];
    qty = json['Qty'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ProcessName'] = processName;
    map['PartName'] = partName;
    map['EmpID'] = empID;
    map['EmpNumber'] = empNumber;
    map['EmpName'] = empName;
    map['Qty'] = qty;
    return map;
  }
}

class ReportInfo {
  ReportInfo({
    this.type,
    this.name,
    this.size,
    this.mtono,
    this.mtonoQty,
    this.qty,
  });

  String? type; //类型 0.工序 1.指令合计 2.部件合计
  String? name; //工序
  String? size; //尺码
  String? mtono; //指令
  String? mtonoQty; //指令数
  String? qty; //贴标数


  ReportInfo.fromJson(dynamic json) {
    type = json['Type'];
    name = json['Name'];
    size = json['Size'];
    mtono = json['Mtono'];
    mtonoQty = json['MtonoQty'];
    qty = json['Qty'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Type'] = type;
    map['Name'] = name;
    map['Size'] = size;
    map['Mtono'] = mtono;
    map['MtonoQty'] = mtonoQty;
    map['Qty'] = qty;
    return map;
  }
}

class Distribution {
  String? name;
  String? number;
  int? empId;
  double? distributionQty;
  double? percentage;

  Distribution({
    this.name,
    this.number,
    this.empId,
    this.distributionQty,
    this.percentage,
  });
}

class BarCodeInfo {
  BarCodeInfo({
    this.barCode,
    this.qty,
    this.processName,
  });

  String? barCode; //条码
  double? qty; //数量
  String? processName; //工序

  BarCodeInfo.fromJson(dynamic json) {
    barCode = json['BarCode'];
    qty = json['Qty'];
    processName = json['ProcessName'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['BarCode'] = barCode;
    map['Qty'] = qty;
    map['ProcessName'] = processName;
    return map;
  }
}
