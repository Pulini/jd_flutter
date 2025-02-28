// DeviceMessage : {"DeviceID":10473,"DeviceNo":"A013111516","DeviceName":"空调","Model":"格力立式3p","CustodianID":13927,"CustodianCode":"007371","CustodianName":"廖小燕","CustodianDept":"金帝厂设备组","CustodianTel":"15869470406"}
// RepairOrder : {"InterID":5,"Number":"SBWXJLD2000005","DeviceID":10473,"DeviceNo":"A013111516","DeviceName":"空调","Model":"格力立式3p","CustodianID":13927,"CustodianCode":"007371","CustodianDept":"金帝厂设备组","CustodianTel":"15869470406","MaintenanceUnit":"。","RepairParts":"。","InspectionTime":"2020-07-06","FaultDescription":"，","RepairTime":"2020-07-06","IssueCause":"其它","AssessmentPrevention":"，","Custodian":"","RepairEntryData":[{"AccessoriesName":"，","Manufacturer":"，","Specification":"，","Quantity":1,"Unit":"，","Budget":1,"Remarks":"，"}]}

class DeviceMaintenanceInfo {
  DeviceMaintenanceInfo({
      this.deviceMessage, 
      this.repairOrder,});

  DeviceMaintenanceInfo.fromJson(dynamic json) {
    deviceMessage = json['DeviceMessage'] != null ? DeviceMessage.fromJson(json['DeviceMessage']) : null;
    repairOrder = json['RepairOrder'] != null ? RepairOrder.fromJson(json['RepairOrder']) : null;
  }
  DeviceMessage? deviceMessage;
  RepairOrder? repairOrder;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (deviceMessage != null) {
      map['DeviceMessage'] = deviceMessage?.toJson();
    }
    if (repairOrder != null) {
      map['RepairOrder'] = repairOrder?.toJson();
    }
    return map;
  }

}

// InterID : 5
// Number : "SBWXJLD2000005"
// DeviceID : 10473
// DeviceNo : "A013111516"
// DeviceName : "空调"
// Model : "格力立式3p"
// CustodianID : 13927
// CustodianCode : "007371"
// CustodianDept : "金帝厂设备组"
// CustodianTel : "15869470406"
// MaintenanceUnit : "。"
// RepairParts : "。"
// InspectionTime : "2020-07-06"
// FaultDescription : "，"
// RepairTime : "2020-07-06"
// IssueCause : "其它"
// AssessmentPrevention : "，"
// Custodian : ""
// RepairEntryData : [{"AccessoriesName":"，","Manufacturer":"，","Specification":"，","Quantity":1,"Unit":"，","Budget":1,"Remarks":"，"}]

class RepairOrder {
  RepairOrder({
      this.interID, 
      this.number, 
      this.deviceID, 
      this.deviceNo, 
      this.deviceName, 
      this.model, 
      this.custodianID, 
      this.custodianCode, 
      this.custodianDept, 
      this.custodianTel, 
      this.maintenanceUnit, 
      this.repairParts, 
      this.inspectionTime, 
      this.faultDescription, 
      this.repairTime, 
      this.issueCause, 
      this.assessmentPrevention, 
      this.custodian, 
      this.repairEntryData,});

  RepairOrder.fromJson(dynamic json) {
    interID = json['InterID'];
    number = json['Number'];
    deviceID = json['DeviceID'];
    deviceNo = json['DeviceNo'];
    deviceName = json['DeviceName'];
    model = json['Model'];
    custodianID = json['CustodianID'];
    custodianCode = json['CustodianCode'];
    custodianDept = json['CustodianDept'];
    custodianTel = json['CustodianTel'];
    maintenanceUnit = json['MaintenanceUnit'];
    repairParts = json['RepairParts'];
    inspectionTime = json['InspectionTime'];
    faultDescription = json['FaultDescription'];
    repairTime = json['RepairTime'];
    issueCause = json['IssueCause'];
    assessmentPrevention = json['AssessmentPrevention'];
    custodian = json['Custodian'];
    if (json['RepairEntryData'] != null) {
      repairEntryData = [];
      json['RepairEntryData'].forEach((v) {
        repairEntryData?.add(RepairEntryData.fromJson(v));
      });
    }
  }
  int? interID;
  String? number;
  int? deviceID;
  String? deviceNo;
  String? deviceName;
  String? model;
  int? custodianID;
  String? custodianCode;
  String? custodianDept;
  String? custodianTel;
  String? maintenanceUnit;
  String? repairParts;
  String? inspectionTime;
  String? faultDescription;
  String? repairTime;
  String? issueCause;
  String? assessmentPrevention;
  String? custodian;
  List<RepairEntryData>? repairEntryData;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['InterID'] = interID;
    map['Number'] = number;
    map['DeviceID'] = deviceID;
    map['DeviceNo'] = deviceNo;
    map['DeviceName'] = deviceName;
    map['Model'] = model;
    map['CustodianID'] = custodianID;
    map['CustodianCode'] = custodianCode;
    map['CustodianDept'] = custodianDept;
    map['CustodianTel'] = custodianTel;
    map['MaintenanceUnit'] = maintenanceUnit;
    map['RepairParts'] = repairParts;
    map['InspectionTime'] = inspectionTime;
    map['FaultDescription'] = faultDescription;
    map['RepairTime'] = repairTime;
    map['IssueCause'] = issueCause;
    map['AssessmentPrevention'] = assessmentPrevention;
    map['Custodian'] = custodian;
    if (repairEntryData != null) {
      map['RepairEntryData'] = repairEntryData?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

// AccessoriesName : "，"
// Manufacturer : "，"
// Specification : "，"
// Quantity : 1
// Unit : "，"
// Budget : 1
// Remarks : "，"

class RepairEntryData {
  RepairEntryData({
      this.accessoriesName, 
      this.manufacturer, 
      this.specification, 
      this.quantity, 
      this.unit, 
      this.budget, 
      this.remarks,});

  RepairEntryData.fromJson(dynamic json) {
    accessoriesName = json['AccessoriesName'];
    manufacturer = json['Manufacturer'];
    specification = json['Specification'];
    quantity = json['Quantity'];
    unit = json['Unit'];
    budget = json['Budget'];
    remarks = json['Remarks'];
  }
  String? accessoriesName;
  String? manufacturer;
  String? specification;
  int? quantity;
  String? unit;
  int? budget;
  String? remarks;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['AccessoriesName'] = accessoriesName;
    map['Manufacturer'] = manufacturer;
    map['Specification'] = specification;
    map['Quantity'] = quantity;
    map['Unit'] = unit;
    map['Budget'] = budget;
    map['Remarks'] = remarks;
    return map;
  }

}

// DeviceID : 10473
// DeviceNo : "A013111516"
// DeviceName : "空调"
// Model : "格力立式3p"
// CustodianID : 13927
// CustodianCode : "007371"
// CustodianName : "廖小燕"
// CustodianDept : "金帝厂设备组"
// CustodianTel : "15869470406"

class DeviceMessage {
  DeviceMessage({
      this.deviceID, 
      this.deviceNo, 
      this.deviceName, 
      this.model, 
      this.custodianID, 
      this.custodianCode, 
      this.custodianName, 
      this.custodianDept, 
      this.custodianTel,});

  DeviceMessage.fromJson(dynamic json) {
    deviceID = json['DeviceID'];
    deviceNo = json['DeviceNo'];
    deviceName = json['DeviceName'];
    model = json['Model'];
    custodianID = json['CustodianID'];
    custodianCode = json['CustodianCode'];
    custodianName = json['CustodianName'];
    custodianDept = json['CustodianDept'];
    custodianTel = json['CustodianTel'];
  }
  int? deviceID;
  String? deviceNo;
  String? deviceName;
  String? model;
  int? custodianID;
  String? custodianCode;
  String? custodianName;
  String? custodianDept;
  String? custodianTel;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['DeviceID'] = deviceID;
    map['DeviceNo'] = deviceNo;
    map['DeviceName'] = deviceName;
    map['Model'] = model;
    map['CustodianID'] = custodianID;
    map['CustodianCode'] = custodianCode;
    map['CustodianName'] = custodianName;
    map['CustodianDept'] = custodianDept;
    map['CustodianTel'] = custodianTel;
    return map;
  }

}