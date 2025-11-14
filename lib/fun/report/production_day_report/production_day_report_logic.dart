import 'package:get/get.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/spinner_widget.dart';

import 'production_day_report_state.dart';

class ProductionDayReportLogic extends GetxController {
  final ProductionDayReportState state = ProductionDayReportState();

  //日期选择器的控制器
  late DatePickerController pickerControllerDate = DatePickerController(
    PickerType.date,
    saveKey: '${RouteConfig.productionDayReport.name}${PickerType.date}',
    firstDate: state.lastWeek,
    lastDate: state.today,
    onChanged: (index) => query(),
  );

  //下拉选择器的控制器
  late SpinnerController spinnerControllerWorkShop = SpinnerController(
    saveKey: RouteConfig.productionDayReport.name,
    dataList: [
      'spinner_work_shop_hint1'.tr,
      'spinner_work_shop_hint2'.tr,
      'spinner_work_shop_hint3'.tr,
      'spinner_work_shop_hint4'.tr,
      'spinner_work_shop_hint5'.tr
    ],
    onChanged: (index) => query(),
  );
  late DatePickerController reasonDateController = DatePickerController(
    PickerType.date,
    firstDate: state.yesterday,
    lastDate: state.today,
  );

  //获取产量汇总表接口
  void query() {
    state.getPrdDayReport(
      date: pickerControllerDate.getDateFormatYMD(),
      workShopID: spinnerControllerWorkShop.selectIndex + 1,
      success: (msg) => Get.back(closeOverlays: true),
      error: (msg) => errorDialog(content: msg),
    );
  }

  bool checkDate() {
    var now = DateTime.now();
    if (pickerControllerDate.pickDate.value.year == now.year &&
        pickerControllerDate.pickDate.value.month == now.month) {
      if (pickerControllerDate.pickDate.value.day == now.day) {
        return true;
      }
      if (pickerControllerDate.pickDate.value.day + 1 == now.day &&
          now.hour < 9) {
        return true;
      }
    }
    return false;
  }

  void submitReason({
    required String date,
    required String reason,
    required Function() refresh,
  }) {
    state.submitReason(
      date: date,
      reason: reason,
      success: (msg) => successDialog(content: msg, back: () => refresh.call()),
      error: (msg) => errorDialog(content: msg),
    );
  }
}
