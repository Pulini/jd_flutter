import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/carton_label_scan_info.dart';
import 'package:jd_flutter/bean/http/response/carton_label_scan_progress_info.dart';
import 'package:jd_flutter/fun/warehouse/manage/carton_label_scan/carton_label_scan_progress_detail_view.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'carton_label_scan_state.dart';

class CartonLabelScanLogic extends GetxController {
  final CartonLabelScanState state = CartonLabelScanState();
  var scanController = TextEditingController();

  var isSubmitting = false;

  queryPriorityCartonLabelInfo({
    required String code,
  }) {
    httpGet(
      loading:'carton_label_scan_querying_outside_label_detail'.tr  ,
      method: webApiGetCartonLabelInfo,
      params: {
        'CartonBarCode': code,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        state.priorityCartonLabelInfo = CartonLabelScanInfo.fromJson(response.data);
        state.priorityCartonLabel.value = state.priorityCartonLabelInfo?.outBoxBarCode ?? '';
        state.priorityPo.value = state.priorityCartonLabelInfo?.custOrderNumber ?? '';
        state.priorityCartonInsideLabelList.value = state.priorityCartonLabelInfo!.linkDataSizeList ?? [];
      } else {
        state.clearPriority();
        errorDialog(content: response.message ?? 'query_default_error'.tr);
      }
    });
  }

  queryCartonLabelInfo(String code) {
    state.queryCartonLabelInfo(
      code: code,
      error: (msg) => errorDialog(content: msg),
    );
  }

  cleanAll(Function refresh) {
    state.cartonInsideLabelList.value = [];
    state.cartonLabel.value = '';
    state.cartonLabelInfo = null;
    refresh.call();
  }

  cleanScanned() {
    for (var v in state.cartonInsideLabelList) {
      v.scanned = 0;
    }
    state.scannedLabelTotal.value = 0;
    state.cartonInsideLabelList.refresh();
  }

  scan({
    required String code,
    required Function(String) outsideCode,
    required Function(String) insideCode,
    required Function() insideExpired,
    required Function() notOutsideCode,
    required Function() submitSuccess,
    required Function() submitError,
  }) {
    if (isSubmitting) return;
    if (state.cartonLabel.value.isEmpty) {
      outsideCode.call(code);
      queryCartonLabelInfo(code);
    } else {
      try {
        var exist = state.cartonInsideLabelList.singleWhere(
          (v) => v.priceBarCode == code,
        );
        if (exist.scanned < exist.labelCount!) {
          insideCode.call(code);
          exist.scanned += 1;
          state.scannedLabelTotal.value += 1;
        } else {
          insideExpired.call();
          if (Get.isDialogOpen == true) Get.back();
          errorDialog(
            content: 'carton_label_scan_label_scan_completed_tips'.trArgs(
              [code],
            ),
          );
        }
      } catch (e) {
        notOutsideCode.call();
        if (Get.isDialogOpen == true) Get.back();
        errorDialog(
          content: 'carton_label_scan_label_placement_error_tips'.trArgs(
            [code],
          ),
        );
      }
    }
    if (state.labelTotal.value > 0 &&
        state.labelTotal.value == state.scannedLabelTotal.value) {
      isSubmitting = true;
      state.submitScannedCartonLabel(
        success: (msg) {
          cleanAll(submitSuccess);
          showSnackBar(title: 'carton_label_scan_success'.tr, message: msg);
          isSubmitting = false;
        },
        error: (msg) {
          submitError.call();
          errorDialog(content: msg);
          isSubmitting = false;
        },
      );
    }
  }

  submit(Function refresh) {
    if (isSubmitting) return;
    isSubmitting = true;
    state.submitScannedCartonLabel(
      success: (msg) {
        cleanAll(refresh);
        successDialog(content: msg);
        isSubmitting = false;
      },
      error: (msg) {
        errorDialog(content: msg);
        isSubmitting = false;
      },
    );
  }

  changePriority() {
    if(scanController.text.isEmpty && state.priorityCartonLabelInfo==null){
      showSnackBar(message:'carton_label_scan_input_or_scan'.tr  );
    }else{
      state.changePOPriority(success: (mes) {
        successDialog(content: mes, back: () => {
          scanController.clear(),
          state.clearPriority()});
      }, poNumber: scanController.text.length!=20? scanController.text.toString() : state.priorityCartonLabelInfo!.custOrderNumber!.toString());
    }
  }

  queryScanHistory(String orderNo) {
    state.getCartonLabelScanHistory(
      orderNo: orderNo,
      error: (msg) => errorDialog(content: msg),
    );
  }

  getProgressDetail(CartonLabelScanProgressInfo data) {
    state.getCartonLabelScanHistoryDetail(
      id: data.interID ?? 0,
      success: () => Get.to(() => const CartonLabelScanProgressDetailView()),
      error: (msg) => errorDialog(content: msg),
    );
  }
}
