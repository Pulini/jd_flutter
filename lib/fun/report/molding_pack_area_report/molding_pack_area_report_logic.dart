import 'package:get/get.dart';

import '../../../route.dart';
import '../../../widget/dialogs.dart';
import '../../../widget/picker/picker_controller.dart';
import 'molding_pack_area_detail_report_view.dart';
import 'molding_pack_area_report_state.dart';

class MoldingPackAreaReportPageLogic extends GetxController {
  final MoldingPackAreaReportPageState state = MoldingPackAreaReportPageState();
  var today = DateTime.now();
  late DatePickerController dateControllerStart = DatePickerController(
    PickerType.startDate,
    saveKey: '${RouteConfig.moldingPackAreaReport.name}${PickerType.startDate}',
    firstDate: DateTime(today.year, today.month - 2, today.day),
    lastDate: today,
  );
  late DatePickerController dateControllerEnd = DatePickerController(
    PickerType.endDate,
    saveKey: '${RouteConfig.moldingPackAreaReport.name}${PickerType.endDate}',
    firstDate: DateTime(today.year, today.month - 2, today.day),
    lastDate: today,
  );
  var checkBoxController = CheckBoxPickerController(
    PickerType.mesMoldingPackAreaReportType,
    saveKey:
        '${RouteConfig.moldingPackAreaReport.name}${PickerType.mesMoldingPackAreaReportType}',
  );

  query() {
    state.getMoldingPackAreaReport(
      startDate: dateControllerStart.getDateFormatYMD(),
      endDate: dateControllerEnd.getDateFormatYMD(),
      packAreaIDs: checkBoxController.selectedIds,
      success: () {
        if (state.tableData.isNotEmpty) Get.back();
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  getDetails(int interID, String clientOrderNumber) {
    state.getMoldingPackAreaReportDetail(
      interID: interID,
      clientOrderNumber: clientOrderNumber,
      success: () => Get.to(() => const MoldingPackAreaDetailReportPage()),
      error: (msg) => errorDialog(content: msg),
    );
  }
}
