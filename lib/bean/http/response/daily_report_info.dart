import 'package:flutter/material.dart';

class DailyReport {
  DailyReport({
    this.type,
    this.materialName,
    this.size,
    this.processName,
    this.qty,
    this.seOrderNo,
  });

  DailyReport.fromJson(dynamic json) {
    type = json['Type'];
    materialName = json['MaterialName'];
    size = json['Size'];
    processName = json['ProcessName'];
    seOrderNo = json['SeOrderNo'];
    qty = json['Qty'].toString();
  }

  int? type;
  String? materialName;
  String? size;
  String? processName;
  String? seOrderNo;
  String? qty;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Type'] = type;
    map['MaterialName'] = materialName;
    map['Size'] = size;
    map['ProcessName'] = processName;
    map['Qty'] = qty;
    map['SeOrderNo'] = seOrderNo;
    return map;
  }
  Color? getItemColor() {
    switch (type) {
      case 0:
        return Colors.greenAccent;
      case 1:
        return Colors.blue[200];
      default:
        return Colors.blue;
    }
  }
}
