
class ShowHandoverReportList {
  ShowHandoverReportList({
    this.interID,
    this.entryID,
    this.dispatchNumber,
    this.machine,
    this.factoryType,
    this.status,
    this.processName,
    this.empName,
    this.shift,
    this.changeColor,
    this.select,
    this.subList,
  });


  int? interID;  //主键ID
  int? entryID;
  String? dispatchNumber;  //派工单号
  String? machine;  //机台号
  String? factoryType;  //型体
  bool? status;  //状态 true.已上传到SAP false 未上传到SAP
  String? processName;  //工序名称
  double? processQty;  //工序数量
  String? empName;  //员工名字
  String? shift;  //班次
  bool? changeColor; // 提示
  bool? select; // 选中状态
  List<SubList>? subList;  //中间内容

}

class SubList {
  SubList({
    this.subSize,
    this.subCapacity,
    this.subLastMantissa,
    this.subMantissa,
    this.subBox,
    this.subQty,
    this.subDispatchNum,

  });

  String? subSize;  //尺码
  double? subCapacity;  //箱容
  double? subLastMantissa;  //上班尾数
  double? subMantissa;  //当班尾数
  double? subBox;  //箱数
  double? subQty;  //单码小计
  double? subDispatchNum;  //派工数量
}




