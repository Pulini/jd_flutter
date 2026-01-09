import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/fun/warehouse/out/material_label_scan/material_label_scan_state.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

class MaterialLabelScanLogic extends GetxController {
  final MaterialLabelScanState state = MaterialLabelScanState();

  void query({
    required String startDate,
    required String endDate,
  }) {
    state.getQueryList(
        startDate: startDate, endDate: endDate, error: (String s) {});
  }

  void queryDetail({
    required String workCardNo,
  }) {
    state.getQueryDetail(workCardNo: workCardNo);
  }

  void queryBarCodeDetail({
    required String barCode,
  }) {
    state.canScan = false;
    state.getQueryBarCodeDetail(
        barCode: barCode,
        success: () {
          showScanTips(tips: '+');
        },
        error: (String s) {
          showSnackBar(message: s);
        });
  }

  //清空条码
  void clearBarCode() {
    for (var entry in state.dataDetailList.entries) {
      // 获取当前物料分组下的所有明细
      var materialList = entry.value;

      // 在当前物料分组中查找匹配的尺码
      for (var detailItem in materialList) {
        detailItem.thisTime = 0.0;
        detailItem.isScan = false;
      }
    }
    state.dataDetailList.refresh();
  }

// 检查是否可以提交
  void checkSubmit({
    required Function()? success,
}) {
    bool hasScannedItems = false;

    // 遍历所有物料分组
    for (var entry in state.dataDetailList.entries) {
      // 获取当前物料分组下的所有明细
      var materialList = entry.value;
      // 在当前物料分组中查找匹配的尺码
      for (var detailItem in materialList) {
        if (detailItem.isScan == true) {
          hasScannedItems = true;
          break; // 找到后退出内层循环
        }
      }
      // 如果在当前物料分组中已找到扫描项，继续下一个分组
      if (hasScannedItems) break;
    }

    // 如果存在已扫描的项目，则返回成功
    if (hasScannedItems) {
      success?.call();
    } else {
      showSnackBar(message: '没有可提交的条码信息');
    }
  }


  //提交条码信息
  void submit(WorkerInfo worker) {
    state.submitCodeDetail(success: () {}, receiverEmpID: worker.empID ?? 0);
  }
}
