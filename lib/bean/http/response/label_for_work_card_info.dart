import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class LabelForWorkCardInfo {
  LabelForWorkCardInfo({
      this.processWorkCardInfo, 
      this.componentList, 
      this.employeeList, 
      this.sizeList,
  });

  LabelForWorkCardInfo.fromJson(dynamic json) {
    processWorkCardInfo = json['ProcessWorkCardInfo'] != null ? ProcessWorkCardInfo.fromJson(json['ProcessWorkCardInfo']) : null;
    if (json['ComponentList'] != null) {
      componentList = [];
      json['ComponentList'].forEach((v) {
        componentList?.add(ComponentList.fromJson(v));
      });
    }
    if (json['EmployeeList'] != null) {
      employeeList = [];
      json['EmployeeList'].forEach((v) {
        employeeList?.add(EmployeeList.fromJson(v));
      });
    }
    if (json['SizeList'] != null) {
      sizeList = [];
      json['SizeList'].forEach((v) {
        sizeList?.add(SizeList.fromJson(v));
      });
    }
  }
  ProcessWorkCardInfo? processWorkCardInfo;
  List<ComponentList>? componentList;
  List<EmployeeList>? employeeList;
  List<SizeList>? sizeList;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (processWorkCardInfo != null) {
      map['ProcessWorkCardInfo'] = processWorkCardInfo?.toJson();
    }
    if (componentList != null) {
      map['ComponentList'] = componentList?.map((v) => v.toJson()).toList();
    }
    if (employeeList != null) {
      map['EmployeeList'] = employeeList?.map((v) => v.toJson()).toList();
    }
    if (sizeList != null) {
      map['SizeList'] = sizeList?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// Size : "7"
/// TotalQty : 126.0000000000
/// EmpID : 0
/// AllocatedQty : 0
/// FPrdMoID : 58397657

class SizeList {
  SizeList({
    this.size,
    this.totalQty,
    this.empID,
    this.allocatedQty,
    this.fPrdMoID,
  }) {
    _initUiState();
  }

  SizeList.fromJson(dynamic json) {
    size = json['Size'];
    totalQty = json['TotalQty'];
    empID = json['EmpID'];
    allocatedQty = json['AllocatedQty'];
    fPrdMoID = json['FPrdMoID'];
    _initUiState();
  }
  String? size;
  double? totalQty;
  int? empID;
  int? allocatedQty;
  int? fPrdMoID;

  // —— 交互 / UI 状态（非接口字段，不参与 toJson）——
  var assignedOperator = ''.obs; // 工号输入
  var currentQty = ''.obs; // 本次分配数量（输入框）
  var isMatched = false.obs; // 是否匹配到员工
  final operatorController = TextEditingController();
  final qtyController = TextEditingController();

  // 是否已分配过（来自 ProcessWorkCardInfo.allocationStatus == 1）。
  // 决定「本次可分配上限」取值口径：已分配→allocatedQty，未分配→totalQty
  bool isAllocated = false;

  // 本次可分配上限（max）：
  //  - allocationStatus==1（已分配过）：取接口给的已分配量 allocatedQty
  //  - allocationStatus==0（未分配）：取整行总数量 totalQty
  int get allocCap {
    final cap = isAllocated
        ? (allocatedQty ?? 0)
        : (totalQty?.toInt() ?? 0);
    return cap < 0 ? 0 : cap;
  }

  // 剩余未分配 = 上限 - 本次分配
  int get remainingQty => allocCap - (int.tryParse(currentQty.value) ?? 0);

  // 把「本次分配」重设为上限（默认规则：本次分配 = 上限）
  void fillQtyByTotal() {
    final cap = allocCap;
    currentQty.value = cap.toString();
    qtyController.text = currentQty.value;
  }

  // 重置：清空工号，本次分配回到默认值（= 总数量）
  void reset() {
    assignedOperator.value = '';
    isMatched.value = false;
    operatorController.clear();
    fillQtyByTotal();
  }

  void _initUiState() {
    fillQtyByTotal();
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Size'] = size;
    map['TotalQty'] = totalQty;
    map['EmpID'] = empID;
    map['AllocatedQty'] = allocatedQty;
    map['FPrdMoID'] = fPrdMoID;
    return map;
  }
}

/// FItemID : 224248
/// FNumber : "750239"
/// FName : "Ikah Marcella"
/// AvatarPath : "https://geapp.goldemperor.com:8084/PT.Gold Emperor Indonesia/员工/2024/8/Ikah Marcella/750239.jpg"

class EmployeeList {
  EmployeeList({
      this.fItemID, 
      this.fNumber, 
      this.fName, 
      this.avatarPath,});

  EmployeeList.fromJson(dynamic json) {
    fItemID = json['FItemID'];
    fNumber = json['FNumber'];
    fName = json['FName'];
    avatarPath = json['AvatarPath'];
  }
  int? fItemID;
  String? fNumber;
  String? fName;
  String? avatarPath;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['FItemID'] = fItemID;
    map['FNumber'] = fNumber;
    map['FName'] = fName;
    map['AvatarPath'] = avatarPath;
    return map;
  }

}

/// FInterID : 3240977
/// FItemID : 1584262
/// FPictureUrl : "https://geapp.goldemperor.com:8084/部件图/2026/6/PDS25400367-02/鞋身面.png"
/// FSourceinterID : 1236215
/// IncludesProcess : ["裁1"]
/// ComponentName : "鞋身面"
/// Componentno : "00001"
/// ProcessList : ["裁1","印刷","切刀","印线","批料","烫压","贴补强"]
/// MaterialList : [{"FInterID":58397657,"MaterialID":388259,"MaterialNo":"04110218788","MaterialName":"通用(2.5丝）1公斤/28米PE纸","FModel":"","ChineseUnit":"米","EnglishUnit":"M","Ingredients":5.040,"FDenominator":0.040},{"FInterID":58397657,"MaterialID":854036,"MaterialNo":"011000312","MaterialName":"1.3mm*1.35m 白色 JH448(AL149)纹太空革PU（可再生）","FModel":"","ChineseUnit":"米","EnglishUnit":"M","Ingredients":10.206,"FDenominator":0.081}]

class ComponentList {
  ComponentList({
      this.fInterID, 
      this.fItemID, 
      this.fPictureUrl, 
      this.fSourceinterID, 
      this.includesProcess, 
      this.componentName, 
      this.componentno, 
      this.processList, 
      this.materialList,});

  ComponentList.fromJson(dynamic json) {
    fInterID = json['FInterID'];
    fItemID = json['FItemID'];
    fPictureUrl = json['FPictureUrl'];
    fSourceinterID = json['FSourceinterID'];
    includesProcess = json['IncludesProcess'] != null ? json['IncludesProcess'].cast<String>() : [];
    componentName = json['ComponentName'];
    componentno = json['Componentno'];
    processList = json['ProcessList'] != null ? json['ProcessList'].cast<String>() : [];
    if (json['MaterialList'] != null) {
      materialList = [];
      json['MaterialList'].forEach((v) {
        materialList?.add(MaterialList.fromJson(v));
      });
    }
  }
  int? fInterID;
  int? fItemID;
  String? fPictureUrl;
  int? fSourceinterID;
  List<String>? includesProcess;
  String? componentName;
  String? componentno;
  List<String>? processList;
  List<MaterialList>? materialList;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['FInterID'] = fInterID;
    map['FItemID'] = fItemID;
    map['FPictureUrl'] = fPictureUrl;
    map['FSourceinterID'] = fSourceinterID;
    map['IncludesProcess'] = includesProcess;
    map['ComponentName'] = componentName;
    map['Componentno'] = componentno;
    map['ProcessList'] = processList;
    if (materialList != null) {
      map['MaterialList'] = materialList?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// FInterID : 58397657
/// MaterialID : 388259
/// MaterialNo : "04110218788"
/// MaterialName : "通用(2.5丝）1公斤/28米PE纸"
/// FModel : ""
/// ChineseUnit : "米"
/// EnglishUnit : "M"
/// Ingredients : 5.040
/// FDenominator : 0.040

class MaterialList {
  MaterialList({
      this.fInterID, 
      this.materialID, 
      this.materialNo, 
      this.materialName, 
      this.fModel, 
      this.chineseUnit, 
      this.englishUnit, 
      this.ingredients, 
      this.fDenominator,});

  MaterialList.fromJson(dynamic json) {
    fInterID = json['FInterID'];
    materialID = json['MaterialID'];
    materialNo = json['MaterialNo'];
    materialName = json['MaterialName'];
    fModel = json['FModel'];
    chineseUnit = json['ChineseUnit'];
    englishUnit = json['EnglishUnit'];
    ingredients = json['Ingredients'];
    fDenominator = json['FDenominator'];
  }
  int? fInterID;
  int? materialID;
  String? materialNo;
  String? materialName;
  String? fModel;
  String? chineseUnit;
  String? englishUnit;
  double? ingredients;
  double? fDenominator;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['FInterID'] = fInterID;
    map['MaterialID'] = materialID;
    map['MaterialNo'] = materialNo;
    map['MaterialName'] = materialName;
    map['FModel'] = fModel;
    map['ChineseUnit'] = chineseUnit;
    map['EnglishUnit'] = englishUnit;
    map['Ingredients'] = ingredients;
    map['FDenominator'] = fDenominator;
    return map;
  }

}

/// ProcessNumber : "GXPG260397253"
/// FactoryName : "PT.Gold Emperor Indonesia"
/// FDate : "2026-06-30T00:00:00"
/// WorkshopName : "IDN. Workshop 2 Cutting Line 1"
/// DepartName : "IDN. Workshop 2 Cutting Line 1"
/// ProcessRoute : null
/// ProductNumber : "PDS25400367-02"
/// ProductName : "PDS25400367-02"
/// TotalQty : 0
/// Packag : "单码装: 100 pr/pc"
/// FCardNo : "GXPG260397253/1"

class ProcessWorkCardInfo {
  ProcessWorkCardInfo({
      this.processNumber, 
      this.factoryName, 
      this.fDate, 
      this.workshopName, 
      this.departName, 
      this.productNumber,
      this.productName, 
      this.totalQty, 
      this.packag, 
      this.fCardNo,
      this.interID,
      this.allocationStatus,
      this.reportStatus,
  });

  ProcessWorkCardInfo.fromJson(dynamic json) {
    reportStatus = json['ReportStatus'];
    allocationStatus = json['AllocationStatus'];
    processNumber = json['ProcessNumber'];
    factoryName = json['FactoryName'];
    fDate = json['FDate'];
    workshopName = json['WorkshopName'];
    departName = json['DepartName'];
    productNumber = json['ProductNumber'];
    productName = json['ProductName'];
    totalQty = json['TotalQty'];
    packag = json['Packag'];
    fCardNo = json['FCardNo'];
    interID = json['InterID'];
  }
  int? reportStatus; //0未汇报  1已汇报
  int? allocationStatus; //0未分配  1已分配
  String? processNumber;
  String? factoryName;
  String? fDate;
  String? workshopName;
  String? departName;
  String? productNumber;
  String? productName;
  int? totalQty;
  String? packag;
  String? fCardNo;
  int? interID;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['AllocationStatus'] = allocationStatus;
    map['ProcessNumber'] = processNumber;
    map['FactoryName'] = factoryName;
    map['FDate'] = fDate;
    map['WorkshopName'] = workshopName;
    map['DepartName'] = departName;
    map['ProductNumber'] = productNumber;
    map['ProductName'] = productName;
    map['TotalQty'] = totalQty;
    map['Packag'] = packag;
    map['FCardNo'] = fCardNo;
    map['InterID'] = interID;
    return map;
  }

}