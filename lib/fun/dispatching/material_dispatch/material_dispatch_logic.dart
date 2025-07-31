import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/material_dispatch_info.dart';
import 'package:jd_flutter/bean/http/response/material_dispatch_label_detail.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/spinner_widget.dart';
import 'material_dispatch_state.dart';

class MaterialDispatchLogic extends GetxController {
  final MaterialDispatchState state = MaterialDispatchState();
  var scReportState = SpinnerController(
    saveKey: RouteConfig.materialDispatch.name,
    dataList: [
      'material_dispatch_report_state_all'.tr,
      'material_dispatch_report_state_not_report'.tr,
      'material_dispatch_report_state_reported'.tr,
      'material_dispatch_report_state_generated_not_report'.tr,
    ],
  );

  //日期选择器的控制器
  var dpcStartDate = DatePickerController(
    PickerType.startDate,
    saveKey: '${RouteConfig.materialDispatch.name}${PickerType.startDate}',
  )..firstDate = DateTime(
      DateTime.now().year - 5, DateTime.now().month, DateTime.now().day);

  //日期选择器的控制器
  var dpcEndDate = DatePickerController(
    PickerType.endDate,
    saveKey: '${RouteConfig.materialDispatch.name}${PickerType.endDate}',
  );

  // @override
  // void onReady() {
  //   userInfo?.empID = 175122;
  //   userInfo?.factory = '1000';
  //   userInfo?.defaultStockNumber = '1104';
  //   super.onReady();
  // }

  refreshDataList() {
    state.getScWorkCardProcess(
      startDate: dpcStartDate.getDateFormatYMD(),
      endDate: dpcEndDate.getDateFormatYMD(),
      status: scReportState.selectIndex - 1,
      error: (msg) => errorDialog(content: msg),
    );
  }

  search(String s) {
    if (s.isEmpty) {
      state.showOrderList.value = state.orderList;
    } else {
      state.showOrderList.value = state.orderList
          .where((v) => v.materialNumber?.contains(s) ?? false)
          .toList();
    }
  }

  reportToSAP() {
    state.reportToSAP(
      success: (msg) => successDialog(
        content: msg,
        back: () => refreshDataList(),
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  batchWarehousing() {
    var submitList = state.createSubmitData();
    if (submitList.isEmpty) {
      msgDialog(content: 'material_dispatch_batch_stock_in_error_tips'.tr);
    } else {
      state.batchWarehousing(
        submitList: submitList,
        success: (msg) => successDialog(
          content: msg,
          back: () => refreshDataList(),
        ),
        error: (msg) => errorDialog(content: msg),
      );
    }
  }

  itemReport(MaterialDispatchInfo data) {
    state.itemReport(
      data: data,
      success: (msg) => successDialog(
        content: msg,
        back: () => refreshDataList(),
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  itemCancelReport(MaterialDispatchInfo data) {
    state.itemCancelReport(
      data: data,
      success: (msg) => successDialog(
        content: msg,
        back: () => refreshDataList(),
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  subItemWarehousing(Children data, String sapDecideArea) {
    state.subItemWarehousing(
      data: data,
      sapDecideArea: sapDecideArea,
      success: (msg) => successDialog(
        content: msg,
        back: () => refreshDataList(),
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  subItemReport({
    required MaterialDispatchInfo submitData,
    required Children subData,
    required bool isPrint,
    required String qty,
    required String long,
    required String wide,
    required String height,
    required String gw,
    required String nw,
    required int titlePosition,
    required int clickPosition,
    required Function(
      String guid,
      String pick,
      List<MaterialDispatchLabelDetail> bill,
      String long,
      String wide,
      String height,
      String gwQty,
      String nwQty,
    ) success,
  }) {
    state.subItemReport(
      reportQty: qty,
      data: submitData,
      subData: subData,
      titlePosition: titlePosition,
      clickPosition: clickPosition,
      longQty: long,
      wideQty: wide,
      heightQty: height,
      gwQty: gw,
      nwQty: nw,
      success: (guid, pick) {
        if (state.allInstruction.value) {
          success.call(
            guid,
            pick,
            <MaterialDispatchLabelDetail>[],
            long,
            wide,
            height,
            gw,
            nw,
          );
        } else {
          state.getLabelDetail(
            guid: guid,
            success: (List<MaterialDispatchLabelDetail> bill) {
              success.call(
                guid,
                pick,
                bill,
                long,
                wide,
                height,
                gw,
                nw,
              );
            },
          );
        }
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  subItemCancelReport(Children subData) {
    state.subItemCancelReport(
      subData: subData,
      success: (msg) => successDialog(
        content: msg,
        back: () => refreshDataList(),
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }
}
