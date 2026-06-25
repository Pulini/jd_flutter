import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/carton_label_scan_progress_info.dart';
import 'package:jd_flutter/fun/warehouse/manage/new_carton_label_scan/new_carton_label_scan_progress_detail_view.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'new_carton_label_scan_state.dart';

class NewCartonLabelScanLogic extends GetxController {
  final NewCartonLabelScanState state = NewCartonLabelScanState();
  var scanController = TextEditingController();

  var isSubmitting = false;

  void queryPriorityCartonLabelInfo({
    required String code,
  }) {
    state.queryCartonLabelInfo(
      code: code,
      success: (data) {
        state.priorityCartonLabelInfo = data;
        state.dispatchNumber.value = data.dispatchNumber ?? '';
        state.priorityCartonLabel.value =
            state.priorityCartonLabelInfo?.outBoxBarCode ?? '';
        state.priorityPo.value =
            state.priorityCartonLabelInfo?.custOrderNumber ?? '';
        state.priorityCartonInsideLabelList.value =
            state.priorityCartonLabelInfo!.linkDataSizeList ?? [];
      },
      error: (msg) {
        state.clearPriority();
        errorDialog(content: msg);
      },
    );
  }

  void queryCartonLabelInfo(String code) {
    state.labelTotal.value = 0;
    state.scannedLabelTotal.value = 0;
    state.queryCartonLabelInfo(
      code: code,
      success: (data) {
        state.cartonLabelInfo = data;
        state.dispatchNumber.value = data.dispatchNumber ?? '';
        state.cartonLabel.value = state.cartonLabelInfo?.outBoxBarCode ?? '';
        state.cartonInsideLabelList.value =
            state.cartonLabelInfo!.linkDataSizeList ?? [];
        state.labelTotal.value = state.cartonInsideLabelList
            .fold(0, (total, next) => total + next.labelCount!);
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  void cleanAll(Function refresh) {
    state.cartonInsideLabelList.value = [];
    state.cartonLabel.value = '';
    state.cartonLabelInfo = null;
    state.labelTotal.value = 0;
    state.scannedLabelTotal.value = 0;
    refresh.call();
  }

  Future<void> cleanScanned() async {
    for (var v in state.cartonInsideLabelList) {
      v.scanned = 0;
    }
    state.scannedLabelTotal.value = 0;
    state.cartonInsideLabelList.refresh();
  }

  void scan({
    required String code,
    required Function(String) outsideCode,
    required Function(String) insideCode,
    required Function() insideExpired,
    required Function() notOutsideCode,
    required Function() submitSuccess,
    required Function() submitError,
  }) {
    if (code.startsWith('P') && code.length > 5) {
      state.dispatchNumber.value = code;
      return;
    }
    // if(state.dispatchNumber.value.isEmpty){
    //   errorDialog(content: 'carton_label_scan_label_scan_dispatch_no_empty_tips'.tr);
    //   return;
    // }
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

  void submit(Function refresh) {
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

  void changePriority() {
    if (scanController.text.isEmpty && state.priorityCartonLabelInfo == null) {
      showSnackBar(message: 'carton_label_scan_input_or_scan'.tr);
    } else {
      state.changePOPriority(
          success: (mes) {
            successDialog(
                content: mes,
                back: () {
                  scanController.clear();
                  state.clearPriority();
                });
          },
          poNumber: scanController.text.length != 20
              ? scanController.text.toString()
              : state.priorityCartonLabelInfo!.custOrderNumber!.toString());
    }
  }

  void queryScanHistory(String orderNo) {
    state.getCartonLabelScanHistory(
      orderNo: orderNo,
      error: (msg) => errorDialog(content: msg),
    );
  }

  void getProgressDetail(CartonLabelScanProgressInfo data) {
    state.getCartonLabelScanHistoryDetail(
      id: data.interID ?? 0,
      success: () => Get.to(() => const NewCartonLabelScanProgressDetailView()),
      error: (msg) => errorDialog(content: msg),
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

              if (currentShortQty < currentLabelCount){
                if(state.tailScannedLabelTotal.value +1<state.tailLabelTotal.value){
                  a.thisShortQty = currentShortQty + 1;

                  showScanTips();
                  state.tailScannedLabelTotal.value += 1;
                  add.call();

                }else{
                  full.call();
                  if (Get.isDialogOpen == true) Get.back();
                  errorDialog(
                    content: 'carton_label_scan_order_not_full'.tr,
                  );
                }
              }else{
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

  Future<void> cleanDetailScanned() async {
    for (var v in state.outBoxList[state.showIndex].mantissaDataSizeList!) {
      v.thisShortQty = v.shortQty;
    }
    setTotalQty();
    state.outBoxList.refresh();
  }
}
