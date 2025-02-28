import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/machine_dispatch_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';

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
        errorDialog(content: 'machine_dispatch_order_not_scanned_tips'.tr);
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
          content: 'machine_dispatch_not_scanned_all_tips'.trArgs([
            notScanLabelList.join(','),
            lastLabelList.join(','),
          ]),
        );
      } else {
        if (notScanLabelList.isNotEmpty) {
          errorDialog(
            content: 'machine_dispatch_not_scanned_box_tips'.trArgs([
              notScanLabelList.join(','),
            ]),
          );
        } else if (lastLabelList.isNotEmpty) {
          errorDialog(
            content: 'machine_dispatch_not_scanned_last_tips'.trArgs([
              lastLabelList.join(','),
            ]),
          );
        } else {
          var totalReport = 0.0;
          for (var v in state.sizeItemList) {
            if ((v.reportQty ?? 0.0) < 0) {
              errorDialog(
                content: 'machine_dispatch_input_size_report_qty_tips'.trArgs([
                  v.size ?? '',
                ]),
              );
              return;
            }
            totalReport = totalReport.add(v.reportQty ?? 0.0);
          }
          if (totalReport == 0) {
            errorDialog(content: 'machine_dispatch_input_report_qty_tips'.tr);
            return;
          } else {
            if (state.detailsInfo?.status == 2) {
              askDialog(
                  content:
                      'machine_dispatch_worker_number_report_again_tips'.tr,
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
        errorDialog(
          content: 'machine_dispatch_precess_not_allocation_tips'.trArgs([
            v.processNumber,
            v.processName,
          ]),
        );
        return;
      }
      var unsigned = <String>[];
      v.dispatchList.where((v) => v.signature == null).forEach((v) {
        unsigned.add('machine_dispatch_worker_not_signature_tips'.trArgs([
          v.workerNumber ?? '',
          v.workerName ?? '',
        ]));
      });
      if (unsigned.isNotEmpty) {
        errorDialog(
          content: 'machine_dispatch_process_unsigned_tips'.trArgs([
            v.processNumber,
            v.processName,
            unsigned.join('\n'),
          ]),
        );
        return;
      }
      if (v.totalProduction == 0) {
        errorDialog(
          content: 'machine_dispatch_process_no_allocation_qty_tips'.trArgs([
            v.processNumber,
            v.processName,
          ]),
        );
        return;
      }
      if (v.getSurplus() > 0) {
        errorDialog(
          content: 'machine_dispatch_process_still_surplus_qty_tips'.trArgs([
            v.processNumber,
            v.processName,
          ]),
        );
        return;
      }
    }
    askDialog(
      content: 'machine_dispatch_report_tips'.tr,
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
