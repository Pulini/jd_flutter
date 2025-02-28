import 'package:get/get.dart';
import 'package:jd_flutter/fun/dispatching/work_order_list/part_label_view.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';

import 'work_order_list_state.dart';

class WorkOrderListLogic extends GetxController {
  final WorkOrderListState state = WorkOrderListState();

  //组别选择器的控制器
  var pcGroup = OptionsPickerController(
    PickerType.sapGroup,
    saveKey: '${RouteConfig.workOrderList.name}${PickerType.sapGroup}',
  );

  //日期选择器的控制器
  var pcStartDate = DatePickerController(
    PickerType.startDate,
    saveKey: '${RouteConfig.workOrderList.name}${PickerType.startDate}',
  );

  //日期选择器的控制器
  var pcEndDate = DatePickerController(
    PickerType.endDate,
    saveKey: '${RouteConfig.workOrderList.name}${PickerType.endDate}',
  );

  query() {
    state.query(
      pcStartDate: pcStartDate.getDateFormatYMD(),
      pcEndDate: pcEndDate.getDateFormatYMD(),
      pcGroup: pcGroup.selectedId.value,
      error: (msg) => errorDialog(content: msg),
    );
  }

  queryPartList() {
    state.queryPartList(error: (msg) => errorDialog(content: msg));
  }

  submitCheck() {
    var selected = state.partList.where((v) => v.select);
    if (selected.isEmpty) {
      showSnackBar(
          message: 'work_order_list_select_component_tips'.tr,
          isWarning: true,);
    } else {
      if (selected.length > 1) {
        var names = <String>[];
        var name = '';
        for (var data in selected) {
          names.add(data.partName ?? '');
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

  queryPartDetail() {
    state.queryPartDetail(error: (msg) => errorDialog(content: msg));
  }

  createPartLabel(
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

  deleteLabel(String barCode, Function() callback) {
    state.deleteLabel(
      barCode: barCode,
      success: callback,
      error: (msg) => errorDialog(content: msg),
    );
  }
}
