import 'package:jd_flutter/utils/extension_util.dart';
class PartReportTicketInfo {
  PartReportTicketInfo({
    this.factoryType,
    this.partName,
    this.processName,
    this.qty,
    this.empID,
    this.empNumber,
    this.empName,
    this.ticketItem,
  });

  PartReportTicketInfo.fromJson(dynamic json) {
    factoryType = JsonParse.str(json['FactoryType']);
    partName = JsonParse.str(json['PartName']);
    processName = JsonParse.str(json['ProcessName']);
    qty = JsonParse.toDouble(json['Qty']);
    empID = JsonParse.str(json['EmpID']);
    empNumber = JsonParse.str(json['EmpNumber']);
    empName = JsonParse.str(json['EmpName']);
    ticketItem = JsonParse.list(json['Items'], TicketItem.fromJson);
  }

  String? factoryType; //工厂型体
  String? partName; //部件名称
  String? processName; //工序名称
  double? qty; //数量
  String? empID;
  String? empNumber;
  String? empName;
  List<TicketItem>? ticketItem;


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['FactoryType'] = factoryType;
    map['PartName'] = partName;
    map['ProcessName'] = processName;
    map['Qty'] = qty;
    map['EmpID'] = empID;
    map['EmpNumber'] = empNumber;
    map['EmpName'] = empName;
    if (ticketItem != null) {
      map['Items'] = ticketItem?.map((v) => v.toJson()).toList();
    }

    return map;
  }
}

class TicketItem {
  TicketItem({
    this.processName,
    this.mtono,
    this.size,
    this.qty,
  });

  TicketItem.fromJson(dynamic json) {
    processName = JsonParse.str(json['ProcessName']);
    mtono = JsonParse.str(json['Mtono']);
    size = JsonParse.str(json['Size']);
    qty = JsonParse.toDouble(json['Qty']);

  }

  String? processName;  //工序
  String? mtono;  //指令
  String? size;  //尺码
  double? qty;  //数量


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ProcessName'] = processName;
    map['Mtono'] = mtono;
    map['Size'] = size;
    map['Qty'] = qty;

    return map;
  }
}


