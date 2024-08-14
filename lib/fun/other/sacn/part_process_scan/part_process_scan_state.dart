import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/scan_barcode_info.dart';
import 'package:jd_flutter/web_api.dart';



class PartProcessScanState {
  var barCodeList = <String>[].obs;

  // var reportEmpList =<EmpInfo>[].obs;
  var reportProcessList = <List<ReportInfo>>[].obs;
  var reportSelectList = <bool>[].obs;
  var reportDistributionList = <List<Distribution>>[].obs;

  // var reportBarCodeList =<BarCodeInfo>[].obs;
  PartProcessScanState() {
    ///Initialize variables
  }

  getPartProcessReportedReport() {
    httpPost(
      method: webApiGetPartProcessReportedReport,
      loading: '正在获取汇总信息...',
      body: {'BarCodeList': barCodeList.toList()},
    ).then((response) {
      // if (response.resultCode == resultSuccess) {
      //   var data = ScanBarcodeReportedReportInfo.fromJson(
      //     response.data,
      //   );
      //   var report = <ReportInfo>[];
      //   data.reportList?.where((v) => v.type == '0').forEach((v) {
      //     report.add(v);
      //   });
      //   groupBy(report,(v) => v.name).forEach((key, value) {
      //     state.reportProcessList.add(value);
      //     state.reportSelectList.add(false);
      //   });
      // } else {
      //   errorDialog(content: response.message);
      // }
    });
  }
}
