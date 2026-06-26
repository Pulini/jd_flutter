import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:jd_flutter/bean/http/response/order_production_execution_info.dart';
import 'order_production_table_state.dart';

class OrderProductionTableLogic extends GetxController {
  final OrderProductionTableState state = OrderProductionTableState();

  void scan({required String code, required String number}) {
    state.getTailNumberReportData(barCode: code, dispatchNumber: number);
  }

  void queryOrderList({
   required String type,
   required Function success,
}) {
    state.getTailNumberListData( search: type, success: () {
      success.call();
    });
  }

  void getDetail(OrderProductionExecutionInfo data) {
    state.getTailNumberReportData(
        barCode: '', dispatchNumber: data.workCardNo!);
  }

  void selectShow(int index){
    if (index == 0) {
      state.tailNumberList.value = state.copyTailNumberList;
    } else {
      state.tailNumberList.value = state.copyTailNumberList
          .where((data) => data.departmentName== state.lineList[index])
          .toList();
    }
    state.tailNumberList.refresh();
  }

}
