import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/order_production_execution_info.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'order_production_table_state.dart';

class OrderProductionTableLogic extends GetxController {
  final OrderProductionTableState state = OrderProductionTableState();

  void queryOrderList({
    required Function success,
  }) {
    state.getTailNumberListData(success: () {
      success.call();
    });
  }

  void getDetail({
    required OrderProductionExecutionInfo data,
    required Function() successTo,
  }) {
    state.getTailNumberReportData(
      needData: data,
      barCode: '',
      isGetTo: true,
      getTo: () {
        successTo.call();
      },
    );
  }

  // 线别 + 状态 + 搜索关键词 组合筛选（基于全量 copyTailNumberList）
  void selectShow() {
    final key = state.searchKey.value.trim().toLowerCase();
    // 先按 线别 + 搜索关键字 过滤（不含状态），用于统计各状态数量
    final base = state.copyTailNumberList.where((data) =>
        (state.selectIndex == 0 ||
            data.departmentName == state.lineList[state.selectIndex]) &&
        (key.isEmpty ||
            (data.seOrderNo ?? '').toLowerCase().contains(key) ||
            (data.workCardNo ?? '').toLowerCase().contains(key))).toList();
    // 再按 当前 Tab 状态 过滤，得到要展示的列表
    state.tailNumberList.value = base
        .where((data) => data.status == state.selectedTabIndex.value + 1)
        .toList();
    // 用不含状态过滤的 base 统计 4 个数量，保证每个 Tab 的数量角标恒等于真实值
    state.countByStatus(base);
    state.tailNumberList.refresh();
  }

  //清尾确认与取消
  void confirmTailCartonRecords(
      OrderProductionExecutionInfo item, bool submitType) {
    state.confirmTailCartonRecords(
        item: item,
        success: (mes) {
          successDialog(
              content: mes,
              back: () {
                state.getTailNumberListData(success: () {
                  selectShow();
                });
              });
        },
        isSubmit: submitType);
  }

  //添加不满箱数量
  void addUnFull({
    required String code,
    required Function() fullError,
    required Function() addSuccess,
  }) {
    for (var v in state.reportBoxList) {
      if (code == v.barCode) {
        // 命中对应箱码：容量校验，已扫 + 当前这 1 件不能超过欠数
        if (v.unFullBoxQty! + v.thisScanQty! + 1 <= v.arrears!) {
          v.thisScanQty = v.thisScanQty! + 1;
          // 合计行同步 +1，保证合计"不满箱数"随扫描累加
          // 合计行创建时 barCode 为空，尺码行的 barCode 非空，据此识别
          for (var t in state.reportBoxList) {
            if (t.size == '合计') {
              t.thisScanQty = (t.thisScanQty ?? 0) + 1;
              break;
            }
          }
          showScanTips();
          addSuccess.call();
          state.reportBoxList.refresh();
        } else {
          // 容量已满，报错一次即可
          fullError.call();
        }
        return; // 箱码唯一，命中即结束，避免重复处理/误报
      }
    }
    // 没匹配到任何箱码，报错一次
    fullError.call();
  }

  // 尾数重置：清空所有不满箱扫描数量
  void resetTailNumber() {
    askDialog(
      title: 'carton_label_scan_remain_reset'.tr,
      content: 'carton_label_scan_confirm_clear_unfull_box'.tr,
      confirmText: 'carton_label_scan_reset'.tr,
      confirm: () {
        state.resetUnFullBoxQty();
        showSnackBar(message: 'carton_label_scan_already_reset'.tr);
      },
    );
  }

  // 尾数提交
  void submitTailNumber() {
    askDialog(
      title: 'carton_label_scan_remain_submit'.tr,
      content: 'carton_label_scan_confirm_submit_remain_data'.tr,
      confirmText: 'carton_label_scan_submit'.tr,
      confirm: () {
        state.tailCartonRecordsTotal(success: (mes) {
          successDialog(
              content: mes,
              back: () {
                state.getTailNumberReportData(
                  barCode: '',
                  isGetTo: false,
                  needData: state.searcherData!,
                  getTo: () {},
                );
              });
        });
      },
    );
  }

  void setTailDetail({
    required int index,
    required Function goActivity,
  }) {
    state.showIndex = index;
    if (state.outBoxList[index].mantissaDataSizeList!.isNotEmpty) {
      setTotalQty();
      goActivity.call();
    } else {
      errorDialog(content: 'carton_label_scan_order_no_last_data'.tr);
    }
  }

  Future<void> cleanDetailScanned() async {
    for (var v in state.outBoxList[state.showIndex].mantissaDataSizeList!) {
      v.thisShortQty = v.shortQty;
    }
    setTotalQty();
    state.outBoxList.refresh();
  }

  void setTotalQty() {
    int totalLabelCount = 0;
    int totalShortQty = 0;
    for (var a in state.outBoxList[state.showIndex].mantissaDataSizeList!) {
      totalLabelCount += a.labelCount ?? 0;
      totalShortQty += a.thisShortQty ?? 0;
    }
    state.tailLabelTotal.value = totalLabelCount;
    state.tailScannedLabelTotal.value = totalShortQty;
  }

  void subMantissa(Function refresh) {
    state.subMantissaData(
      success: (msg) {
        refresh.call(msg);
      },
      error: (msg) {
        errorDialog(content: msg);
      },
    );
  }

  void tailDetailScan({
    required String barCode,
    required Function() full,
    required Function() add,
  }) {
    if (barCode.isNotEmpty) {
      bool found = false;
      for (var a in state.outBoxList[state.showIndex].mantissaDataSizeList!) {
        if (a.priceBarCode == barCode) {
          found = true;
          break;
        }
      }
      if (!found) {
        if (Get.isDialogOpen == true) Get.back();
        errorDialog(
          content: 'carton_label_scan_label_placement_error_tips'.trArgs(
            [barCode],
          ),
        );
      } else {
        for (var a in state.outBoxList[state.showIndex].mantissaDataSizeList!) {
          if (a.priceBarCode == barCode) {
            if (state.outBoxList[state.showIndex].guid!.isEmpty) {
              final currentShortQty = a.thisShortQty ?? 0;
              final currentLabelCount = a.labelCount ?? 0;

              if (currentShortQty < currentLabelCount) {
                if (state.tailScannedLabelTotal.value + 1 <
                    state.tailLabelTotal.value) {
                  a.thisShortQty = currentShortQty + 1;

                  showScanTips();
                  state.tailScannedLabelTotal.value += 1;
                  add.call();
                } else {
                  full.call();
                  if (Get.isDialogOpen == true) Get.back();
                  errorDialog(
                    content: 'carton_label_scan_order_not_full'.tr,
                  );
                }
              } else {
                full.call();
              }
            } else {
              final currentShortQty = a.thisShortQty ?? 0;
              final currentLabelCount = a.labelCount ?? 0;

              if (currentShortQty < currentLabelCount) {
                a.thisShortQty = currentShortQty + 1;

                showScanTips();
                state.tailScannedLabelTotal.value += 1;
                add.call();
              } else {
                full.call();
              }
            }
          }
        }
      }
    } else {
      showSnackBar(message: 'carton_label_scan_order_real_code'.tr);
    }
  }
}
