import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class LabelForWorkCardInfo {
  LabelForWorkCardInfo({
      this.processWorkCardInfo, 
      this.componentList, 
      this.employeeList,
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
    this.fMtono,
    this.fRouteEntryFID,
    this.fItemID,
    this.fProcessName,
    this.empNumber,
    this.empName,

  }) {
    _initUiState();
  }

  SizeList.fromJson(dynamic json) {
    empName = json['EmpName'];
    empNumber = json['empNumber'];
    fProcessName = json['FProcessName'];
    fItemID = json['FItemID'];
    fMtono = json['FMtono'];
    size = json['Size'];
    totalQty = json['TotalQty'];
    empID = json['EmpID'];
    empNumber = json['EmpNumber'];
    empName = json['EmpName'];
    allocatedQty = json['AllocatedQty'];
    fPrdMoID = json['FPrdMoID'];
    fRouteEntryFID = json['FRouteEntryFID'];
    _initUiState();
  }
  String? empName;
  String? empNumber;
  String? fMtono;
  String? size;
  int? fItemID;
  String? fProcessName;
  double? totalQty;
  int? empID;
  int? allocatedQty;
  int? fPrdMoID;
  int? fRouteEntryFID; //工序id
  // 已分配工单(allocationStatus==1 ⟺ isAllocated 【概念1：工单级】)：isScanTotal 锁定为历史已分配量 allocatedQty，
  // 未分配时为 0。用 getter 实现「取 allocatedQty 且不可被改变」——没有 setter，外部无法赋值。
  // 注意：isScanTotal 取的是「工单级」已派量（概念1），不是「本行是否已派」(概念2/qtyAllocated)。
  int get isScanTotal => isAllocated ? (allocatedQty ?? 0) : 0;

  // —— 交互 / UI 状态（非接口字段，不参与 toJson）——
  var operatorNo = ''.obs; // 纯工号（输入框只显示工号，姓名由「员工」列单独展示）
  var operatorName = ''.obs; // 接口按工号查回的员工姓名（未命中花名册时用于「员工」列展示）
  var currentQty = ''.obs; // 本次分配数量（输入框）
  var isMatched = false.obs; // 是否匹配到员工
  final operatorController = TextEditingController();
  final qtyController = TextEditingController();

  // —— 概念1：工单是否已分配（WORK-ORDER level）——
  // 取自 ProcessWorkCardInfo.allocationStatus == 1，整张工单一个布尔，所有行共享。
  // 它只决定「本次可分配上限 cap」的取值（见 allocCap / isScanTotal）：
  //   已分配 → cap = isScanTotal(=历史 allocatedQty)；未分配 → cap = totalQty。
  // 注意：它是「工单级」概念，不要把它当成「这一行数量已派」(概念2) 来用——
  // 一张已分配工单里刚复制出来的新行，逻辑上「行数量未派」(概念2=false)，
  // 但仍应继承本标记的 true（因为它同属这张已分配工单，cap 仍是 isScanTotal）。
  bool isAllocated = false;

  // —— 概念2：本行数量是否已分配（ROW level）——
  // 与「工单是否分配」(isAllocated) 是两个独立概念：isAllocated 是整单一个布尔，
  // 本 getter 看「这一行自己的历史已派量 allocatedQty 是否 > 0」，逐行独立。
  // 用途举例（当前未接入任何行为，仅澄清模型）：判断某行是否为历史已派行、是否需锁定等。
  // 与 isAllocated 可能不一致：工单 status==1 但某尺码 allocatedQty==0 时，
  // isAllocated=true 而 qtyAllocated=false。
  bool get qtyAllocated => (allocatedQty ?? 0) > 0;

  // 本次可分配上限（max 基准）= 该「指令+尺码」组合的「可分配总量」。
  // 刻意使用【概念1：工单级】标记 isAllocated 决定上限取值（非概念2 行级 qtyAllocated）：
  //  - 未分配(status!=1)：上限 = 总数量 totalQty。
  //  - 已分配(status==1 ⟺ isAllocated)：上限 = isScanTotal（= 历史已分配量 allocatedQty），
  //    即「能有个值来决定好上限」：已分配工单以历史已分配量为盘子重新分配，
  //    不回退到 totalQty，避免把历史已分配量当新上限导致逻辑错乱。
  //  实际可填量由「剩余未分配 = 上限 - 已填数量」动态求解（见 logic.rowMaxQty / groupRemainingQty）。
  //  isScanTotal 为只读 getter，不会在别处被改写，故上限不会漂移到非预期值。
  int get allocCap => isAllocated ? isScanTotal : (totalQty?.toInt() ?? 0);

  // 剩余未分配 = 上限 - 本次分配
  int get remainingQty => allocCap - (int.tryParse(currentQty.value) ?? 0);

  // 把「本次分配」重设为回显默认值：
  //  - 已分配过 → 接口历史已分配量 allocatedQty（保留历史数据，不覆盖）
  //  - 未分配   → 总数量 totalQty
  // 注意与「上限 allocCap」解耦：上限已统一为 totalQty，此处仅决定首次加载默认值，
  // 不参与上限计算，避免改动已分配场景的回显数据。
  void fillQtyByTotal() {
    final cap = isAllocated
        ? (allocatedQty ?? 0)
        : (totalQty?.toInt() ?? 0);
    currentQty.value = cap.toString();
    qtyController.text = currentQty.value;
  }

  // 重置：清空工号，本次分配回到默认值（= 总数量）
  void reset() {
    operatorNo.value = '';
    operatorName.value = '';
    isMatched.value = false;
    operatorController.clear();
    fillQtyByTotal();
  }

  void _initUiState() {
    fillQtyByTotal();
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['EmpName'] = empName;
    map['EmpNumber'] = empNumber;
    map['FProcessName'] = fProcessName;
    map['FItemID'] = fItemID;
    map['FMtono'] = fMtono;
    map['Size'] = size;
    map['TotalQty'] = totalQty;
    map['EmpID'] = empID;
    map['AllocatedQty'] = allocatedQty;
    map['FPrdMoID'] = fPrdMoID;
    map['FRouteEntryFID'] = fRouteEntryFID;
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
      this.materialList,
      this.sizeList,
  });

  ComponentList.fromJson(dynamic json) {
    if (json['SizeList'] != null) {
      sizeList = [];
      json['SizeList'].forEach((v) {
        sizeList?.add(SizeList.fromJson(v));
      });
    }
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
  List<SizeList>? sizeList;

  // 该部件的尺码分配明细是否已经「首次加载并初始化」过。
  // 用于 loadSizeAllocation：首次加载时从接口回显工号/默认数量，
  // 之后切换部件再切回来，保留用户在面板里填的工号/数量，不再重置。
  bool allocationLoaded = false;

  // 该部件是否已「全部分配完」：sizeList 非空且每一行 allocatedQty >= totalQty
  bool get isFullyAllocated {
    final list = sizeList;
    if (list == null || list.isEmpty) return false;
    for (var e in list) {
      final total = e.totalQty ?? 0;
      final allocated = e.allocatedQty ?? 0;
      if (total <= 0 || allocated < total) return false;
    }
    return true;
  }

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
    if (sizeList != null) {
      map['SizeList'] = sizeList?.map((v) => v.toJson()).toList();
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
      this.fBatchNo,
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
    fBatchNo = json['FBatchNo'];
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
  String? fBatchNo;
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
    map['FBatchNo'] = fBatchNo;
    map['InterID'] = interID;
    return map;
  }

}