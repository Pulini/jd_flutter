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
    statusID = json['StatusID'];
    statusName = json['StatusName'];
    interID = json['InterID'];
    styleID = json['StyleID'];
    deptID = json['DeptID'];
    keepEmpID = json['KeepEmpID'];
    organizeID = json['OrganizeID'];
    model = json['Model'];
    number = json['Number'];
    sapCgOrderNo = json['SAPCgOrderNo'];
    name = json['Name'];
    status = json['Status'];
    processStatus = json['ProcessStatus'];
    labelPrintQty = json['LabelPrintQty'];
    manufacturer = json['Manufacturer'];
    qty = json['Qty'];
    currencyName = json['CurrencyName'];
    price = json['Price'];
    orgVal = json['OrgVal'];
    buyDate = json['BuyDate'];
    guaranteePeriod = json['GuaranteePeriod'];
    writeDate = json['WriteDate'];
    reviceDate = json['ReviceDate'];
    produceDate = json['ProduceDate'];
    vender = json['Vender'];
    custodianCode = json['CustodianCode'];
    custodianName = json['CustodianName'];
    liableEmpID = json['LiableEmpID'];
    liableEmpName = json['LiableEmpName'];
    participator = json['Participator'];
    participatorCode = json['ParticipatorCode'];
    participatorName = json['ParticipatorName'];
    sno = json['Sno'];
    organizeName = json['OrganizeName'];
    deptName = json['DeptName'];
    address = json['Address'];
    notes = json['Notes'];
    registrantID = json['RegistrationerID'];
    sapInvoiceNo = json['SAPINVOICENO'];
    isCardCheck = json['IsCardCheck'];
    isFinanceCheck = json['IsFinanceCheck'];
    checkInterID = json['CheckInterID'];
    expectedLife = json['ExpectedLife'];
    typeName = json['TypeName'];
    unit = json['Unit'];
    liableEmpCode = json['LiableEmpCode'];
    assetPicture = json['AssetPicture'];
    ratingPlatePicture = json['RatingPlatePicture'];
    if (json['CardEntry'] != null) {
      cardEntry = [];
      json['CardEntry'].forEach((v) {
        cardEntry?.add(CardEntry.fromJson(v));
      });
    }
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
    name = json['Name'];
    qty = json['Qty'];
    price = json['Price'];
    amount = json['Amount'];
    place = json['Place'];
    notes = json['Notes'];
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
