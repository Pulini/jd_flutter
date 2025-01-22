import 'package:flutter/material.dart';

/// SalesOrder : "N2400054"
/// CustOrderNumber : "202408140001"
/// TotalPiece : 20.0
/// NoScanPiece : 20.0

class CartonLabelScanProgressInfo {
  CartonLabelScanProgressInfo({
    this.interID,
    this.salesOrder,
    this.custOrderNumber,
    this.totalPiece,
    this.noScanPiece,
  });

  CartonLabelScanProgressInfo.fromJson(dynamic json) {
    interID = json['SCMOInterID'];
    salesOrder = json['SalesOrder'];
    custOrderNumber = json['CustOrderNumber'];
    totalPiece = json['TotalPiece'];
    noScanPiece = json['NoScanPiece'];
    scanned=totalPiece!-noScanPiece!;
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

/// OutBoxBarCode : "00340486681090872291"
/// Size : "混码"
/// SendCustomSystemState : 0

class CartonLabelScanProgressDetailInfo {
  CartonLabelScanProgressDetailInfo({
    this.cartonNo,
    this.outBoxBarCode,
    this.size,
    this.sendCustomSystemState,
  });

  CartonLabelScanProgressDetailInfo.fromJson(dynamic json) {
    cartonNo = json['CartonNo'];
    outBoxBarCode = json['OutBoxBarCode'];
    size = json['Size'];
    sendCustomSystemState = json['SendCustomSystemState'];
  }

  String? cartonNo;
  String? outBoxBarCode;
  String? size;
  int? sendCustomSystemState;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['CartonNo'] = cartonNo;
    map['OutBoxBarCode'] = outBoxBarCode;
    map['Size'] = size;
    map['SendCustomSystemState'] = sendCustomSystemState;
    return map;
  }
  stateColor(){
    return sendCustomSystemState==1?Colors.yellow:sendCustomSystemState==2?Colors.green:Colors.grey;
  }


}
