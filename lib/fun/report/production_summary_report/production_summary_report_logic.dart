import 'package:get/get.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/spinner_widget.dart';

import 'production_summary_report_state.dart';

class ProductionSummaryReportLogic extends GetxController {
  final ProductionSummaryReportState state = ProductionSummaryReportState();

  //日期选择器的控制器
  var pickerControllerDate = DatePickerController(
    PickerType.date,
    saveKey: '${RouteConfig.productionSummaryTable.name}${PickerType.date}',
  );
  var spinnerControllerWorkShop = SpinnerController(
    saveKey: RouteConfig.productionSummaryTable.name,
    dataList: [
      'spinner_work_shop_hint1'.tr,
      'spinner_work_shop_hint2'.tr,
      'spinner_work_shop_hint3'.tr,
      'spinner_work_shop_hint4'.tr,
      'spinner_work_shop_hint5'.tr
    ],
  );

  //获取产量汇总表接口
  query() {
    state.getPrdShopDayReport(
      date: pickerControllerDate.getDateFormatYMD(),
      workShopID: spinnerControllerWorkShop.selectIndex + 1,
      error: (msg) => errorDialog(content: msg),
    );
  }
}
