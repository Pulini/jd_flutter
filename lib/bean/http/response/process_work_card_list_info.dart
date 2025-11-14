import 'package:jd_flutter/utils/extension_util.dart';

// InterID : 2243812
// EntryIDs : [2,3]
// FIDs : [21596298,21596297]
// Number : "GXPG25249521"
// ProductID : 976713
// ProductNumber : "MDHM201639-26"
// PartIDs : [19849]
// PartNames : ["①","②"]
// Mtonos : ["0010043440"]
// Emps : [{"EmpID":228392,"EmpNumber":"041102","EmpName":"黄斌"}]
// Processes : [{"ProcessName":"激光脚背饰带（2条）","Qty":903.000,"Unit":"双"},{"ProcessName":"激光第二条前带（2条）","Qty":903.000,"Unit":"双"}]
// HasBarcode : false
// CardNos : ["GXPG25249521/1"]

class ProcessWorkCardListInfo {
  ProcessWorkCardListInfo({
    this.interID,
    this.entryIDs,
    this.fIDs,
    this.number,
    this.productID,
    this.productNumber,
    this.partIDs,
    this.partNames,
    this.mtonos,
    this.emps,
    this.processes,
    this.hasBarcode,
    this.cardNos,
  });

  ProcessWorkCardListInfo.fromJson(dynamic json) {
    interID = json['InterID'];
    entryIDs = json['EntryIDs'] != null ? json['EntryIDs'].cast<int>() : [];
    fIDs = json['FIDs'] != null ? json['FIDs'].cast<int>() : [];
    number = json['Number'];
    productID = json['ProductID'];
    productNumber = json['ProductNumber'];
    partIDs = json['PartIDs'] != null ? json['PartIDs'].cast<int>() : [];
    partNames =
        json['PartNames'] != null ? json['PartNames'].cast<String>() : [];
    mtonos = json['Mtonos'] != null ? json['Mtonos'].cast<String>() : [];
    if (json['Emps'] != null) {
      emps = [];
      json['Emps'].forEach((v) {
        emps?.add(Emps.fromJson(v));
      });
    }
    if (json['Processes'] != null) {
      processes = [];
      json['Processes'].forEach((v) {
        processes?.add(Processes.fromJson(v));
      });
    }
    hasBarcode = json['HasBarcode'];
    cardNos = json['CardNos'] != null ? json['CardNos'].cast<String>() : [];
  }

  int? interID;
  List<int>? entryIDs;
  List<int>? fIDs;
  String? number;
  int? productID;
  String? productNumber;
  List<int>? partIDs;
  List<String>? partNames;
  List<String>? mtonos;
  List<Emps>? emps;
  List<Processes>? processes;
  bool? hasBarcode;
  List<String>? cardNos;
  bool select = false;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['InterID'] = interID;
    map['EntryIDs'] = entryIDs;
    map['FIDs'] = fIDs;
    map['Number'] = number;
    map['ProductID'] = productID;
    map['ProductNumber'] = productNumber;
    map['PartIDs'] = partIDs;
    map['PartNames'] = partNames;
    map['Mtonos'] = mtonos;
    if (emps != null) {
      map['Emps'] = emps?.map((v) => v.toJson()).toList();
    }
    if (processes != null) {
      map['Processes'] = processes?.map((v) => v.toJson()).toList();
    }
    map['HasBarcode'] = hasBarcode;
    map['CardNos'] = cardNos;
    return map;
  }

  String getParts() {
    var name = '';
    partNames?.forEach((v) {
      name = '$name$v、';
    });

    if (name.isNotEmpty) {
      name = name.substring(0, name.length - 1);
    }
    return name;
  }

  String getSales() {
    var name = '';
    mtonos?.forEach((v) {
      name = '$name$v、';
    });

    if (name.isNotEmpty) {
      name = name.substring(0, name.length - 1);
    }
    return name;
  }

  String getPersonal() {
    var name = '';
    emps?.forEach((v) {
      name = '$name${v.empName}(${v.empNumber})、';
    });

    if (name.isNotEmpty) {
      name = name.substring(0, name.length - 1);
    }
    return name;
  }

  String getProcess() {
    var name = '';
    processes?.forEach((v) {
      name = '$name<${v.processName},${v.qty.toShowString()}${v.unit}>';
    });
    return name;
  }
}

// ProcessName : "激光脚背饰带（2条）"
/// Qty : 903.000
/// Unit : "双"

class Processes {
  Processes({
    this.processName,
    this.qty,
    this.unit,
  });

  Processes.fromJson(dynamic json) {
    processName = json['ProcessName'];
    qty = json['Qty'];
    unit = json['Unit'];
  }

  String? processName;
  double? qty;
  String? unit;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ProcessName'] = processName;
    map['Qty'] = qty;
    map['Unit'] = unit;
    return map;
  }
}

/// EmpID : 228392
/// EmpNumber : "041102"
/// EmpName : "黄斌"

class Emps {
  Emps({
    this.empID,
    this.empNumber,
    this.empName,
  });

  Emps.fromJson(dynamic json) {
    empID = json['EmpID'];
    empNumber = json['EmpNumber'];
    empName = json['EmpName'];
  }

  int? empID;
  String? empNumber;
  String? empName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['EmpID'] = empID;
    map['EmpNumber'] = empNumber;
    map['EmpName'] = empName;
    return map;
  }
}
