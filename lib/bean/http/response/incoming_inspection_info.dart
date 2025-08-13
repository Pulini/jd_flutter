import 'package:jd_flutter/bean/http/response/photo_bean.dart';

class InspectionDeliveryInfo {
  String? barCode;
  String? billNo;
  String? billType;
  String? supplier;
  String? model;
  String? materialCode;
  String? materialName;
  double? qty;
  String? unitName;
  int? numPage;
  String? deliAddress;

  InspectionDeliveryInfo({
    this.barCode,
    this.billNo,
    this.billType,
    this.supplier,
    this.model,
    this.materialCode,
    this.materialName,
    this.qty,
    this.unitName,
    this.numPage,
    this.deliAddress,
  });

  factory InspectionDeliveryInfo.fromJson(Map<String, dynamic> json) {
    return InspectionDeliveryInfo(
      barCode: json['BarCode'],
      billNo: json['BillNo'],
      billType: json['BillType'],
      supplier: json['Supplier'],
      model: json['Model'],
      materialCode: json['MaterialCode'],
      materialName: json['MaterialName'],
      qty: json['Qty'],
      unitName: json['UnitName'],
      numPage: json['Numpage'],
      deliAddress: json['DeliAddress'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (barCode != null) data['BarCode'] = barCode;
    if (billNo != null) data['BillNo'] = billNo;
    if (billType != null) data['BillType'] = billType;
    if (supplier != null) data['Supplier'] = supplier;
    if (model != null) data['Model'] = model;
    if (materialCode != null) data['MaterialCode'] = materialCode;
    if (materialName != null) data['MaterialName'] = materialName;
    if (qty != null) data['Qty'] = qty;
    if (unitName != null) data['UnitName'] = unitName;
    if (numPage != null) data['Numpage'] = numPage;
    if (deliAddress != null) data['DeliAddress'] = deliAddress;
    return data;
  }

}

class InspectionOrderInfo {
  String? status; //1.等待稽查2.等待处理3.已签收4.等待异常处理5.已提交异常处理6.已结案
  String? interID;
  String? number;
  String? empName;
  String? applicationDate;
  String? supplier;
  String? note;

  InspectionOrderInfo({
    this.status,
    this.interID,
    this.number,
    this.empName,
    this.applicationDate,
    this.supplier,
    this.note,
  });

  factory InspectionOrderInfo.fromJson(Map<String, dynamic> json) {
    return InspectionOrderInfo(
      status: json['Status'],
      interID: json['InterID'],
      number: json['Number'],
      empName: json['EmpName'],
      applicationDate: json['ApplicationDate'],
      supplier: json['Supplier'],
      note: json['Note'],
    );
  }
}

class InspectionDetailInfo {
  String? billDate; //提交稽查时间
  String? builder; //提交稽查人
  String? checker; //签收人
  String? checkerDate; //签收时间
  String? closer; //稽查结案人
  String? closerDate; //稽查结案时间
  String? exception; //异常提交人
  String? exceptionDate; //异常提交时间
  String? exceptionHandler; //异常单处理提交人
  String? exceptionHandling; //异常处理结果
  String? exceptionInformation; //异常信息
  String? exceptionProcessingTime; //异常单处理提交时间
  String? inspectionDate; //稽查日期
  String? inspectionResult; //稽查结果
  String? inspector; //稽查人员
  int? interID; //工单ID
  String? number; //单号
  String? status; //状态
  String? supplier; //供应商
  List<InspectionMaterielInfo>? materielList; //物料列表
  List<PhotoBean>? pictureList; //照片列表

  InspectionDetailInfo({
    this.billDate,
    this.builder,
    this.checker,
    this.checkerDate,
    this.closer,
    this.closerDate,
    this.exception,
    this.exceptionDate,
    this.exceptionHandler,
    this.exceptionHandling,
    this.exceptionInformation,
    this.exceptionProcessingTime,
    this.inspectionDate,
    this.inspectionResult,
    this.inspector,
    this.interID,
    this.number,
    this.status,
    this.supplier,
    this.materielList,
    this.pictureList,
  });

  factory InspectionDetailInfo.fromJson(Map<String, dynamic> json) {
    return InspectionDetailInfo(
      billDate: json['BillDate'],
      builder: json['Biller'],
      checker: json['Checker'],
      checkerDate: json['CheckerDate'],
      closer: json['Closer'],
      closerDate: json['CloserDate'],
      exception: json['Exception'],
      exceptionDate: json['ExceptionDate'],
      exceptionHandler: json['ExceptionHandler'],
      exceptionHandling: json['ExceptionHandling'],
      exceptionInformation: json['ExceptionInformation'],
      exceptionProcessingTime: json['ExceptionProcessingTime'],
      inspectionDate: json['InspectionDate'],
      inspectionResult: json['InspectionResult'],
      inspector: json['Inspector'],
      interID: json['InterID'],
      number: json['Number'],
      status: json['Status'],
      supplier: json['Supplier'],
      materielList: [
        if (json['Items'] != null)
          for (var json in json['Items']) InspectionMaterielInfo.fromJson(json)
      ],
      pictureList: [
        if (json['PictureList'] != null)
          for (var json in json['PictureList']) PhotoBean.fromJson(json)
      ],
    );
  }
}

class InspectionMaterielInfo {
  int? numPage; //
  String? billNo; //
  String? itemName; //
  String? itemNumber; //
  double? auxQty; //
  String? unitName; //

  InspectionMaterielInfo({
    this.numPage,
    this.billNo,
    this.itemName,
    this.itemNumber,
    this.auxQty,
    this.unitName,
  });

  factory InspectionMaterielInfo.fromJson(Map<String, dynamic> json) {
    return InspectionMaterielInfo(
      numPage: json['Numpage'],
      billNo: json['BillNo'],
      itemName: json['ItemName'],
      itemNumber: json['ItemNumber'],
      auxQty: json['AuxQty'],
      unitName: json['UnitName'],
    );
  }
}
