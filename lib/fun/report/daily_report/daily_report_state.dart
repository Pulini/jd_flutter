import 'package:get/get.dart';

import '../../../http/response/daily_report_data.dart';


class DailyReportState {
  ///报表数据
  RxList<DailyReportData> dataList = <DailyReportData>[].obs;

}
