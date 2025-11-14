import 'dart:convert';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/machine_dispatch_info.dart';
import 'package:jd_flutter/bean/http/response/sap_label_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/fun/dispatching/machine_dispatch/machine_dispatch_history_view.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/printer/print_util.dart';
import 'package:jd_flutter/utils/printer/tsc_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'machine_dispatch_handover_view.dart';
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

  bool statusReportedAndGenerate() => state.detailsInfo?.status == 2;

  bool canHandover() => state.detailsInfo?.status == 2; //可以两班交接

  void getWorkCardList(Function(List<MachineDispatchInfo>) callback) {
    state.getWorkCardList(
      success: callback,
      error: (s) => errorDialog(content: s),
    );
  }

  void refreshWorkCardDetail({Function()? refreshUI}) {
    state.refreshWorkCardDetail(
      success: () => refreshUI?.call(),
      error: (msg) {
        errorDialog(content: msg);
      },
    );
  }

  void cleanOrRecoveryLastQty(bool isClean) {
    state.cleanOrRecoveryLastQty(
      isClean: isClean,
      success: (msg) => successDialog(
        content: msg,
        back: () => refreshWorkCardDetail(),
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  void modifyWorkCardItem() {
    state.modifyWorkCardItem(
      success: (msg) => successDialog(
        content: msg,
        back: () => refreshWorkCardDetail(),
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  void workerDispatchConfirmation({
    required bool isHandover,
    required Function() callback,
  }) {
    refreshWorkCardDetail(refreshUI: () {
      state.getSapLabelList(
        success: () {
          if (isHandover) {
            for (var data in state.labelList) {
              for (var size in state.sizeItemList) {
                if (data.size == size.size && data.qty != size.capacity) {
                  size.mantissaIdentification = true;
                }
              }
            }
            gotoHandover(callback: () {
              callback.call();
            });
          } else {
            if (state.labelList.isEmpty) {
              errorDialog(
                  content: 'machine_dispatch_order_not_scanned_tips'.tr);
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
                  if (v.getReportQty() < 0) {
                    errorDialog(
                      content:
                          'machine_dispatch_input_size_report_qty_tips'.trArgs([
                        v.size ?? '',
                      ]),
                    );
                    return;
                  }
                  totalReport = totalReport.add(v.getReportQty());
                }
                if (totalReport == 0) {
                  errorDialog(
                      content: 'machine_dispatch_input_report_qty_tips'.tr);
                  return;
                } else {
                  if (statusReportedAndGenerate()) {
                    askDialog(
                        content:
                            'machine_dispatch_worker_number_report_again_tips'
                                .tr,
                        confirm: () {
                          Get.to(() => const MachineDispatchReportPage())
                              ?.then((v) {
                            if (v == true) {
                              callback.call();
                            }
                          });
                        });
                  } else {
                    Get.to(() => const MachineDispatchReportPage())?.then((v) {
                      if (v == true) {
                        callback.call();
                      }
                    });
                  }
                }
              }
            }
          }
        },
        error: (msg) => errorDialog(content: msg),
      );
    });
  }

  void gotoHandover({
    required Function() callback,
  }) {
    state.handoverList.clear();
    state.handoverList.add(HandoverInfo('当班交接人员'));
    state.handoverList.add(HandoverInfo('接收尾数人员'));
    Get.to(() => const MachineDispatchHandoverPage())?.then((v) {
      if (v != null) {
        callback.call();
      }
    });
  }

  void cancelWorkerDispatchConfirmation() {
    state.cancelConfirmation(
      success: (msg) => successDialog(
        content: msg,
        back: () => refreshWorkCardDetail(),
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  void signatureIdenticalWorker(DispatchInfo data) {
    for (var v in state.processList) {
      for (var v2 in v.dispatchList) {
        if (v2.workerEmpID == data.workerEmpID) {
          v2.signature = data.signature;
        }
      }
    }
    state.processList.refresh();
  }

  void report() {
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
          back: () => Get.back(result: true),
        ),
        error: (msg) => errorDialog(content: msg),
      ),
    );
  }

  void getHistoryInfo() {
    state.getWorkCardListByDate(
      startDate: getDateYMD(
        time: DateTime.now().subtract(const Duration(days: 7)),
      ),
      endDate: getDateYMD(),
      success: () => Get.to(() => const MachineDispatchHistoryPage()),
      error: (msg) => errorDialog(content: msg),
    );
  }

  void getHistoryStockInLabelInfo(int index) {
    state.getHistoryLabelList(
      index: index,
      success: () => Get.to(
        () => const MachineDispatchHistoryDetailPage(),
        arguments: {'index': index},
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  void printHistoryLabel(int i) {
    printLabel(state.historyLabelInfo[i]);
  }

  //重新打印
  void printLabel(MachineDispatchReprintLabelInfo label) {
    labelMultipurposeFixed(
      isEnglish: label.isEnglish,
      qrCode: label.labelID,
      title: state.detailsInfo?.factoryType ?? '',
      subTitle: label.isEnglish
          ? state.detailsInfo?.materialName ?? ''
          : ((state.detailsInfo?.processflow ?? '') +
              ('       序号：${label.number}')),
      subTitleWrap: false,
      content: label.isEnglish
          ? ('GW:${label.grossWeight}KG   NW:${label.netWeight}KG')
          : state.detailsInfo?.materialName ?? '',
      specification: label.isEnglish ? 'MEAS:  ${label.specifications}' : '',
      subContent1: label.isEnglish
          ? 'DISPATCH:${state.detailsInfo?.dispatchNumber.toString()}'
          : '派工单号：${state.detailsInfo?.dispatchNumber ?? ''}       班次：${state.detailsInfo?.shift ?? ''}',
      subContent2: label.isEnglish
          ? 'DECREASE:${state.detailsInfo?.decrementNumber}    DATE:${state.detailsInfo?.startDate}'
          : '递减号:${state.detailsInfo?.decrementNumber}      日期:${state.detailsInfo?.startDate}',
      bottomLeftText1: label.isEnglish
          ? '${label.qty}${label.englishUnit}'
          : '${state.detailsInfo?.machine}',
      bottomMiddleText1: label.isEnglish
          ? '   Made in China'
          : '     ${label.size}码${label.qty}${label.unit}',
      bottomRightText1:
          label.isEnglish ? "${label.size}#" : (label.isLastLabel ? '尾' : ''),
      speed: spGet(spSavePrintSpeed) ?? 3.0,
      density: spGet(spSavePrintDensity) ?? 15.0,
    ).then((printLabel) {
      PrintUtil().printLabel(
          label: printLabel,
          start: () {
            loadingShow('正在打印');
          },
          success: () {
            loadingDismiss();
            showSnackBar(message: '打印成功');
          },
          failed: () {
            loadingDismiss();
            showSnackBar(message: '打印失败');
          });
    });
  }

  void printMaterialHeadLabel(
    String code,
    String name,
    MachineDispatchDetailsInfo details, {
    required Function() callback,
  }) {
    labelForSurplusMaterial(
            qrCode: jsonEncode({
              'DispatchNumber': details.dispatchNumber,
              'StubBar': code,
              'Factory': details.factory ?? '',
              'Date': details.startDate ?? '',
              'NowTime': DateTime.now().millisecond,
            }),
            machine: details.machine ?? '',
            shift: details.shift ?? '',
            startDate: details.startDate ?? '',
            factoryType: details.factoryType ?? '',
            stubBar: name,
            stuBarCode: code)
        .then((printLabel) {
      PrintUtil().printLabel(
          label: printLabel,
          start: () {
            loadingShow('正在打印');
          },
          success: () {
            loadingDismiss();
            showSnackBar(message: '打印成功');
          },
          failed: () {
            loadingDismiss();
            showSnackBar(message: '打印失败');
          });
    });
  }

  void generateAndPrintLabel({
    required bool isPrintLast,
    bool isEnglish = false,
    String specifications = '',
    double weight = 0.0,
  }) {
    Items item =
        state.detailsInfo!.items![state.selectList.indexWhere((v) => v.value)];


    var printQty = 0.0;
    if ((state.detailsInfo?.status == 1 || state.detailsInfo?.status == 2 ) && state.leaderVerify.value) {
      printQty = item.notFullQty ?? 0;
    } else {
      if (isPrintLast) {
        if ((item.capacity ?? 0) > 0) {
          if (item.mantissaMark == 'X') {
            printQty = item.sumUnderQty != 0 ? (item.sumUnderQty.add(item.lastNotFullQty ?? 0) % (item.capacity ?? 0)) : item.notFullQty ?? 0;
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
        labelMultipurposeFixed(
          isEnglish: isEnglish,
          qrCode: label.labelID ?? '',
          title: state.detailsInfo?.factoryType ?? '',
          subTitle: isEnglish
              ? label.name ?? ''
              : ((state.detailsInfo?.processflow ?? '') +
                  ('       序号：${label.number}')),
          subTitleWrap: false,
          content: isEnglish
              ? ('GW:${label.grossWeight}KG   NW:${label.netWeight}KG')
              : state.detailsInfo?.materialName ?? '',
          specification: isEnglish ? 'MEAS:  ${label.specifications}    No.${label.number?? ''}': '',
          subContent1: isEnglish
              ? 'DISPATCH:${state.detailsInfo?.dispatchNumber.toString()}'
              : '派工单号：${state.detailsInfo?.dispatchNumber ?? ''}       班次：${state.detailsInfo?.shift ?? ''}',
          subContent2: isEnglish
              ? 'DECREASE:${state.detailsInfo?.decrementNumber}    DATE:${state.detailsInfo?.startDate}'
              : '递减号:${state.detailsInfo?.decrementNumber}    日期:${state.detailsInfo?.startDate}',
          bottomLeftText1: isEnglish ? ((printQty.toShowString()) + (label.unit ?? '')) : '${state.detailsInfo?.machine}',
          bottomMiddleText1: isEnglish
              ? '   Made in China'
              : ('     ${item.size ?? ''}码${printQty.toShowString()}${item.bUoM ?? ''}'),
          bottomRightText1:
              isEnglish ? "${item.size}#" : (isPrintLast ? '尾' : ''),
          speed: spGet(spSavePrintSpeed) ?? 3.0,
          density: spGet(spSavePrintDensity) ?? 15.0,
        ).then((printLabel) {
          PrintUtil().printLabel(
              label: printLabel,
              start: () {
                loadingShow('正在打印');
              },
              success: () {
                loadingDismiss();
                showSnackBar(message: '打印成功');
              },
              failed: () {
                loadingDismiss();
                showSnackBar(message: '打印失败');
              });
        });
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  void productionReport() {
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

  bool checkAllTotal() {
    var reportQty = 0.0;
    for (var v in state.sizeItemList) {
      reportQty = reportQty.add(v.getReportQty());
    }
    if (reportQty < 0) {
      showSnackBar(
        message: '合计报工数小于0',
        isWarning: true,
      );
      return false;
    } else {
      return true;
    }
  }

  bool checkSizeTotal() {
    if (state.sizeItemList.any((v) => v.getReportQty() < 0)) {
      showSnackBar(
        message: '含有尺码报工数小于0',
        isWarning: true,
      );
      return false;
    } else {
      return true;
    }
  }

//验证料头
  bool handoverShifts() {
    var stuBar = true;
    var stuBar2 = true;

    if (state.detailsInfo?.stubBarName1 != '' &&
        state.detailsInfo?.stubBar1PrintFlag != 1) {
      errorDialog(content: '料头一未打印');
      stuBar = false;
    }

    if (state.detailsInfo?.stubBarName2 != '' &&
        state.detailsInfo?.stubBar2PrintFlag != 1) {
      errorDialog(content: '料头二未打印');
      stuBar2 = false;
    }

    if (stuBar && stuBar2) {
      return true;
    } else {
      return false;
    }
  }

  void getEnglishLabel(Function(EnglishLabelInfo) callback) {
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

//更改模具数
  void changeMould(String size, String moulds, String qty) {
    for (var data in state.sizeItemList) {
      if (data.size == size) {
        data.mould = moulds.toDoubleTry();
        data.todayDispatchQty = qty.toDoubleTry();
      }
    }
    state.sizeItemList.refresh();
  }

//更改当日派工数量
  void changeTodayNum(String size, String qty) {
    for (var data in state.sizeItemList) {
      if (data.size == size) {
        data.todayDispatchQty = qty.toDoubleTry();
      }
    }
    state.sizeItemList.refresh();
  }

//更改箱容
  void changeCapacity(String size, String capacity) {
    for (var data in state.sizeItemList) {
      if (data.size == size) {
        data.capacity = capacity.toDoubleTry();
      }
    }
    state.sizeItemList.refresh();
  }

  void changeLastNum(String size, String qty) {
    for (var data in state.sizeItemList) {
      if (data.size == size) {
        data.notFullQty = qty.toDoubleTry();
      }
    }
  }

  void handover() {
    state.handover(success: (mes) {
      successDialog(
        content: mes,
        back: () {
          Get.back(result: true);
        },
      );
    });
  }
}
