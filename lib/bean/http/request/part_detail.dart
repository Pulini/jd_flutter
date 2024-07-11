class PartDetailQuery {
  String workCardBarCode;
  List<String> partNames;
  int deptID;

  PartDetailQuery({
    required this.workCardBarCode,
    required this.partNames,
    required this.deptID,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['WorkCardBarCode'] = workCardBarCode;
    map['PartNames'] = partNames.toList();
    map['DeptID'] = deptID;
    return map;
  }
}

class PartDetailCreate {
  double boxCapacity;
  List<int> fID;
  double qty;
  String size;
  int userID;
  List<String> partNames;
  int deptID;
  String empID;

  PartDetailCreate({
    required this.boxCapacity,
    required this.fID,
    required this.qty,
    required this.size,
    required this.userID,
    required this.partNames,
    required this.deptID,
    required this.empID,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['BoxCapacity'] = boxCapacity;
    map['FID'] = fID;
    map['Qty'] = qty;
    map['Size'] = size;
    map['UserID'] = userID;
    map['PartNames'] = partNames;
    map['DeptID'] = deptID;
    map['EmpID'] = empID;
    return map;
  }
}
