import 'package:get/get.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

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
    state.getPartProcessReportedReport();
  }
}
