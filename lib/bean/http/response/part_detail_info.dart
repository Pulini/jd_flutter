import 'package:jd_flutter/utils/utils.dart';

// DeptName : "金帝裁断2组"
// Unit : "双"
// FactoryType : "鞋面-D13677-22B M"
// PartName : "鞋面"
// FIDs : [3716273,3716274,3716275,3716276]
// ProcessName : "裁1,裁2,裁3,裁4"
// Qty : 160.0
// CreateQty : 0.0
// SizeList : [{"Size":"38","Qty":40.0,"CreateQty":0.0,"MtonoList":[{"Mtono":"JZ2400096","Qty":40.0,"CreateQty":0.0,"EmpID":0,"EmpNumber":"","EmpName":""}]},{"Size":"39","Qty":40.0,"CreateQty":0.0,"MtonoList":[{"Mtono":"JZ2400096","Qty":40.0,"CreateQty":0.0,"EmpID":0,"EmpNumber":"","EmpName":""}]},{"Size":"40","Qty":40.0,"CreateQty":0.0,"MtonoList":[{"Mtono":"JZ2400096","Qty":40.0,"CreateQty":0.0,"EmpID":0,"EmpNumber":"","EmpName":""}]},{"Size":"41","Qty":40.0,"CreateQty":0.0,"MtonoList":[{"Mtono":"JZ2400096","Qty":40.0,"CreateQty":0.0,"EmpID":0,"EmpNumber":"","EmpName":""}]}]
// BarCodeList : []

class PartDetailInfo {
  PartDetailInfo({
    this.deptName,
    this.unit,
    this.factoryType,
    this.partName,
    this.fIDs,
    this.processName,
    this.qty,
    this.createQty,
    this.sizeList,
    this.barCodeList,
  });

  PartDetailInfo.fromJson(dynamic json) {
    deptName = json['DeptName'];
    unit = json['Unit'];
    factoryType = json['FactoryType'];
    partName = json['PartName'];
    fIDs = json['FIDs'] != null ? json['FIDs'].cast<int>() : [];
    processName = json['ProcessName'];
    qty = json['Qty'];
    createQty = json['CreateQty'];
    if (json['SizeList'] != null) {
      sizeList = [];
      json['SizeList'].forEach((v) {
        sizeList?.add(SizeInfo.fromJson(v));
      });
    }
    if (json['BarCodeList'] != null) {
      barCodeList = [];
      json['BarCodeList'].forEach((v) {
        barCodeList?.add(BarCodeInfo.fromJson(v));
      });
    }
  }

  String? deptName;
  String? unit;
  String? factoryType;
  String? partName;
  List<int>? fIDs;
  String? processName;
  double? qty;
  double? createQty;
  List<SizeInfo>? sizeList;
  List<BarCodeInfo>? barCodeList;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['DeptName'] = deptName;
    map['Unit'] = unit;
    map['FactoryType'] = factoryType;
    map['PartName'] = partName;
    map['FIDs'] = fIDs;
    map['ProcessName'] = processName;
    map['Qty'] = qty;
    map['CreateQty'] = createQty;
    if (sizeList != null) {
      map['SizeList'] = sizeList?.map((v) => v.toJson()).toList();
    }
    if (barCodeList != null) {
      map['BarCodeList'] = barCodeList?.map((v) => v.toJson()).toList();
    }
    return map;
  }

  SizeInfo getSizeListTotal() {
    var qty = 0.0;
    var createQty = 0.0;
    sizeList?.forEach((data) {
      qty = qty.add(data.qty ?? 0);
      createQty = createQty.add(data.createQty ?? 0);
    });
    return SizeInfo(qty: qty, createQty: createQty);
  }
}

// Size : "38"
// Qty : 40.0
// CreateQty : 0.0
// MtonoList : [{"Mtono":"JZ2400096","Qty":40.0,"CreateQty":0.0,"EmpID":0,"EmpNumber":"","EmpName":""}]

class SizeInfo {
  SizeInfo({
    this.size,
    this.qty,
    this.createQty,
    this.mtonoList,
  });

  SizeInfo.fromJson(dynamic json) {
    size = json['Size'];
    qty = json['Qty'];
    createQty = json['CreateQty'];
    if (json['MtonoList'] != null) {
      mtonoList = [];
      json['MtonoList'].forEach((v) {
        mtonoList?.add(MtonoInfo.fromJson(v));
      });
    }
  }

  String? size;
  double? qty;
  double? createQty;
  List<MtonoInfo>? mtonoList;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Size'] = size;
    map['Qty'] = qty;
    map['CreateQty'] = createQty;
    if (mtonoList != null) {
      map['MtonoList'] = mtonoList?.map((v) => v.toJson()).toList();
    }
    return map;
  }

  String getSalesOrderNumber() {
    if (size?.isEmpty == true && mtonoList?.isEmpty == true) {
      return '合计';
    } else {
      var numbers = <String>[];
      mtonoList?.forEach((data) {
        numbers.add(data.mtono ?? '');
      });
      if (numbers.length > 1) {
        return numbers.join(',');
      } else {
        if (numbers.length == 1) {
          return numbers[0];
        } else {
          return '';
        }
      }
    }
  }
}

// Mtono : "JZ2400096"
// Qty : 40.0
// CreateQty : 0.0
// EmpID : 0
// EmpNumber : ""
// EmpName : ""

class MtonoInfo {
  MtonoInfo({
    this.mtono,
    this.qty,
    this.createQty,
    this.empID,
    this.empNumber,
    this.empName,
  });

  MtonoInfo.fromJson(dynamic json) {
    mtono = json['Mtono'];
    qty = json['Qty'];
    createQty = json['CreateQty'];
    empID = json['EmpID'];
    empNumber = json['EmpNumber'];
    empName = json['EmpName'];
  }

  String? mtono;
  double? qty;
  double? createQty;
  int? empID;
  String? empNumber;
  String? empName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Mtono'] = mtono;
    map['Qty'] = qty;
    map['CreateQty'] = createQty;
    map['EmpID'] = empID;
    map['EmpNumber'] = empNumber;
    map['EmpName'] = empName;
    return map;
  }
}

class BarCodeInfo {
  BarCodeInfo({
    this.barCode,
    this.printTimes,
    this.size,
    this.createQty,
    this.reported,
    this.mtonoList,
  });

  BarCodeInfo.fromJson(dynamic json) {
    barCode = json['BarCode'];
    printTimes = json['PrintTimes'];
    size = json['Size'];
    createQty = json['CreateQty'];
    reported = json['Reported'];
    if (json['MtonoList'] != null) {
      mtonoList = [];
      json['MtonoList'].forEach((v) {
        mtonoList?.add(MtonoInfo.fromJson(v));
      });
    }
  }

  String? barCode;
  int? printTimes;
  String? size;
  double? createQty;
  double? reportQty;
  bool? reported;
  List<MtonoInfo>? mtonoList;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['BarCode'] = barCode;
    map['PrintTimes'] = printTimes;
    map['Size'] = size;
    map['CreateQty'] = createQty;
    map['ReportQty'] = reportQty;
    map['Reported'] = reported;
    if (mtonoList != null) {
      map['MtonoList'] = mtonoList?.map((v) => v.toJson()).toList();
    }
    return map;
  }

  String getWorkerName() {
    var list = <String>[];
    mtonoList?.forEach((mono) {
      list.add(mono.empName ?? '');
    });
    return list.join(',');
  }
}

// {
// "PartName": "鞋面",
// "LinkPartName": []
// }
class PartInfo {
  PartInfo({
    this.partName,
    this.linkPartName,
  });

  PartInfo.fromJson(dynamic json) {
    partName = json['PartName'];
    if (json['LinkPartName'] != null) {
      linkPartName = [];
      json['LinkPartName'].forEach((v) {
        linkPartName?.add(v);
      });
    }
  }

  String? partName;
  List<String>? linkPartName;
  bool select = false;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['PartName'] = partName;
    map['LinkPartName'] = linkPartName;
    return map;
  }
}
