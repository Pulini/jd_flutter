import 'package:get/get.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

import '../../../web_api.dart';
import 'part_process_scan_state.dart';

class PartProcessScanLogic extends GetxController {
  final PartProcessScanState state = PartProcessScanState();

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  addBarCode(String code, Function() callback) {
    if (code.isEmpty) {
      showSnackBar(title: '错误', message: '请输入贴标号', isWarning: true);
      return;
    }
    if (state.barCodeList.any((v) => v == code)) {
      showSnackBar(title: '错误', message: '标签已存在', isWarning: true);
      return;
    }
    state.barCodeList.add(code);
    callback.call();
  }

  barCodeModify() {
    if (state.barCodeList.isEmpty) {
      showSnackBar(title: '错误', message: '没有可提交的条码', isWarning: true);
      return;
    }
    httpPost(
      method: webApiGetPartProcessReportedReport,
      loading: '正在获取汇总信息...',
      body: {
        'BarCodeList': state.barCodeList.toList(),
      },
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
