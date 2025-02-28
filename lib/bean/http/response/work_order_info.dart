import 'package:flutter/material.dart';
import 'package:jd_flutter/utils/utils.dart';

// InterID : 213332
// OrderBill : "P2048871"
// OrderDate : "2024-03-22"
// PlantBody : "D13677-22B M"
// Group : "金臻_沿条课"
// ProcessFlowName : "造粒"
// MaterialCode : "460100005"
// WorkNumberTotal : "0.02"
// CodeInfos : []
// MtonoInfos : [{"PlanBill":"ZJ2400000252","WorkNumberTotal":"0.02"}]

class WorkOrderInfo {
  WorkOrderInfo({
    this.interID,
    this.orderBill,
    this.orderDate,
    this.plantBody,
    this.group,
    this.processFlowName,
    this.materialCode,
    this.workNumberTotal,
    this.codeInfos,
    this.mtonoInfos,
  });

  WorkOrderInfo.fromJson(dynamic json) {
    interID = json['InterID'];
    orderBill = json['OrderBill'];
    orderDate = json['OrderDate'];
    plantBody = json['PlantBody'];
    group = json['Group'];
    processFlowName = json['ProcessFlowName'];
    materialCode = json['MaterialCode'];
    workNumberTotal = json['WorkNumberTotal'];
    if (json['CodeInfos'] != null) {
      codeInfos = [];
      json['CodeInfos'].forEach((v) {
        codeInfos?.add(CodeInfo.fromJson(v));
      });
    }
    if (json['MtonoInfos'] != null) {
      mtonoInfos = [];
      json['MtonoInfos'].forEach((v) {
        mtonoInfos?.add(MtonoInfos.fromJson(v));
      });
    }
  }

  int? interID;
  String? orderBill;
  String? orderDate;
  String? plantBody;
  String? group;
  String? processFlowName;
  String? materialCode;
  String? workNumberTotal;
  List<CodeInfo>? codeInfos;
  List<MtonoInfos>? mtonoInfos;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['InterID'] = interID;
    map['OrderBill'] = orderBill;
    map['OrderDate'] = orderDate;
    map['PlantBody'] = plantBody;
    map['Group'] = group;
    map['ProcessFlowName'] = processFlowName;
    map['MaterialCode'] = materialCode;
    map['WorkNumberTotal'] = workNumberTotal;
    if (codeInfos != null) {
      map['CodeInfos'] = codeInfos?.map((v) => v.toJson()).toList();
    }
    if (mtonoInfos != null) {
      map['MtonoInfos'] = mtonoInfos?.map((v) => v.toJson()).toList();
    }
    return map;
  }

  int _getState() {
    double min = codeInfos?.isNotEmpty == true ? double.infinity : 0;
    codeInfos?.forEach((info) {
      if (min > (info.codeQty ?? 0)) {
        min = info.codeQty ?? 0;
      }
    });
    if (min == 0.0) {
      return 1;
    } else {
      if (min < workNumberTotal.toDoubleTry()) {
        return 2;
      } else {
        return 3;
      }
    }
  }

  String getStateName() {
    var state = '';
    switch (_getState()) {
      case 1:
        state = '未生成贴标';
        break;
      case 2:
        state = '生成部分贴标';
        break;
      default:
        state = '已生成贴标';
        break;
    }
    return state;
  }

  Color getStateColor() {
    var color = Colors.black;
    switch (_getState()) {
      case 1:
        color = Colors.green.shade900;
        break;
      case 2:
        color = Colors.blue.shade900;
        break;
      default:
        color = Colors.orange.shade900;
        break;
    }
    return color;
  }
}

// PlanBill : "ZJ2400000252"
// WorkNumberTotal : "0.02"

class MtonoInfos {
  MtonoInfos({
    this.planBill,
    this.workNumberTotal,
  });

  MtonoInfos.fromJson(dynamic json) {
    planBill = json['PlanBill'];
    workNumberTotal = json['WorkNumberTotal'];
  }

  String? planBill;
  String? workNumberTotal;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['PlanBill'] = planBill;
    map['WorkNumberTotal'] = workNumberTotal;
    return map;
  }
}

// PlanBill : "ZJ2400000252"
// WorkNumberTotal : "0.02"

class CodeInfo {
  CodeInfo({
    this.codeQty,
    this.partNames,
  });

  CodeInfo.fromJson(dynamic json) {
    codeQty = json['CodeQty'];
    partNames = json['PartNames'];
  }

  double? codeQty;
  String? partNames;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['CodeQty'] = codeQty;
    map['PartNames'] = partNames;
    return map;
  }
}
