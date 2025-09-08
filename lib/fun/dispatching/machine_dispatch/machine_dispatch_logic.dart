import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/machine_dispatch_info.dart';
import 'package:jd_flutter/bean/http/response/sap_label_info.dart';
import 'package:jd_flutter/fun/dispatching/machine_dispatch/machine_dispatch_history_view.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/preview_label_widget.dart';
import 'package:jd_flutter/widget/tsc_label_templates/fixed_label_75w45h.dart';

import 'machine_dispatch_report_view.dart';
import 'machine_dispatch_state.dart';

class MachineDispatchLogic extends GetxController {
  final MachineDispatchState state = MachineDispatchState();

  bool isSelectAll() =>
      state.selectList.isNotEmpty &&
      state.selectList.where((v) => v.value).length == state.selectList.length;

  bool isSelectedOne() =>
      state.selectList.map((v) => v.value ? 1 : 0).reduce((a, b) => a + b) == 1;

  bool hasSelected() => state.selectList.any((v) => v.value);

  bool hasReported() =>
      state.detailsInfo?.items?.any((v) => (v.boxesQty ?? 0) > 0) == true;

  bool statusReportedAndGenerate() => state.detailsInfo?.status == 2;

  getWorkCardList(Function(List<MachineDispatchInfo>) callback) {
    state.getWorkCardList(
      success: callback,
      error: (s) => errorDialog(content: s),
    );
  }

  refreshWorkCardDetail({Function()? refreshUI}) {
    state.refreshWorkCardDetail(
      success: () => refreshUI?.call(),
      error: (msg) {
        errorDialog(content: msg);
      },
    );
  }

  cleanOrRecoveryLastQty(bool isClean) {
    state.cleanOrRecoveryLastQty(
      isClean: isClean,
      success: (msg) => successDialog(
        content: msg,
        back: () => refreshWorkCardDetail(),
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  modifyWorkCardItem() {
    state.modifyWorkCardItem(
      success: (msg) => successDialog(
        content: msg,
        back: () => refreshWorkCardDetail(),
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  workerDispatchConfirmation() {
    refreshWorkCardDetail(refreshUI: () {
      state.getSapLabelList(
        success: () {
          if (state.labelList.isEmpty) {
            errorDialog(content: 'machine_dispatch_order_not_scanned_tips'.tr);
            return;
          }
          var notScan = state.labelList.where((v) => !v.isScanned).toList();
          var notScanLabelList = <String>[
            for (var i = 0; i < notScan.length; ++i) notScan[i].number
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
                    content:
                        'machine_dispatch_input_size_report_qty_tips'.trArgs([
                      v.size ?? '',
                    ]),
                  );
                  return;
                }
                totalReport = totalReport.add(v.reportQty ?? 0.0);
              }
              if (totalReport == 0) {
                errorDialog(
                    content: 'machine_dispatch_input_report_qty_tips'.tr);
                return;
              } else {
                if (statusReportedAndGenerate()) {
                  askDialog(
                      content:
                          'machine_dispatch_worker_number_report_again_tips'.tr,
                      confirm: () {
                        Get.to(() => const MachineDispatchReportPage());
                      });
                } else {
                  errorDialog(content: '');
                }
              }
            }
          }
        },
        error: (msg) => errorDialog(content: msg),
      );
    });
  }

  cancelWorkerDispatchConfirmation() {
    state.cancelConfirmation(
      success: (msg) => successDialog(
        content: msg,
        back: () => refreshWorkCardDetail(),
      ),
      error: (msg) => errorDialog(content: msg),
    );
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

  getHistoryInfo() {
    state.getWorkCardListByDate(
      startDate: getDateYMD(
        time: DateTime.now().subtract(const Duration(days: 7)),
      ),
      endDate: getDateYMD(),
      success: () => Get.to(() => const MachineDispatchHistoryPage()),
      error: (msg) => errorDialog(content: msg),
    );
  }

  getHistoryStockInLabelInfo(int index) {
    state.getHistoryLabelList(
      index: index,
      success: () => Get.to(
        () => const MachineDispatchHistoryDetailPage(),
        arguments: {'index': index},
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  printSurplusMaterialLabel() {}

  printHistoryLabel(int i) {
    printLabel(state.historyLabelInfo[i]);
  }

  printLabel(MachineDispatchReprintLabelInfo label) {
    Get.to(() => PreviewLabel(labelWidget: fixedLabel(label: label)));
  }

  fixedLabel({required MachineDispatchReprintLabelInfo label}) =>
      label.isEnglish
          ? machineDispatchEnglishFixedLabel(
              labelID: label.labelID,
              factoryType: label.factoryType,
              englishName: label.englishName,
              grossWeight: label.grossWeight,
              netWeight: label.netWeight,
              specifications: label.specifications,
              number: label.number,
              dispatchNumber: label.dispatchNumber,
              decrementNumber: label.decrementNumber,
              date: label.date,
              qty: label.qty,
              englishUnit: label.englishUnit,
              size: label.size,
            )
          : machineDispatchChineseFixedLabel(
              labelID: label.labelID,
              factoryType: label.factoryType,
              processes: label.processes,
              number: label.number,
              materialName: label.materialName,
              dispatchNumber: label.dispatchNumber,
              decrementNumber: label.decrementNumber,
              date: label.date,
              size: label.size,
              qty: label.qty,
              unit: label.unit,
              shift: label.shift,
              machine: label.machine,
              isLastLabel: label.isLastLabel,
            );

  generateAndPrintLabel({
    required bool isPrintLast,
    bool isEnglish = false,
    String specifications = '',
    double weight = 0.0,
  }) {
    Items item =
        state.detailsInfo!.items![state.selectList.indexWhere((v) => v.value)];

    var printQty = 0.0;
    if (state.detailsInfo?.status == 1 || state.detailsInfo?.status == 2) {
      printQty = item.notFullQty ?? 0;
    } else {
      if (isPrintLast) {
        if ((item.capacity ?? 0) > 0) {
          if (item.mantissaMark == 'X') {
            printQty = item.sumUnderQty != 0
                ? (item.sumUnderQty.add(item.lastNotFullQty ?? 0) %
                    (item.capacity ?? 0))
                : item.notFullQty ?? 0;
          } else {
            printQty = item.capacity ?? 0;
          }
        } else {
          errorDialog(
            content: '数量必须大于0',
          );
          return;
        }
      } else {
        if ((item.capacity ?? 0) > 0) {
          printQty = item.capacity ?? 0;
        } else {
          errorDialog(
            content: '数量必须大于0',
          );
          return;
        }
      }
    }
    state.labelMaintain(
      printQty: printQty,
      sizeMaterialNumber: item.sizeMaterialNumber ?? '',
      size: item.size ?? '',
      isEnglish: isEnglish,
      specifications: specifications,
      weight: weight,
      success: (label) {
        Get.to(() => PreviewLabel(
              labelWidget: fixedLabel(
                label: MachineDispatchReprintLabelInfo(
                  isLastLabel: isEnglish ? false : printQty != item.capacity,
                  number: label.number ?? '',
                  labelID: label.labelID ?? '',
                  processes: state.detailsInfo?.processflow ?? '',
                  qty: printQty,
                  size: item.size ?? '',
                  factoryType: state.detailsInfo?.factoryType ?? '',
                  date: state.detailsInfo?.startDate ?? '',
                  materialName: isEnglish
                      ? label.name ?? ''
                      : state.detailsInfo?.materialName ?? '',
                  unit: isEnglish ? label.unit ?? '' : item.bUoM ?? '',
                  machine: state.detailsInfo?.machine ?? '',
                  shift: state.detailsInfo?.shift ?? '',
                  dispatchNumber: state.detailsInfo?.dispatchNumber ?? '',
                  decrementNumber: state.detailsInfo?.decrementNumber ?? '',
                  isEnglish: isEnglish,
                  specifications: label.specifications ?? '',
                  netWeight: label.netWeight ?? 0,
                  grossWeight: label.grossWeight ?? 0,
                  englishName: label.name ?? '',
                  englishUnit: label.unit ?? '',
                ),
              ),
            ));
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  productionReport() {
    var noWorkingHours = state.detailsInfo?.items
        ?.where((v) =>
            v.getReportQty() > 0 &&
            v.confirmCurrentWorkingHours.toDoubleTry() == 0)
        .map((v) => v.size)
        .toList();
    if (noWorkingHours != null && noWorkingHours.isNotEmpty) {
      errorDialog(content: '尺码 < ${noWorkingHours.join(',')} > 无工时！');
      return;
    }
    state.productionReport(
      success: (msg) => successDialog(
        content: msg,
        back: () => refreshWorkCardDetail(),
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  handoverShifts() {
    if (state.detailsInfo?.stubBar1PrintFlag != 1) {
      errorDialog(content: '料头一未打印');
      return;
    }
    if (state.detailsInfo?.stubBar2PrintFlag != 1) {
      errorDialog(content: '料头二未打印');
      return;
    }
  }

  getEnglishLabel(Function(EnglishLabelInfo) callback) {
    state.getEnglishLabel(
      code: state
              .detailsInfo!
              .items![state.selectList.indexWhere((v) => v.value)]
              .sizeMaterialNumber ??
          '',
      success: callback,
      error: (msg) => errorDialog(content: msg),
    );
  }
}
