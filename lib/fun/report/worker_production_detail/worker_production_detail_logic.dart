import 'package:get/get.dart';

import '../../../route.dart';
import '../../../widget/dialogs.dart';
import '../../../widget/picker/picker_controller.dart';
import 'worker_production_detail_state.dart';

class WorkerProductionDetailLogic extends GetxController {
  final WorkerProductionDetailState state = WorkerProductionDetailState();

  var pickerControllerStartDate = DatePickerController(
    PickerType.date,
    saveKey:
        '${RouteConfig.workerProductionDetail.name}${PickerType.date}start',
    lastDate: DateTime.now(),
  );

  var pickerControllerEndDate = DatePickerController(
    PickerType.date,
    saveKey: '${RouteConfig.workerProductionDetail.name}${PickerType.date}end',
    lastDate: DateTime.now(),
  );

  var pickerControllerReportType = OptionsPickerController(
    PickerType.mesProductionReportType,
    saveKey:
        '${RouteConfig.workerProductionDetail.name}${PickerType.mesProductionReportType}',
  );

  query() {
    state.getProductionReport(
      beginDate: pickerControllerStartDate.getDateFormatYMD(),
      endDate: pickerControllerEndDate.getDateFormatYMD(),
      itemID: pickerControllerReportType.selectedId.value,
      reportType: pickerControllerReportType.selectedId.value,
      success: () => Get.back(),
      error: (msg) => errorDialog(content: msg),
    );
  }

}
