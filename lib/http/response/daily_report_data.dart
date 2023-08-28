import 'package:flutter/material.dart';

class DailyReportData {
  DailyReportData({
    this.type,
    this.materialName,
    this.size,
    this.processName,
    this.qty,
  });

  DailyReportData.fromJson(dynamic json) {
    type = json['Type'];
    materialName = json['MaterialName'];
    size = json['Size'];
    processName = json['ProcessName'];
    qty = json['Qty'].toString();
  }

  int? type;
  String? materialName;
  String? size;
  String? processName;
  String? qty;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Type'] = type;
    map['MaterialName'] = materialName;
    map['Size'] = size;
    map['ProcessName'] = processName;
    map['Qty'] = qty;
    return map;
  }
  getItemColor() {
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
