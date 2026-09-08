import 'package:flutter/material.dart';
import 'package:jd_flutter/utils/extension_util.dart';

// SalesOrder : "N2400054"
// CustOrderNumber : "202408140001"
// TotalPiece : 20.0
// NoScanPiece : 20.0

class CartonLabelScanProgressInfo {
  CartonLabelScanProgressInfo({
    this.interID,
    this.salesOrder,
    this.custOrderNumber,
    this.totalPiece,
    this.noScanPiece,
  });

  CartonLabelScanProgressInfo.fromJson(dynamic json) {
    interID = JsonParse.toInt(json['SCMOInterID']);
    salesOrder = JsonParse.str(json['SalesOrder']);
    custOrderNumber = JsonParse.str(json['CustOrderNumber']);
    totalPiece = JsonParse.toDouble(json['TotalPiece']);
    noScanPiece = JsonParse.toDouble(json['NoScanPiece']);
    scanned = totalPiece! - noScanPiece!;
  }

  int? interID;
  String? salesOrder;
  String? custOrderNumber;
  double? totalPiece;
  double? noScanPiece;
  double scanned = 0;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['SCMOInterID'] = interID;
    map['SalesOrder'] = salesOrder;
    map['CustOrderNumber'] = custOrderNumber;
    map['TotalPiece'] = totalPiece;
    map['NoScanPiece'] = noScanPiece;
    return map;
  }
}

// OutBoxBarCode : "00340486681090872291"
// Size : "混码"
// SendCustomSystemState : 0

class CartonLabelScanProgressDetailInfo {
  CartonLabelScanProgressDetailInfo({
    this.cartonNo,
    this.outBoxBarCode,
    this.size,
    this.sendCustomSystemState,
  });

  CartonLabelScanProgressDetailInfo.fromJson(dynamic json) {
    cartonNo = JsonParse.str(json['CartonNo']);
    outBoxBarCode = JsonParse.str(json['OutBoxBarCode']);
    size = JsonParse.str(json['Size']);
    sendCustomSystemState = JsonParse.toInt(json['SendCustomSystemState']);
    totalPiece = JsonParse.toInt(json['TotalPiece']);
    scanPiece = JsonParse.toInt(json['ScanPiece']);
    isOnlyOne = (totalPiece == scanPiece && totalPiece == 1);
  }

  String? cartonNo;
  String? outBoxBarCode;
  String? size;
  int? sendCustomSystemState;
  int? totalPiece;
  int? scanPiece;
  bool isOnlyOne = false;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['CartonNo'] = cartonNo;
    map['OutBoxBarCode'] = outBoxBarCode;
    map['Size'] = size;
    map['SendCustomSystemState'] = sendCustomSystemState;
    map['TotalPiece'] = totalPiece;
    map['ScanPiece'] = scanPiece;
    return map;
  }

  Color stateColor() {
    return sendCustomSystemState == 1
        ? Colors.deepOrange.shade300
        : sendCustomSystemState == 2
            ? Colors.green
            : Colors.grey;
  }

  String getScanProgress() => '$scanPiece / $totalPiece';
}
