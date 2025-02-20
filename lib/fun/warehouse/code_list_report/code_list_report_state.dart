import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/report_info.dart';
import 'package:jd_flutter/utils/utils.dart';

class CodeListReportState {
  var reportDataList = <ReportInfo>[].obs;

  ///报表数据
  var tableWeight = (0.0).obs;

  ///列表宽度

  getData(dynamic data) {
    reportDataList.value = [
      for (var i = 0; i < data.length; ++i) ReportInfo.fromJson(data[i])
    ];
    if (reportDataList.isNotEmpty) {
      tableWeight.value = reportDataList[0]
              .dataList
              ?.map((v) => (v.width ?? 0).add(12))
              .reduce((a, b) => a.add(b)) ??
          0;
    }
  }
}
