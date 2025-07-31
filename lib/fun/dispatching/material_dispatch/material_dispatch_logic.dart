import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/material_dispatch_info.dart';
import 'package:jd_flutter/bean/http/response/material_dispatch_label_detail.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'material_dispatch_state.dart';

class MaterialDispatchLogic extends GetxController {
  final MaterialDispatchState state = MaterialDispatchState();

  @override
  void onReady() {
    userInfo?.empID = 175122;
    userInfo?.factory = '1000';
    userInfo?.defaultStockNumber = '1104';
    super.onReady();
  }



  refreshDataList({
    required String startDate,
    required String endDate,
    required int status,
    required String typeBody,
  }) {
    state.getScWorkCardProcess(
      startDate: startDate,
      endDate: endDate,
      status: status,
      typeBody: typeBody,
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

  reportToSAP({required Function() refresh}) {
    state.reportToSAP(
      success: (msg) => successDialog(
        content: msg,
        back: refresh,
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  batchWarehousing({required Function() refresh}) {
    var submitList = state.createSubmitData();
    if (submitList.isEmpty) {
      msgDialog(content: 'material_dispatch_batch_stock_in_error_tips'.tr);
    } else {
      state.batchWarehousing(
        submitList: submitList,
        success: (msg) => successDialog(
          content: msg,
          back: refresh,
        ),
        error: (msg) => errorDialog(content: msg),
      );
    }
  }

  itemReport(
      {required MaterialDispatchInfo data, required Function() refresh}) {
    state.itemReport(
      data: data,
      success: (msg) => successDialog(
        content: msg,
        back: refresh,
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  itemCancelReport({
    required MaterialDispatchInfo data,
    required Function() refresh,
  }) {
    state.itemCancelReport(
      data: data,
      success: (msg) => successDialog(
        content: msg,
        back: refresh,
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  subItemWarehousing({
    required Children data,
    required String sapDecideArea,
    required Function() refresh,
  }) {
    state.subItemWarehousing(
      data: data,
      sapDecideArea: sapDecideArea,
      success: (msg) => successDialog(
        content: msg,
        back: refresh,
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

  subItemCancelReport({
    required Children subData,
    required Function() refresh,
  }) {
    state.subItemCancelReport(
      subData: subData,
      success: (msg) => successDialog(
        content: msg,
        back:refresh ,
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }
}
