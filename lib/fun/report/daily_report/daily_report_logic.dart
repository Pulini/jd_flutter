import 'dart:convert';

import 'package:get/get.dart';
import 'package:jd_flutter/http/response/daily_report_data.dart';
import 'package:jd_flutter/http/web_api.dart';

import '../../../route.dart';
import '../../../widget/dialogs.dart';
import '../../../widget/picker/picker_controller.dart';
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
    httpGet(
      loading: 'page_daily_report_querying'.tr,
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
              materialName: 'page_daily_report_table_title_hint1'.tr,
              size: 'page_daily_report_table_title_hint2'.tr,
              processName: 'page_daily_report_table_title_hint3'.tr,
              qty: 'page_daily_report_table_title_hint4'.tr,
            )
          ];
          for (var item in jsonDecode(response.data)) {
            list.add(DailyReportData.fromJson(item));
          }
          state.dataList.value = list;
          Get.back();
        } on Error catch (e) {
          logger.e(e);
          errorDialog(content: 'json_format_error'.tr);
        }
      } else {
        errorDialog(content: response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
