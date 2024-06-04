import 'package:jd_flutter/utils.dart';

class DispatchInfo {
  bool select;
  bool resigned;
  String processName;
  String processNumber;
  String number;
  String name;
  int empID;
  double qty;
  double finishQty;
  double dispatchQty;

  DispatchInfo({
    this.select = false,
    this.resigned = false,
    this.processName = '',
    this.processNumber = '',
    this.number = '',
    this.name = '',
    this.empID = 0,
    this.qty = 0.0,
    this.finishQty = 0.0,
    this.dispatchQty = 0.0,
  });

  String getName() => '<$number>$name';

  String getQty() => qty.toShowString();
}
