import 'dart:typed_data';

import 'package:jd_flutter/utils/utils.dart';

// InterID : 26825
// DecrementNumber : "D0002560"
// DispatchNumber : "000000079839"
// MaterialNumber : "06200400783"
// MaterialName : "XD13536-2D"
// Shift : "白班"

class MachineDispatchInfo {
  MachineDispatchInfo({
    this.interID,
    this.decrementNumber,
    this.dispatchNumber,
    this.materialNumber,
    this.materialName,
    this.shift,
  });

  MachineDispatchInfo.fromJson(dynamic json) {
    interID = json['InterID'];
    decrementNumber = json['DecrementNumber'];
    dispatchNumber = json['DispatchNumber'];
    materialNumber = json['MaterialNumber'];
    materialName = json['MaterialName'];
    shift = json['Shift'];
  }

  int? interID;
  String? decrementNumber; //递减表号
  String? dispatchNumber; //派工单号
  String? materialNumber; //物料编码
  String? materialName; //物料名称
  String? shift; //Shift

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['InterID'] = interID;
    map['DecrementNumber'] = decrementNumber;
    map['DispatchNumber'] = dispatchNumber;
    map['MaterialNumber'] = materialNumber;
    map['MaterialName'] = materialName;
    map['Shift'] = shift;
    return map;
  }
}

// InterID : 26826
// DecrementNumber : "D0002535"
// StartDate : "2024-07-26"
// DispatchNumber : "000000079758"
// StubBar1 : "460500007"
// StubBar2 : ""
// StubBar3 : "460401268"
// StubBarName1 : "新_回收料头(轻质)"
// StubBarName2 : ""
// StubBarName3 : "拌料半成品DX212980--TPR-轻质黑色+车线-有喷漆-60-62"
// StubBar1PrintFlag : 0
// StubBar2PrintFlag : 0
// StubBar3PrintFlag : 0
// MaterialNumber : "06200401209"
// MaterialName : "注塑半成品DX212980--TPR-轻质黑色+车线-有喷漆-60-62"
// FactoryType : "DX212980-5A"
// Machine : "JT23"
// DecreasingMachine : "JT17"
// Factory : "1500"
// Shift : "白班"
// Processflow : "ZHUS"
// Remarks : ""
// Withdrawal : " "
// Items : [{"EntryID":1,"Size":"3.5","SizeMaterialNumber":"0620040120902","SumQty":40.0,"SumUnderQty":40.0,"SumReportQty":0.0,"Mould":0.0,"TodayDispatchQty":0.0,"LastNotFullQty":0.0,"Capacity":35.0,"ReportQty":0.0,"NotFullQty":0.0,"BoxesQty":0.0,"ConfirmCurrentWorkingHours":"0.50000","WorkingHoursUnit":"H","BUoM":"双","MantissaMark":"","MantissaFlag":0,"LastMantissaFlag":0,"AvailableMouldsQty":1.0,"CapacityPerMold":200.0},{"EntryID":2,"Size":"4","SizeMaterialNumber":"0620040120903","SumQty":532.0,"SumUnderQty":0.0,"SumReportQty":532.0,"Mould":0.0,"TodayDispatchQty":0.0,"LastNotFullQty":0.0,"Capacity":35.0,"ReportQty":0.0,"NotFullQty":0.0,"BoxesQty":0.0,"ConfirmCurrentWorkingHours":"0.50000","WorkingHoursUnit":"H","BUoM":"双","MantissaMark":"X","MantissaFlag":0,"LastMantissaFlag":0,"AvailableMouldsQty":1.0,"CapacityPerMold":200.0},{"EntryID":3,"Size":"4.5","SizeMaterialNumber":"0620040120904","SumQty":1251.0,"SumUnderQty":849.0,"SumReportQty":402.0,"Mould":1.0,"TodayDispatchQty":200.0,"LastNotFullQty":16.0,"Capacity":35.0,"ReportQty":0.0,"NotFullQty":0.0,"BoxesQty":0.0,"ConfirmCurrentWorkingHours":"0.50000","WorkingHoursUnit":"H","BUoM":"双","MantissaMark":"","MantissaFlag":0,"LastMantissaFlag":0,"AvailableMouldsQty":1.0,"CapacityPerMold":200.0},{"EntryID":4,"Size":"5","SizeMaterialNumber":"0620040120905","SumQty":3264.0,"SumUnderQty":1090.0,"SumReportQty":2174.0,"Mould":1.0,"TodayDispatchQty":200.0,"LastNotFullQty":19.0,"Capacity":35.0,"ReportQty":0.0,"NotFullQty":0.0,"BoxesQty":0.0,"ConfirmCurrentWorkingHours":"0.50000","WorkingHoursUnit":"H","BUoM":"双","MantissaMark":"","MantissaFlag":0,"LastMantissaFlag":0,"AvailableMouldsQty":1.0,"CapacityPerMold":200.0},{"EntryID":5,"Size":"5.5","SizeMaterialNumber":"0620040120906","SumQty":3902.0,"SumUnderQty":1708.0,"SumReportQty":2194.0,"Mould":1.0,"TodayDispatchQty":200.0,"LastNotFullQty":30.0,"Capacity":35.0,"ReportQty":0.0,"NotFullQty":0.0,"BoxesQty":0.0,"ConfirmCurrentWorkingHours":"0.50000","WorkingHoursUnit":"H","BUoM":"双","MantissaMark":"","MantissaFlag":0,"LastMantissaFlag":0,"AvailableMouldsQty":1.0,"CapacityPerMold":200.0},{"EntryID":6,"Size":"6","SizeMaterialNumber":"0620040120907","SumQty":2815.0,"SumUnderQty":1005.0,"SumReportQty":1810.0,"Mould":0.0,"TodayDispatchQty":0.0,"LastNotFullQty":0.0,"Capacity":35.0,"ReportQty":0.0,"NotFullQty":0.0,"BoxesQty":0.0,"ConfirmCurrentWorkingHours":"0.50000","WorkingHoursUnit":"H","BUoM":"双","MantissaMark":"","MantissaFlag":0,"LastMantissaFlag":0,"AvailableMouldsQty":1.0,"CapacityPerMold":200.0},{"EntryID":7,"Size":"6.5","SizeMaterialNumber":"0620040120908","SumQty":2547.0,"SumUnderQty":394.0,"SumReportQty":2153.0,"Mould":1.0,"TodayDispatchQty":195.0,"LastNotFullQty":5.0,"Capacity":35.0,"ReportQty":0.0,"NotFullQty":0.0,"BoxesQty":0.0,"ConfirmCurrentWorkingHours":"0.50000","WorkingHoursUnit":"H","BUoM":"双","MantissaMark":"","MantissaFlag":0,"LastMantissaFlag":0,"AvailableMouldsQty":1.0,"CapacityPerMold":200.0},{"EntryID":8,"Size":"7","SizeMaterialNumber":"0620040120909","SumQty":2347.0,"SumUnderQty":521.0,"SumReportQty":1826.0,"Mould":1.0,"TodayDispatchQty":200.0,"LastNotFullQty":0.0,"Capacity":35.0,"ReportQty":0.0,"NotFullQty":0.0,"BoxesQty":0.0,"ConfirmCurrentWorkingHours":"0.50000","WorkingHoursUnit":"H","BUoM":"双","MantissaMark":"","MantissaFlag":0,"LastMantissaFlag":0,"AvailableMouldsQty":1.0,"CapacityPerMold":200.0},{"EntryID":9,"Size":"7.5","SizeMaterialNumber":"0620040120910","SumQty":696.0,"SumUnderQty":224.0,"SumReportQty":472.0,"Mould":0.0,"TodayDispatchQty":0.0,"LastNotFullQty":0.0,"Capacity":35.0,"ReportQty":0.0,"NotFullQty":0.0,"BoxesQty":0.0,"ConfirmCurrentWorkingHours":"0.50000","WorkingHoursUnit":"H","BUoM":"双","MantissaMark":"","MantissaFlag":0,"LastMantissaFlag":0,"AvailableMouldsQty":1.0,"CapacityPerMold":200.0},{"EntryID":10,"Size":"8","SizeMaterialNumber":"0620040120911","SumQty":324.0,"SumUnderQty":0.0,"SumReportQty":324.0,"Mould":0.0,"TodayDispatchQty":0.0,"LastNotFullQty":0.0,"Capacity":35.0,"ReportQty":0.0,"NotFullQty":0.0,"BoxesQty":0.0,"ConfirmCurrentWorkingHours":"0.50000","WorkingHoursUnit":"H","BUoM":"双","MantissaMark":"X","MantissaFlag":0,"LastMantissaFlag":0,"AvailableMouldsQty":1.0,"CapacityPerMold":200.0}]
// ProcessList : [{"FWorkingHoursUnit":"H","FWorkingHours":0.5,"ProcessNumber":"ZD1","ProcessName":"撬模1"},{"FWorkingHoursUnit":"H","FWorkingHours":0.5,"ProcessNumber":"ZD2","ProcessName":"撬模2"},{"FWorkingHoursUnit":"H","FWorkingHours":0.5,"ProcessNumber":"ZD3","ProcessName":"修边"}]
// Status : 0
// MoldNo : "DX212980"
// Weight : 400.0
// BarCodeList : []

class MachineDispatchDetailsInfo {
  MachineDispatchDetailsInfo({
    this.interID,
    this.decrementNumber,
    this.startDate,
    this.dispatchNumber,
    this.stubBar1,
    this.stubBar2,
    this.stubBar3,
    this.stubBarName1,
    this.stubBarName2,
    this.stubBarName3,
    this.stubBar1PrintFlag,
    this.stubBar2PrintFlag,
    this.stubBar3PrintFlag,
    this.materialNumber,
    this.materialName,
    this.factoryType,
    this.machine,
    this.decreasingMachine,
    this.factory,
    this.shift,
    this.processflow,
    this.remarks,
    this.withdrawal,
    this.items,
    this.processList,
    this.status,
    this.moldNo,
    this.weight,
    this.barCodeList,
  });

  MachineDispatchDetailsInfo.fromJson(dynamic json) {
    interID = json['InterID'];
    decrementNumber = json['DecrementNumber'];
    startDate = json['StartDate'];
    dispatchNumber = json['DispatchNumber'];
    stubBar1 = json['StubBar1'];
    stubBar2 = json['StubBar2'];
    stubBar3 = json['StubBar3'];
    stubBarName1 = json['StubBarName1'];
    stubBarName2 = json['StubBarName2'];
    stubBarName3 = json['StubBarName3'];
    stubBar1PrintFlag = json['StubBar1PrintFlag'];
    stubBar2PrintFlag = json['StubBar2PrintFlag'];
    stubBar3PrintFlag = json['StubBar3PrintFlag'];
    materialNumber = json['MaterialNumber'];
    materialName = json['MaterialName'];
    factoryType = json['FactoryType'];
    machine = json['Machine'];
    decreasingMachine = json['DecreasingMachine'];
    factory = json['Factory'];
    shift = json['Shift'];
    processflow = json['Processflow'];
    remarks = json['Remarks'];
    withdrawal = json['Withdrawal'];
    if (json['Items'] != null) {
      items = [];
      json['Items'].forEach((v) {
        items?.add(Items.fromJson(v));
      });
    }
    if (json['ProcessList'] != null) {
      processList = [];
      json['ProcessList'].forEach((v) {
        processList?.add(ProcessList.fromJson(v));
      });
    }
    status = json['Status'];
    moldNo = json['MoldNo'];
    weight = json['Weight'];
    if (json['BarCodeList'] != null) {
      barCodeList = [];
      json['BarCodeList'].forEach((v) {
        barCodeList?.add(v);
      });
    }
  }

  int? interID; //派工单InterID
  String? decrementNumber; //ZEDJBH 递减编号
  String? startDate; //ZDISPATCH_DATE 开工日期
  String? dispatchNumber; //ZDISPATCH_NO 派工单号
  String? stubBar1; //ZELT1 料头1
  String? stubBar2; //ZELT2 料头2
  String? stubBar3; //ZELT3 料头3     4604 不判断是否打印
  String? stubBarName1; //料头名称1
  String? stubBarName2; //料头名称2
  String? stubBarName3; //料头名称3
  int? stubBar1PrintFlag; //料头1打印
  int? stubBar2PrintFlag; //料头2打印
  int? stubBar3PrintFlag; //料头3打印
  String? materialNumber; //SATNR 物料号
  String? materialName; //物料名称
  String? factoryType; //ZZGCXT 型体
  String? machine; //ZEPGJT 机台
  String? decreasingMachine; //递减机台
  String? factory; //WERKS_D 工厂
  String? shift; //ZEBC 班次
  String? processflow; //ZKTSCH_PG 制程
  String? remarks; //ZBZ 备注
  String? withdrawal; //ZFLAG 撤回标识
  List<Items>? items;
  List<ProcessList>? processList;
  int? status; //状态：0.未汇报 1.已有产量汇报单,未生成员工 2.已有产量汇报单且已生成员工
  String? moldNo; //模具号
  double? weight; //单重
  List<String>? barCodeList;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['InterID'] = interID;
    map['DecrementNumber'] = decrementNumber;
    map['StartDate'] = startDate;
    map['DispatchNumber'] = dispatchNumber;
    map['StubBar1'] = stubBar1;
    map['StubBar2'] = stubBar2;
    map['StubBar3'] = stubBar3;
    map['StubBarName1'] = stubBarName1;
    map['StubBarName2'] = stubBarName2;
    map['StubBarName3'] = stubBarName3;
    map['StubBar1PrintFlag'] = stubBar1PrintFlag;
    map['StubBar2PrintFlag'] = stubBar2PrintFlag;
    map['StubBar3PrintFlag'] = stubBar3PrintFlag;
    map['MaterialNumber'] = materialNumber;
    map['MaterialName'] = materialName;
    map['FactoryType'] = factoryType;
    map['Machine'] = machine;
    map['DecreasingMachine'] = decreasingMachine;
    map['Factory'] = factory;
    map['Shift'] = shift;
    map['Processflow'] = processflow;
    map['Remarks'] = remarks;
    map['Withdrawal'] = withdrawal;
    if (items != null) {
      map['Items'] = items?.map((v) => v.toJson()).toList();
    }
    if (processList != null) {
      map['ProcessList'] = processList?.map((v) => v.toJson()).toList();
    }
    map['Status'] = status;
    map['MoldNo'] = moldNo;
    map['Weight'] = weight;
    if (barCodeList != null) {
      map['BarCodeList'] = barCodeList?.toList();
    }
    return map;
  }
}

// FWorkingHoursUnit : "H"
// FWorkingHours : 0.5
// ProcessNumber : "ZD1"
// ProcessName : "撬模1"

class ProcessList {
  ProcessList({
    this.workingHoursUnit,
    this.workingHours,
    this.processNumber,
    this.processName,
  });

  ProcessList.fromJson(dynamic json) {
    workingHoursUnit = json['FWorkingHoursUnit'];
    workingHours = json['FWorkingHours'];
    processNumber = json['ProcessNumber'];
    processName = json['ProcessName'];
  }

  String? workingHoursUnit;
  double? workingHours;
  String? processNumber; //工序ID
  String? processName; //工序名称

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['FWorkingHoursUnit'] = workingHoursUnit;
    map['FWorkingHours'] = workingHours;
    map['ProcessNumber'] = processNumber;
    map['ProcessName'] = processName;
    return map;
  }
}

// EntryID : 1
// Size : "3.5"
// SizeMaterialNumber : "0620040120902"
// SumQty : 40.0
// SumUnderQty : 40.0
// SumReportQty : 0.0
// Mould : 0.0
// TodayDispatchQty : 0.0
// LastNotFullQty : 0.0
// Capacity : 35.0
// ReportQty : 0.0
// NotFullQty : 0.0
// BoxesQty : 0.0
// ConfirmCurrentWorkingHours : "0.50000"
// WorkingHoursUnit : "H"
// BUoM : "双"
// MantissaMark : ""
// MantissaFlag : 0
// LastMantissaFlag : 0
// AvailableMouldsQty : 1.0
// CapacityPerMold : 200.0

class Items {
  Items({
    this.entryID,
    this.size,
    this.sizeMaterialNumber,
    this.sumQty,
    this.sumUnderQty,
    this.sumReportQty,
    this.mould,
    this.todayDispatchQty,
    this.lastNotFullQty,
    this.capacity,
    this.reportQty,
    this.notFullQty,
    this.boxesQty,
    this.confirmCurrentWorkingHours,
    this.workingHoursUnit,
    this.bUoM,
    this.mantissaMark,
    this.mantissaFlag,
    this.lastMantissaFlag,
    this.availableMouldsQty,
    this.capacityPerMold,
  });

  Items.fromJson(dynamic json) {
    entryID = json['EntryID'];
    size = json['Size'];
    sizeMaterialNumber = json['SizeMaterialNumber'];
    sumQty = json['SumQty'];
    sumUnderQty = json['SumUnderQty'];
    sumReportQty = json['SumReportQty'];
    mould = json['Mould'];
    todayDispatchQty = json['TodayDispatchQty'];
    lastNotFullQty = json['LastNotFullQty'];
    capacity = json['Capacity'];
    reportQty = json['ReportQty'];
    notFullQty = json['NotFullQty'];
    boxesQty = json['BoxesQty'];
    confirmCurrentWorkingHours = json['ConfirmCurrentWorkingHours'];
    workingHoursUnit = json['WorkingHoursUnit'];
    bUoM = json['BUoM'];
    mantissaMark = json['MantissaMark'];
    mantissaFlag = json['MantissaFlag'];
    lastMantissaFlag = json['LastMantissaFlag'];
    availableMouldsQty = json['AvailableMouldsQty'];
    capacityPerMold = json['CapacityPerMold'];
  }

  int? entryID;
  String? size; //尺码
  String? sizeMaterialNumber; //尺码物料号
  double? sumQty; //总数量
  double? sumUnderQty; //欠数汇总
  double? sumReportQty; //累计报工
  double? mould; //模具
  double? todayDispatchQty; //当日派工数量
  double? lastNotFullQty; //上一班未满箱数量
  double? capacity; //箱容
  double? reportQty;
  double? notFullQty; //当班未满箱数量
  double? boxesQty; //箱数
  String? confirmCurrentWorkingHours; //工时
  String? workingHoursUnit; //工时单位
  String? bUoM; //基本计量单位
  String? mantissaMark; //尾数标识  X是尾数标识
  int? mantissaFlag;
  int? lastMantissaFlag; //尾数标识
  double? availableMouldsQty; //可用模具数
  double? capacityPerMold; //产能每模

  int labelQty = 0;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['EntryID'] = entryID;
    map['Size'] = size;
    map['SizeMaterialNumber'] = sizeMaterialNumber;
    map['SumQty'] = sumQty;
    map['SumUnderQty'] = sumUnderQty;
    map['SumReportQty'] = sumReportQty;
    map['Mould'] = mould;
    map['TodayDispatchQty'] = todayDispatchQty;
    map['LastNotFullQty'] = lastNotFullQty;
    map['Capacity'] = capacity;
    map['ReportQty'] = reportQty;
    map['NotFullQty'] = notFullQty;
    map['BoxesQty'] = boxesQty;
    map['ConfirmCurrentWorkingHours'] = confirmCurrentWorkingHours;
    map['WorkingHoursUnit'] = workingHoursUnit;
    map['BUoM'] = bUoM;
    map['MantissaMark'] = mantissaMark;
    map['MantissaFlag'] = mantissaFlag;
    map['LastMantissaFlag'] = lastMantissaFlag;
    map['AvailableMouldsQty'] = availableMouldsQty;
    map['CapacityPerMold'] = capacityPerMold;
    return map;
  }

  double getTodayDispatchQty() {
    var tdQty = 0.0;
    if (mantissaMark == 'X') {
      tdQty = sumUnderQty ?? 0.0;
    } else {
      if (todayDispatchQty == 0) {
        if ((lastNotFullQty ?? 0.0) > 0) {
          var qty = capacity.sub(lastNotFullQty ?? 0.0);
          if (qty < (sumUnderQty ?? 0.0) && qty >= 0) {
            tdQty = qty;
          } else {
            tdQty = sumUnderQty ?? 0.0;
          }
        }
      } else {
        tdQty = todayDispatchQty ?? 0.0;
      }
    }
    return tdQty;
  }

  double getReportQty() {
    return boxesQty
        .mul(capacity ?? 0)
        .add(notFullQty ?? 0)
        .sub(lastNotFullQty ?? 0);
  }
}

class DispatchProcessInfo {
  var processNumber = ''; //工序ID
  var processName = ''; //工序名称
  var totalProduction = 0.0; //工序总产量
  var dispatchList = <DispatchInfo>[];

  DispatchProcessInfo(
    this.processNumber,
    this.processName,
    this.totalProduction,
  );

  double getSurplus() {
    return totalProduction.sub(
      dispatchList.isEmpty
          ? 0
          : dispatchList
              .map((v) => v.dispatchQty ?? 0)
              .reduce((v1, v2) => v1.add(v2)),
    );
  }
}

class DispatchInfo {
  int? workerEmpID; //员工impID
  String? workerNumber; //员工ID
  String? workerName; //员工姓名
  String? workerAvatar; //员工照片
  double? dispatchQty; //个人产量
  ByteData? signature;

  DispatchInfo({
    required this.workerEmpID,
    required this.workerNumber,
    required this.workerName,
    required this.workerAvatar,
    required this.dispatchQty,
    required this.signature,
  }); //签名
}
