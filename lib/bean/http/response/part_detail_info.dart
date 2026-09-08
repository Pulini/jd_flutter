import 'package:jd_flutter/utils/extension_util.dart';

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
    deptName = JsonParse.str(json['DeptName']);
    unit = JsonParse.str(json['Unit']);
    factoryType = JsonParse.str(json['FactoryType']);
    partName = JsonParse.str(json['PartName']);
    fIDs = JsonParse.intList(json['FIDs']);
    processName = JsonParse.str(json['ProcessName']);
    qty = JsonParse.toDouble(json['Qty']);
    createQty = JsonParse.toDouble(json['CreateQty']);
    sizeList = JsonParse.list(json['SizeList'], SizeInfo.fromJson);
    barCodeList = JsonParse.list(json['BarCodeList'], BarCodeInfo.fromJson);
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
    size = JsonParse.str(json['Size']);
    qty = JsonParse.toDouble(json['Qty']);
    createQty = JsonParse.toDouble(json['CreateQty']);
    mtonoList = JsonParse.list(json['MtonoList'], MtonoInfo.fromJson);
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
    mtono = JsonParse.str(json['Mtono']);
    qty = JsonParse.toDouble(json['Qty']);
    createQty = JsonParse.toDouble(json['CreateQty']);
    empID = JsonParse.toInt(json['EmpID']);
    empNumber = JsonParse.str(json['EmpNumber']);
    empName = JsonParse.str(json['EmpName']);
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
    this.partName,
    this.barCode,
    this.printTimes,
    this.size,
    this.createQty,
    this.reported,
    this.mtonoList,
  });

  BarCodeInfo.fromJson(dynamic json) {
    partName = JsonParse.str(json['PartName']);
    barCode = JsonParse.str(json['BarCode']);
    printTimes = JsonParse.toInt(json['PrintTimes']);
    size = JsonParse.str(json['Size']);
    createQty = JsonParse.toDouble(json['CreateQty']);
    reported = JsonParse.toBool(json['Reported']);
    mtonoList = JsonParse.list(json['MtonoList'], MtonoInfo.fromJson);
  }

  String? partName;
  String? barCode;
  int? printTimes;
  String? size;
  double? createQty;
  double? reportQty;
  bool? reported;
  List<MtonoInfo>? mtonoList;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['PartName'] = partName;
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
    partName = JsonParse.str(json['PartName']);
    linkPartName = [
      if (json['LinkPartName'] != null)
        for (var item in json['LinkPartName']) item
    ];
    partNameData=  linkPartName!.isEmpty?partName??'':linkPartName!.join(',');
  }
  String partNameData='';
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
