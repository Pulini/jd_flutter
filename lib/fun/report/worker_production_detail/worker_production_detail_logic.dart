import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';

import 'worker_production_detail_state.dart';

class WorkerProductionDetailLogic extends GetxController {
  final WorkerProductionDetailState state = WorkerProductionDetailState();
  var tecWorkerNumber = TextEditingController();
  var pickerControllerStartDate = DatePickerController(
    PickerType.startDate,
    saveKey:
        '${RouteConfig.workerProductionDetail.name}${PickerType.date}${PickerType.startDate}',
    lastDate: DateTime.now(),
  );

  var pickerControllerEndDate = DatePickerController(
    PickerType.endDate,
    saveKey: '${RouteConfig.workerProductionDetail.name}${PickerType.date}${PickerType.endDate}',
    lastDate: DateTime.now(),
  );

  var pickerControllerReportType = OptionsPickerController(
    PickerType.mesProductionReportType,
    saveKey:
        '${RouteConfig.workerProductionDetail.name}${PickerType.mesProductionReportType}',
  );

  query() {
    state.getProductionReport(
      worker: tecWorkerNumber.text,
      beginDate: pickerControllerStartDate.getDateFormatYMD(),
      endDate: pickerControllerEndDate.getDateFormatYMD(),
      itemID: pickerControllerReportType.selectedId.value,
      reportType: pickerControllerReportType.selectedId.value,
      error: (msg) => errorDialog(content: msg),
    );
  }

}
