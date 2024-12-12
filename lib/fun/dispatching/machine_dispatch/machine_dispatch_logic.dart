import 'package:get/get.dart';
import 'package:jd_flutter/utils/utils.dart';

import '../../../bean/http/response/machine_dispatch_info.dart';
import '../../../widget/dialogs.dart';
import 'machine_dispatch_report_view.dart';
import 'machine_dispatch_state.dart';

class MachineDispatchLogic extends GetxController {
  final MachineDispatchState state = MachineDispatchState();


  getWorkCardList(Function(List<MachineDispatchInfo>) callback) {
    state.getWorkCardList(
      success: callback,
      error: (s) => errorDialog(content: s),
    );
  }

  getWorkCardDetail(MachineDispatchInfo mdi, Function() refreshUI) {
    state.getWorkCardDetail(
      dispatchNumber: mdi.dispatchNumber ?? '',
      success: () => state.getSapLabelList(
        success: refreshUI,
        error: refreshUI,
      ),
      error: (msg) {
        refreshUI.call();
        errorDialog(content: msg);
      },
    );
  }

  refreshWorkCardDetail(Function() refreshUI) {
    state.refreshWorkCardDetail(
      success: () => state.getSapLabelList(
        success: refreshUI,
        error: refreshUI,
      ),
      error: (msg) {
        refreshUI.call();
        errorDialog(content: msg);
      },
    );
  }

  cleanOrRecoveryLastQty(bool isClean, Function() refreshUI) {
    state.cleanOrRecoveryLastQty(
      isClean: isClean,
      success: (msg) => successDialog(
        content: msg,
        back: () => refreshWorkCardDetail(refreshUI),
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  modifyWorkCardItem(Function() refreshUI) {
    state.modifyWorkCardItem(
      success: (msg) => successDialog(
        content: msg,
        back: () => refreshWorkCardDetail(refreshUI),
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  checkLabelScanState() {
    refreshWorkCardDetail(() {
      if (state.labelList.isEmpty) {
        errorDialog(content: '此工单尚未打标扫码！');
        return;
      }
      var notScan = state.labelList.where((v) => !v.isScanned).toList();
      var notScanLabelList = <String>[
        for (var i = 0; i < notScan.length; ++i) notScan[i].number ?? ''
      ];
      var lastAndNotScan = notScan.where((v) => v.isLastLabel).toList();
      var lastLabelList = <String>[
        for (var i = 0; i < lastAndNotScan.length; ++i)
          lastAndNotScan[i].size ?? ''
      ];
      if (notScanLabelList.isNotEmpty && lastLabelList.isNotEmpty) {
        errorDialog(
            content:
                '含有以下序号的整箱未扫:${notScanLabelList.join(',')}\n含有以下尺码的尾标未扫:${lastLabelList.join(',')}');
      } else {
        if (notScanLabelList.isNotEmpty) {
          errorDialog(content: '含有以下序号的整箱未扫:${notScanLabelList.join(',')}');
        } else if (lastLabelList.isNotEmpty) {
          errorDialog(content: '含有以下尺码的尾标未扫:${lastLabelList.join(',')}');
        } else {
          var totalReport = 0.0;
          for (var v in state.sizeItemList) {
            if ((v.reportQty ?? 0.0) < 0) {
              errorDialog(content: '请填写<${v.size}码>的报工数');
              return;
            }
            totalReport = totalReport.add(v.reportQty ?? 0.0);
          }
          if (totalReport == 0) {
            errorDialog(content: '请填写报工数');
            return;
          } else {
            if (state.detailsInfo?.status == 2) {
              askDialog(
                  content: '还要再次工号汇报吗？',
                  confirm: () {
                    Get.to(() => const MachineDispatchReportPage());
                  });
            } else {
              Get.to(() => const MachineDispatchReportPage());
            }
          }
        }
      }
    });
  }

  signatureIdenticalWorker(DispatchInfo data) {
    for (var v in state.processList) {
      for (var v2 in v.dispatchList) {
        if (v2.workerEmpID == data.workerEmpID) {
          v2.signature = data.signature;
        }
      }
    }
    state.processList.refresh();
  }

  report() {
    for (var v in state.processList) {
      if (v.dispatchList.isEmpty) {
        errorDialog(content: '工序 <${v.processNumber}>${v.processName} 尚未分配！');
        return;
      }
      var unsigned = <String>[];
      v.dispatchList.where((v) => v.signature == null).forEach((v) {
        unsigned.add('员工  <${v.workerNumber}>${v.workerName}  尚未签字');
      });
      if (unsigned.isNotEmpty) {
        errorDialog(
            content:
                '工序 <${v.processNumber}>${v.processName}\n${unsigned.join('\n')}');
        return;
      }
      if (v.totalProduction == 0) {
        errorDialog(content: '工序 <${v.processNumber}>${v.processName} 无可分配数量！');
        return;
      }
      if (v.getSurplus() > 0) {
        errorDialog(
            content: '工序 <${v.processNumber}>${v.processName} 还有剩余可分配数量！');
        return;
      }
    }
    askDialog(
      content: '确定要工资汇报吗？',
      confirm: () => state.reportDispatch(
        success: (msg) => successDialog(
          content: msg,
          back: () => Get.back(),
        ),
        error: (msg) => errorDialog(content: msg),
      ),
    );
  }
}
