import 'package:flutter/cupertino.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:jd_flutter/fun/management/quality_management/quality_management_state.dart';
import 'package:jd_flutter/web_api.dart';

import '../../../route.dart';
import '../../../widget/picker/picker_controller.dart';

class QualityManagementLogic extends GetxController {
  final QualityManagementState state = QualityManagementState();

  ///日期选择器的控制器
  var pcStartDate = DatePickerController(
    PickerType.startDate,
    saveKey: '${RouteConfig.qualityRestrictionPage.name}${PickerType.startDate}',
  );

  ///日期选择器的控制器
  var pcEndDate = DatePickerController(
    PickerType.endDate,
    saveKey: '${RouteConfig.qualityRestrictionPage.name}${PickerType.endDate}',
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

  printNumber(){
     logger.f('轻微：${state.slight.value}');
  }
}