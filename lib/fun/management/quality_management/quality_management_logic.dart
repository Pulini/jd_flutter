import 'package:flutter/cupertino.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:jd_flutter/fun/management/quality_management/quality_management_state.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';

class QualityManagementLogic extends GetxController {
  final QualityManagementState state = QualityManagementState();

  ///部门选择器的控制器
  var pickerControllerDepartment = OptionsPickerController(
    PickerType.mesDepartment,
    saveKey: '${RouteConfig.qualityRestriction.name}${PickerType.mesDepartment}',
  );

  ///日期选择器的控制器
  var pcStartDate = DatePickerController(
    PickerType.startDate,
    saveKey: '${RouteConfig.qualityRestriction.name}${PickerType.startDate}',
  );

  ///日期选择器的控制器
  var pcEndDate = DatePickerController(
    PickerType.endDate,
    saveKey: '${RouteConfig.qualityRestriction.name}${PickerType.endDate}',
  );


  var textNumber = TextEditingController(); //异常数量
  var textPersonal = TextEditingController(); //测试人员

   addOrReduceNumber(bool isAdd){
    if(isAdd){
      state.number.value = (int.parse(state.number.value)+1).toString();
    }else{
      if(int.parse(state.number.value)>1){
        state.number.value = (int.parse(state.number.value)-1).toString();
      }else{
        state.number.value ="1";
      }
    }
  }


}