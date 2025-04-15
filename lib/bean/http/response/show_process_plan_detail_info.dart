
import 'package:jd_flutter/utils/utils.dart';

class ShowProcessPlanDetailInfo {
  ShowProcessPlanDetailInfo({
    this.interID,
    this.entryID,
    this.dispatchNumber,
    this.machine,
    this.factoryType,
    this.size,
    this.lastMantissa,
    this.mantissa,
    this.allQty,
    this.box,
    this.maxBox =0,
    this.capacity,
    this.processFlow,
    this.bUoM,
    this.confirmCurrentWorkingHours,
    this.workingHoursUnit,

  });


  int? interID;    //主键ID
  int? entryID;
  String? dispatchNumber;      //派工单号
  String? machine;  //机台
  String? factoryType;  //型体
  String? size;  //尺码
  double? lastMantissa;  //上班尾数
  double? mantissa;  //当班尾数
  double? allQty;  //单码小计
  int? box;  //箱数
  int maxBox=0;  //最大箱数
  double? capacity;  //箱容
  String? processFlow;  //制程
  String? bUoM;  //基本计量单位
  String? confirmCurrentWorkingHours;  //确认当前工时
  String? workingHoursUnit;  //工时单位

  double subtotal() => (box ?? 0)*(capacity?? 0).add(mantissa?? 0.0).sub(lastMantissa?? 0.0);

}




