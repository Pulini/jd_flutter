import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:jd_flutter/fun/dispatching/work_order_list/part_label_view.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/printer/print_util.dart';
import 'package:jd_flutter/utils/printer/tsc_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import '../../../bean/http/response/part_detail_info.dart';
import 'work_order_list_state.dart';

class WorkOrderListLogic extends GetxController {
  final WorkOrderListState state = WorkOrderListState();

  var pu = PrintUtil();


  //固定单码标
  void  printLabel({
    required List<BarCodeInfo> list,
  }) async {
    //不显示预览
    var labelList = <List<Uint8List>>[];
    for (var data in list) {

      var instructions = '';
      data.mtonoList?.forEach((c) {
        instructions += '${c.mtono}(${c.createQty.toShowString()}),';
      });
      instructions = instructions.endsWith(',')
          ? instructions.substring(0, instructions.length - 1)
          : instructions;

      labelList.add(await labelMultipurposeFixed(
        qrCode: data.barCode ?? '',
        title: state.partDetail?.factoryType ?? '',
        subTitle: data.partName ?? '',
        subTitleWrap: false,
        content: '',
        bottomLeftText1: '${data.size?? ''}码',
        bottomMiddleText1: getDateYMDHM(),
        bottomRightText1: data.createQty.toShowString()+(state.partDetail?.unit ?? ''),
        speed:  4.0,
        density:  10.0,
      ));
    }
    pu.printLabelList(
      labelList: labelList,
      start: () {
        loadingShow('正在下发标签...');
      },
      progress: (i, j) {
        loadingShow('正在下发标签($i/$j)');
      },
      finished: (success, fail) {
        successDialog(
            title: '标签下发结束',
            content: '完成${success.length}张, 失败${fail.length}张',
            back: () {});
      },
    );
  }

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
