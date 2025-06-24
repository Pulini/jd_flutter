import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:jd_flutter/fun/management/quality_management/quality_management_state.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';

class QualityManagementLogic extends GetxController {
  final QualityManagementState state = QualityManagementState();


  //部门选择器的控制器
  var pickerControllerDepartment = OptionsPickerController(
    PickerType.mesDepartment,
    saveKey: '${RouteConfig.dailyReport.name}${PickerType.mesDepartment}',
  );

}