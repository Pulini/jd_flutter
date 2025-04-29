import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/handover_detail_info.dart';
import 'package:jd_flutter/bean/http/response/show_handover_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/utils.dart';

class ComponentHandoverState {
  var dataList = <ShowHandoverInfo>[].obs; //条码数组
  var summaryDataList = <SummaryList>[].obs; //条码数组
  var empName = ''.obs; //员工名字
  var departmentId = ''; //交接员工的部门id
  var empId = ''; //员工EmpId
  var empCode = ''; //员工EmpId

  var process = spGet(spSaveComponentHandoverProcessName) ?? ''.obs; //制程
  var processId = spGet(spSaveComponentHandoverProcessID) ?? 0; //制程ID
  var typeBody = ''.obs; //型体
  var outPart= ''.obs; //转出部件
  var outProcess= ''.obs; //转出工序
  var upDepartmentToDown= ''.obs; //转出部门到转入部门
  var handoverDetail = HandoverDetailInfo();
}
