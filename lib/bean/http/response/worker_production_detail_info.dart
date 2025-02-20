abstract class WorkerProductionDetail {
  int? level;
  int? empID;
  String? empNumber;
  double? qty;
  double? amount;
}

class WorkerProductionDetailShow {
  late String title;
  late WorkerProductionDetail head;
  late List<WorkerProductionDetail> body;
  WorkerProductionDetailShow(this.title,this.head,this.body);
}

// Flevel : 2
// FEmpID : 139660
// FEmpNumber : "080121"
// FInterID : 0
// FBillNO : "单号"
// FBillDate : null
// FOrganizeName : "报产量组织"
// FDeptName : "报产量组别"
// FScmoNO : "派工单号"
// FProcessFlowName : "制程"
// FItemNo : "货号"
// FProcessNumber : "工序编号"
// FProcessName : "工序名称"
// FQty : 0.000
// FPrice : 0.00000
// FAmount : 0.0000
// FSmallBillSubsidyPCT : 0.00
// FSmallBillSubsidy : 0.00
// FamountSum : 0.0000

class WorkerProductionDetailType1 extends WorkerProductionDetail {
  WorkerProductionDetailType1.fromJson(dynamic json) {
    level = json['Flevel'];
    empID = json['FEmpID'];
    empNumber = json['FEmpNumber'];
    interID = json['FInterID'];
    billNO = json['FBillNO'];
    billDate = json['FBillDate'];
    organizeName = json['FOrganizeName'];
    deptName = json['FDeptName'];
    dispatchNO = json['FScmoNO'];
    processFlowName = json['FProcessFlowName'];
    itemNo = json['FItemNo'];
    processNumber = json['FProcessNumber'];
    processName = json['FProcessName'];
    qty = json['FQty'];
    price = json['FPrice'];
    amount = json['FAmount'];
    smallBillSubsidyPCT = json['FSmallBillSubsidyPCT'];
    smallBillSubsidy = json['FSmallBillSubsidy'];
    amountSum = json['FamountSum'];
  }

  int? interID;
  String? billNO;
  String? billDate;
  String? organizeName;
  String? deptName;
  String? dispatchNO;
  String? processFlowName;
  String? itemNo;
  String? processNumber;
  String? processName;
  double? price;
  double? smallBillSubsidyPCT;
  double? smallBillSubsidy;
  double? amountSum;
}

// Flevel : 4
// FEmpID : 87929
// FEmpNumber : "000973"
// FItemNo : "合计"
// FProcessNumber : null
// FProcessName : null
// FQty : 5684.000
// FPrice : null
// FAmount : 103.0659
// FSmallBillSubsidyPCT : null
// FSmallBillSubsidy : 0.00
// FAmountSum : 103.0659

class WorkerProductionDetailType2 extends WorkerProductionDetail {
  WorkerProductionDetailType2.fromJson(dynamic json) {
    level = json['Flevel'];
    empID = json['FEmpID'];
    empNumber = json['FEmpNumber'];
    itemNo = json['FItemNo'];
    processNumber = json['FProcessNumber'];
    processName = json['FProcessName'];
    qty = json['FQty'];
    price = json['FPrice'];
    amount = json['FAmount'];
    smallBillSubsidyPCT = json['FSmallBillSubsidyPCT'];
    smallBillSubsidy = json['FSmallBillSubsidy'];
    amountSum = json['FAmountSum'];
  }

  String? itemNo;
  String? processNumber;
  String? processName;
  double? price;
  double? smallBillSubsidyPCT;
  double? smallBillSubsidy;
  double? amountSum;
}

// Flevel : 2
// FEmpID : 87929
// FDate : "日期"
// FEmpNumber : "工号"
// FEmpName : "姓名"
// FQty : 0.000
// FAmount : 0.0000

class WorkerProductionDetailType3 extends WorkerProductionDetail {
  WorkerProductionDetailType3.fromJson(dynamic json) {
    level = json['Flevel'];
    empID = json['FEmpID'];
    date = json['FDate'];
    empNumber = json['FEmpNumber'];
    empName = json['FEmpName'];
    qty = json['FQty'];
    amount = json['FAmount'];
  }

  String? date;
  String? empName;
}
