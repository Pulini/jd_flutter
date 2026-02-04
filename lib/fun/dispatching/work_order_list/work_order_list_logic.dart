import 'package:get/get.dart';
import 'package:jd_flutter/fun/dispatching/work_order_list/part_label_view.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'work_order_list_state.dart';

class WorkOrderListLogic extends GetxController {
  final WorkOrderListState state = WorkOrderListState();

  void query({
    required String startDate,
    required String endDate,
    required String group,
    required String workBarCode,
    required String planOrderNumber,
  }) {
    state.query(
      pcStartDate: startDate,
      pcEndDate: endDate,
      pcGroup: group,
      workBarCode: workBarCode,
      planOrderNumber: planOrderNumber,
      error: (msg) => errorDialog(content: msg),
    );
  }

  void queryPartList() {
    state.queryPartList(error: (msg) => errorDialog(content: msg));
  }

  void submitCheck() {
    var selected = state.partList.where((v) => v.select);
    if (selected.isEmpty) {
      showSnackBar(
        message: 'work_order_list_select_component_tips'.tr,
        isWarning: true,
      );
    } else {
      if (selected.length > 1) {
        var names = <String>[];
        var name = '';
        for (var data in selected) {
          names.add(data.partNameData);
        }
        name = names.join('work_order_list_and'.tr);
        askDialog(
            content: 'work_order_list_merge_tips'.trArgs([name]),
            confirm: () {
              Get.to(() => const PartLabelPage());
            });
      } else {
        Get.to(() => const PartLabelPage());
      }
    }
  }

  void queryPartDetail({required Function() success}) {
    state.queryPartDetail(
      error: (msg) => errorDialog(content: msg),
      success: success,
    );
  }

  void createPartLabel(
    double boxCapacity,
    double qty,
    String size,
    String empId,
  ) {
    if (boxCapacity <= 0) {
      showSnackBar(
        message: 'work_order_list_input_box_capacity_tips'.tr,
        isWarning: true,
      );
      return;
    }
    if (qty <= 0) {
      showSnackBar(
        message: 'work_order_list_input_create_qty'.tr,
        isWarning: true,
      );
      return;
    }
    if (empId.isEmpty) {
      showSnackBar(
        message: 'work_order_list_input_worker_tips'.tr,
        isWarning: true,
      );
      return;
    }
    state.createPartLabel(
      boxCapacity: boxCapacity,
      qty: qty,
      size: size,
      empId: empId,
      success: (msg) => successDialog(content: msg),
      error: (msg) => errorDialog(content: msg),
    );
  }

  void deleteLabel(String barCode, Function() callback) {
    state.deleteLabel(
      barCode: barCode,
      success: callback,
      error: (msg) => errorDialog(content: msg),
    );
  }
}
