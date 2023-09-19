import 'dart:convert';

import 'package:get/get.dart';

import '../../../http/response/worker_production_info.dart';
import '../../../http/web_api.dart';
import '../../../route.dart';
import '../../../widget/dialogs.dart';
import '../../../widget/picker/picker_controller.dart';
import 'worker_production_report_state.dart';

class WorkerProductionReportLogic extends GetxController {
  final WorkerProductionReportState state = WorkerProductionReportState();

  ///部门选择器的控制器
  var pickerControllerDepartment = OptionsPickerController(
    PickerType.mesDepartment,
    saveKey:
        '${RouteConfig.workerProductionReport.name}${PickerType.mesDepartment}',
  );

  ///日期选择器的控制器
  late DatePickerController pickerControllerDate = DatePickerController(
    PickerType.date,
    saveKey: '${RouteConfig.workerProductionReport.name}${PickerType.date}',
  );


  query() {
    httpGet(
      loading: '正在查询计件产量...',
      method: webApiGetWorkerProductionReport,
      query: {
        'DepartmentID': pickerControllerDepartment.selectedId.value,
        'Date': pickerControllerDate.getDateFormatYMD(),
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <WorkerProductionInfo>[];
        for (var item in jsonDecode(response.data)) {
          list.add(WorkerProductionInfo.fromJson(item));
        }
        state.dataList.value=list;
        Get.back();
      } else {
        errorDialog(content: response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
