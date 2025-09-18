import 'package:get/get.dart';
import 'package:jd_flutter/utils/extension_util.dart';

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
    this.instruction,
    this.instructionQty,
    this.qty,
  });

  int? type; //类型 0.工序 1.指令合计 2.部件合计
  String? name; //工序
  String? size; //尺码
  String? instruction; //指令
  double? instructionQty; //指令数
  double? qty; //贴标数

  ReportInfo.fromJson(dynamic json) {
    type = json['Type'];
    name = json['Name'];
    size = json['Size'];
    instruction = json['Mtono'];
    instructionQty = json['MtonoQty'];
    qty = json['Qty'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Type'] = type;
    map['Name'] = name;
    map['Size'] = size;
    map['Mtono'] = instruction;
    map['MtonoQty'] = instructionQty;
    map['Qty'] = qty;
    return map;
  }
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

  RxBool isSelect=false.obs;

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

class ReportItemData {
  var reportList = <ReportInfo>[].obs;
  var distribution = <Distribution>[].obs;
  var isSelect = false.obs;

  ReportItemData.fromData({
    required List<EmpInfo> empList,
    required List<ReportInfo> reportList,
  }) {
    this.reportList.addAll(reportList);
    for (var worker in empList) {
      distribution.add(Distribution(
        name: worker.empName ?? '',
        number: worker.empNumber ?? '',
        empId: worker.empID ?? 0,
        distributionQty: worker.qty ?? 0,
      ));
    }
  }

  sharingDistribution() {
    if (distribution.isNotEmpty) {
      var disTotal = getProcessMax();
      var integer = disTotal ~/ distribution.length;
      var decimal = (disTotal % distribution.length).toInt();
      for (var v in distribution) {
        v.distributionQty = integer.toDouble();
      }
      distribution.last.distributionQty =
          distribution.last.distributionQty.add(decimal.toDouble());
    }
  }

  double getProcessMax() {
    var total = 0.0;
    for (var v1 in reportList) {
      total = total.add(v1.qty??0);
    }
    return total;
  }

  double getDistributionMax() {
    var total = 0.0;
    for (var v1 in distribution) {
      total = total.add(v1.distributionQty);
    }
    return total;
  }

  double getProcessSurplus() => getProcessMax().sub(getDistributionMax());

  Distribution? getDistributionWorker(int empID) {
    return distribution.any((v) => v.empId == empID)
        ? distribution.firstWhere((v) => v.empId == empID)
        : null;
  }

  double getSurplusQty(int id) {
    var surplus = getProcessMax();
    for (var v in distribution.where((v) => v.empId != id)) {
      surplus = surplus.sub(v.distributionQty);
    }
    return surplus;
  }
}

class Distribution {
  late String name;
  late String number;
  late int empId;
  late double distributionQty;

  Distribution({
    required this.name,
    required this.number,
    required this.empId,
    required this.distributionQty,
  });

  Distribution.fromJson(dynamic json) {
    name = json['Name'];
    number = json['Number'];
    empId = json['EmpId'];
    distributionQty = json['DistributionQty'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Name'] = name;
    map['Number'] = number;
    map['EmpId'] = empId;
    map['DistributionQty'] = distributionQty;
    return map;
  }
}
