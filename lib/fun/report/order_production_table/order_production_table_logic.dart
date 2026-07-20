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
        barCode: '', dispatchNumber: data.workCardNo!, isGetTo: true);
  }

  // 线别 + 状态 + 搜索关键词 组合筛选（基于全量 copyTailNumberList）
  void selectShow() {
    final key = state.searchKey.value.trim().toLowerCase();
    state.tailNumberList.value = state.copyTailNumberList
        .where((data) =>
            (state.selectIndex == 0 ||
                data.departmentName == state.lineList[state.selectIndex]) &&
            data.searchType == state.selectedTabIndex.value &&
            (key.isEmpty ||
                (data.seOrderNo ?? '').toLowerCase().contains(key) ||
                (data.workCardNo ?? '').toLowerCase().contains(key)))
        .toList();
    state.countByStatus();
    state.tailNumberList.refresh();
  }

  //清尾确认与取消
  void confirmTailCartonRecords(OrderProductionExecutionInfo item,bool submitType) {
    print('DIAG logic.confirmTailCartonRecords called submitType=$submitType');
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
  }) {
    for (var v in state.reportBoxList) {
      if (code == v.barCode &&
          (v.unFullBoxQty! + v.thisScanQty! + 1 <= v.arrears!)) {
        v.thisScanQty = v.thisScanQty! + 1;
        showScanTips();
      } else {
        fullError.call();
      }
    }
  }

  // 尾数重置：清空所有不满箱扫描数量
  void resetTailNumber() {
    askDialog(
      title: '尾数重置',
      content: '确定清空所有不满箱扫描数量？',
      confirmText: '重置',
      confirm: () {
        state.resetUnFullBoxQty();
        showSnackBar(message: '已重置');
      },
    );
  }

  // 尾数提交
  void submitTailNumber() {
    askDialog(
      title: '尾数提交',
      content: '确定提交当前尾数数据？',
      confirmText: '提交',
      confirm: () {
        state.tailCartonRecordsTotal(success: (mes) {
          successDialog(
              content: mes,
              back: () {
                state.getTailNumberReportData(
                    barCode: '',
                    dispatchNumber: state.showDispatchNumber.value,
                    isGetTo: false);
              });
        });
      },
    );
  }
}
