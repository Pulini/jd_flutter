import 'package:get/get.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';

import 'daily_report_state.dart';

class DailyReportLogic extends GetxController {
  final DailyReportState state = DailyReportState();

  ///部门选择器的控制器
  var pickerControllerDepartment = OptionsPickerController(
    PickerType.mesDepartment,
    saveKey: '${RouteConfig.dailyReport.name}${PickerType.mesDepartment}',
  );

  ///日期选择器的控制器
  late DatePickerController pickerControllerDate = DatePickerController(
    PickerType.date,
    saveKey: '${RouteConfig.dailyReport.name}${PickerType.date}',
  );
  ///获取扫码日产量接口
  query() {
    state.getDayOutput(
      departmentID: pickerControllerDepartment.selectedId.value,
      date: pickerControllerDate.getDateFormatYMD(),
      success: () => Get.back(),
      error: (msg) => errorDialog(content: msg),
    );
  }
}
