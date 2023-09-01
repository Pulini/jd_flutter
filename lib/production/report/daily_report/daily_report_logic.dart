import 'dart:convert';

import 'package:get/get.dart';
import 'package:jd_flutter/http/response/daily_report_data.dart';
import 'package:jd_flutter/http/web_api.dart';

import '../../../widget/dialogs.dart';
import '../../../widget/picker/picker_controller.dart';
import 'daily_report_state.dart';

class DailyReportLogic extends GetxController {
  final DailyReportState state = DailyReportState();

  ///部门选择器的控制器
  var pickerControllerDepartment =
      OptionsPickerController(PickerType.mesDepartment);

  ///日期选择器的控制器
  var pickerControllerDate = DatePickerController(PickerType.date);

  ///获取扫码日产量接口
  query() {
    if (pickerControllerDepartment.selectedId.value.isEmpty) {
      errorDialog(content: '请选择部门');
      return;
    }
    httpGet(
      loading: '正在查询日产量报表...',
      method: webApiGetDayOutput,
      query: {
        'DepartmentID': pickerControllerDepartment.selectedId.value,
        'Date': pickerControllerDate.getDateFormatYMD(),
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        try {
          var list = <DailyReportData>[
            DailyReportData(
              type: 0,
              materialName: '物料名称',
              size: '尺码',
              processName: '工序',
              qty: '报工数',
            )
          ];
          for (var item in jsonDecode(response.data)) {
            list.add(DailyReportData.fromJson(item));
          }
          state.dataList.value = list;
        } on Error catch (e) {
          logger.e(e);
          errorDialog( content: 'json_format_error'.tr);
        }
      } else {
        errorDialog( content: response.message ?? '查询失败');
      }
    });
  }
}
