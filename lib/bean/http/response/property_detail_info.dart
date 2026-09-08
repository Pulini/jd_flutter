import 'package:jd_flutter/utils/extension_util.dart';
// StatusID : 1
// StatusName : "使用中"
// InterID : 102433
// StyleID : 1
// DeptID : 554577
// KeepEmpID : 209579
// OrganizeID : 1
// Model : "2023款华为MateBook-14皓月银"
// Number : "A001241647"
// SAPCgOrderNo : "4500734300"
// Name : "笔记本"
// Status : "已审核"
// ProcessStatus : 2
// LabelPrintQty : 1
// Manufacturer : "  "
// Qty : 1.0
// CurrencyName : "人民币"
// Price : 5250.0
// OrgVal : 4646.02
// BuyDate : "2024-01-04"
// GuaranteePeriod : ""
// WriteDate : "2024-01-05"
// ReviceDate : "2024-01-11"
// ProduceDate : ""
// Vender : "温州斯艾斯通信有限公司"
// CustodianCode : "033953"
// CustodianName : "周元双"
// LiableEmpID : 5351
// LiableEmpName : "诸建勇"
// Participator : 139797
// ParticipatorCode : "015114"
// ParticipatorName : "李进"
// Sno : "0000400029290000"
// OrganizeName : "01.01|金帝集团股份有限公司"
// DeptName : "总经理室"
// Address : "金帝办公楼3楼总经理室"
// Notes : "24332000000003351748"
// RegistrationerID : 140274
// SAPINVOICENO : "24332000000003351748"
// IsCardCheck : 0
// IsFinanceCheck : 0
// CheckInterID : 0
// ExpectedLife : 36
// TypeName : ""
// Unit : ""
// LiableEmpCode : ""
// AssetPicture : ""
// RatingPlatePicture : ""
// CardEntry : [{"Name":"","Qty":0.0,"Price":0.0,"Amount":0.0,"Plce":"","Notes":""},{"Name":"","Qty":0.0,"Price":0.0,"Amount":0.0,"Plce":"","Notes":""}]

class PropertyDetailInfo {
  PropertyDetailInfo({
    this.statusID,
    this.statusName,
    this.interID,
    this.styleID,
    this.deptID,
    this.keepEmpID,
    this.organizeID,
    this.model,
    this.number,
    this.sapCgOrderNo,
    this.name,
    this.status,
    this.processStatus,
    this.labelPrintQty,
    this.laserPrintQty,
    this.manufacturer,
    this.qty,
    this.currencyName,
    this.price,
    this.orgVal,
    this.buyDate,
    this.guaranteePeriod,
    this.writeDate,
    this.reviceDate,
    this.produceDate,
    this.vender,
    this.custodianCode,
    this.custodianName,
    this.liableEmpID,
    this.liableEmpName,
    this.participator,
    this.participatorCode,
    this.participatorName,
    this.sno,
    this.organizeName,
    this.deptName,
    this.address,
    this.notes,
    this.registrantID,
    this.sapInvoiceNo,
    this.isCardCheck,
    this.isFinanceCheck,
    this.checkInterID,
    this.expectedLife,
    this.typeName,
    this.unit,
    this.liableEmpCode,
    this.assetPicture,
    this.ratingPlatePicture,
    this.cardEntry,
  });

  PropertyDetailInfo.fromJson(dynamic json) {
    statusID = JsonParse.toInt(json['StatusID']);
    statusName = JsonParse.str(json['StatusName']);
    interID = JsonParse.toInt(json['InterID']);
    styleID = JsonParse.toInt(json['StyleID']);
    deptID = JsonParse.toInt(json['DeptID']);
    keepEmpID = JsonParse.toInt(json['KeepEmpID']);
    organizeID = JsonParse.toInt(json['OrganizeID']);
    model = JsonParse.str(json['Model']);
    number = JsonParse.str(json['Number']);
    sapCgOrderNo = JsonParse.str(json['SAPCgOrderNo']);
    name = JsonParse.str(json['Name']);
    status = JsonParse.str(json['Status']);
    processStatus = JsonParse.toInt(json['ProcessStatus']);
    labelPrintQty = JsonParse.toInt(json['LabelPrintQty']);
    laserPrintQty = JsonParse.toInt(json['LaserPrintQty']);
    manufacturer = JsonParse.str(json['Manufacturer']);
    qty = JsonParse.toDouble(json['Qty']);
    currencyName = JsonParse.str(json['CurrencyName']);
    price = JsonParse.toDouble(json['Price']);
    orgVal = JsonParse.toDouble(json['OrgVal']);
    buyDate = JsonParse.str(json['BuyDate']);
    guaranteePeriod = JsonParse.str(json['GuaranteePeriod']);
    writeDate = JsonParse.str(json['WriteDate']);
    reviceDate = JsonParse.str(json['ReviceDate']);
    produceDate = JsonParse.str(json['ProduceDate']);
    vender = JsonParse.str(json['Vender']);
    custodianCode = JsonParse.str(json['CustodianCode']);
    custodianName = JsonParse.str(json['CustodianName']);
    liableEmpID = JsonParse.toInt(json['LiableEmpID']);
    liableEmpName = JsonParse.str(json['LiableEmpName']);
    participator = JsonParse.toInt(json['Participator']);
    participatorCode = JsonParse.str(json['ParticipatorCode']);
    participatorName = JsonParse.str(json['ParticipatorName']);
    sno = JsonParse.str(json['Sno']);
    organizeName = JsonParse.str(json['OrganizeName']);
    deptName = JsonParse.str(json['DeptName']);
    address = JsonParse.str(json['Address']);
    notes = JsonParse.str(json['Notes']);
    registrantID = JsonParse.toInt(json['RegistrationerID']);
    sapInvoiceNo = JsonParse.str(json['SAPINVOICENO']);
    isCardCheck = JsonParse.toInt(json['IsCardCheck']);
    isFinanceCheck = JsonParse.toInt(json['IsFinanceCheck']);
    checkInterID = JsonParse.toInt(json['CheckInterID']);
    expectedLife = JsonParse.toInt(json['ExpectedLife']);
    typeName = JsonParse.str(json['TypeName']);
    unit = JsonParse.str(json['Unit']);
    liableEmpCode = JsonParse.str(json['LiableEmpCode']);
    assetPicture = JsonParse.str(json['AssetPicture']);
    ratingPlatePicture = JsonParse.str(json['RatingPlatePicture']);
    cardEntry = JsonParse.list(json['CardEntry'], CardEntry.fromJson);
  }

  int? statusID;
  String? statusName;
  int? interID;
  int? styleID;
  int? deptID;
  int? keepEmpID;
  int? organizeID;
  String? model;
  String? number;
  String? sapCgOrderNo;
  String? name;
  String? status;
  int? processStatus;
  int? labelPrintQty;
  int? laserPrintQty; //激光打印次数
  String? manufacturer;
  double? qty;
  String? currencyName;
  double? price;
  double? orgVal;
  String? buyDate;
  String? guaranteePeriod;
  String? writeDate;
  String? reviceDate;
  String? produceDate;
  String? vender;
  String? custodianCode;
  String? custodianName;
  int? liableEmpID;
  String? liableEmpName;
  int? participator;
  String? participatorCode;
  String? participatorName;
  String? sno;
  String? organizeName;
  String? deptName;
  String? address;
  String? notes;
  int? registrantID;
  String? sapInvoiceNo;
  int? isCardCheck;
  int? isFinanceCheck;
  int? checkInterID;
  int? expectedLife;
  String? typeName;
  String? unit;
  String? liableEmpCode;
  String? assetPicture;
  String? ratingPlatePicture;
  List<CardEntry>? cardEntry;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['StatusID'] = statusID;
    map['StatusName'] = statusName;
    map['InterID'] = interID;
    map['StyleID'] = styleID;
    map['DeptID'] = deptID;
    map['KeepEmpID'] = keepEmpID;
    map['OrganizeID'] = organizeID;
    map['Model'] = model;
    map['Number'] = number;
    map['SAPCgOrderNo'] = sapCgOrderNo;
    map['Name'] = name;
    map['Status'] = status;
    map['ProcessStatus'] = processStatus;
    map['LabelPrintQty'] = labelPrintQty;
    map['LaserPrintQty'] = laserPrintQty;
    map['Manufacturer'] = manufacturer;
    map['Qty'] = qty;
    map['CurrencyName'] = currencyName;
    map['Price'] = price;
    map['OrgVal'] = orgVal;
    map['BuyDate'] = buyDate;
    map['GuaranteePeriod'] = guaranteePeriod;
    map['WriteDate'] = writeDate;
    map['ReviceDate'] = reviceDate;
    map['ProduceDate'] = produceDate;
    map['Vender'] = vender;
    map['CustodianCode'] = custodianCode;
    map['CustodianName'] = custodianName;
    map['LiableEmpID'] = liableEmpID;
    map['LiableEmpName'] = liableEmpName;
    map['Participator'] = participator;
    map['ParticipatorCode'] = participatorCode;
    map['ParticipatorName'] = participatorName;
    map['Sno'] = sno;
    map['OrganizeName'] = organizeName;
    map['DeptName'] = deptName;
    map['Address'] = address;
    map['Notes'] = notes;
    map['RegistrationerID'] = registrantID;
    map['SAPINVOICENO'] = sapInvoiceNo;
    map['IsCardCheck'] = isCardCheck;
    map['IsFinanceCheck'] = isFinanceCheck;
    map['CheckInterID'] = checkInterID;
    map['ExpectedLife'] = expectedLife;
    map['TypeName'] = typeName;
    map['Unit'] = unit;
    map['LiableEmpCode'] = liableEmpCode;
    map['AssetPicture'] = assetPicture;
    map['RatingPlatePicture'] = ratingPlatePicture;
    if (cardEntry != null) {
      map['CardEntry'] = cardEntry?.map((v) => v.toJson()).toList();
    }
    return map;
  }


}

// Name : ""
// Qty : 0.0
// Price : 0.0
// Amount : 0.0
// Place : ""
// Notes : ""

class CardEntry {
  CardEntry({
    this.name,
    this.qty,
    this.price,
    this.amount,
    this.place,
    this.notes,
  });

  CardEntry.fromJson(dynamic json) {
    name = JsonParse.str(json['Name']);
    qty = JsonParse.toDouble(json['Qty']);
    price = JsonParse.toDouble(json['Price']);
    amount = JsonParse.toDouble(json['Amount']);
    place = JsonParse.str(json['Place']);
    notes = JsonParse.str(json['Notes']);
  }

  String? name;
  double? qty;
  double? price;
  double? amount;
  String? place;
  String? notes;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Name'] = name;
    map['Qty'] = qty;
    map['Price'] = price;
    map['Amount'] = amount;
    map['Place'] = place;
    map['Notes'] = notes;
    return map;
  }
}
