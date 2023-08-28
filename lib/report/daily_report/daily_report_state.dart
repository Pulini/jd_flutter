import 'package:get/get.dart';

import '../../http/response/daily_report_data.dart';
import '../../route.dart';
import '../../widget/picker/picker_controller.dart';

class DailyReportState {
  ///部门选择器存储值的key
  var pickerSaveDepartment =
      '${RouteConfig.dailyReport}${PickerType.mesDepartment}';

  ///日期选择器存储值的key
  var pickerSaveDate = '${RouteConfig.dailyReport}${PickerType.date}';

  ///报表数据
  RxList<DailyReportData> dataList = <DailyReportData>[].obs;

}
