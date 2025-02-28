// Number : "F002240051"
// InterID : 102526
// Name : "海尔冰柜"
// CustodianName : "邓林波"
// BuyDate : "2024-01-16 00:00"
// WriteDate : "2024-01-17 00:00"
// Address : "金帝办公楼5楼"
// ProcessStatus : "2"
// LabelPrintQty : 0
// SAPCgOrderNo : "4500734296"
// VisitedNum : 0

class PropertyInfo {
  PropertyInfo({
      this.number, 
      this.interID, 
      this.name, 
      this.custodianName, 
      this.buyDate, 
      this.writeDate, 
      this.address, 
      this.processStatus, 
      this.labelPrintQty, 
      this.sapCgOrderNo,
      this.sapInvoiceNo,
      this.visitedNum,});

  PropertyInfo.fromJson(dynamic json) {
    number = json['Number'];
    interID = json['InterID'];
    name = json['Name'];
    custodianName = json['CustodianName'];
    buyDate = json['BuyDate'];
    writeDate = json['WriteDate'];
    address = json['Address'];
    processStatus = json['ProcessStatus'];
    labelPrintQty = json['LabelPrintQty'];
    sapCgOrderNo = json['SAPCgOrderNo'];
    sapInvoiceNo = json['SAPINVOICENO'];
    visitedNum = json['VisitedNum'];
  }
  bool isChecked=false;
  String? number;
  int? interID;
  String? name;
  String? custodianName;
  String? buyDate;
  String? writeDate;
  String? address;
  String? processStatus;//0未审核 1审核中 2已审核
  int? labelPrintQty;
  String? sapCgOrderNo;
  String? sapInvoiceNo;
  int? visitedNum;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Number'] = number;
    map['InterID'] = interID;
    map['Name'] = name;
    map['CustodianName'] = custodianName;
    map['BuyDate'] = buyDate;
    map['WriteDate'] = writeDate;
    map['Address'] = address;
    map['ProcessStatus'] = processStatus;
    map['LabelPrintQty'] = labelPrintQty;
    map['SAPCgOrderNo'] = sapCgOrderNo;
    map['SAPINVOICENO'] = sapInvoiceNo;
    map['VisitedNum'] = visitedNum;
    return map;
  }

}