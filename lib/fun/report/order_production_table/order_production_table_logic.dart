import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
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

  void getDetail(OrderProductionExecutionInfo data) {
    state.getTailNumberReportData(
      needData: data,
      barCode: '',
      isGetTo: true,
    );
  }

  // 线别 + 状态 + 搜索关键词 组合筛选（基于全量 copyTailNumberList）
  void selectShow() {
    final key = state.searchKey.value.trim().toLowerCase();
    state.tailNumberList.value = state.copyTailNumberList
        .where((data) =>
            (state.selectIndex == 0 ||
                data.departmentName == state.lineList[state.selectIndex]) &&
            data.status == state.selectedTabIndex.value + 1 &&
            (key.isEmpty ||
                (data.seOrderNo ?? '').toLowerCase().contains(key) ||
                (data.workCardNo ?? '').toLowerCase().contains(key)))
        .toList();
    state.countByStatus();
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
                );
              });
        });
      },
    );
  }
}
