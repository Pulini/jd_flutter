import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/temporary_order_info.dart';
import 'package:jd_flutter/fun/warehouse/in/temporary_order/temporary_order_detail_view.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'temporary_order_state.dart';

class TemporaryOrderLogic extends GetxController {
  final TemporaryOrderState state = TemporaryOrderState();

  void queryTemporaryOrders({
    required String startDate,
    required String endDate,
    required String temporaryNo,
    required String productionNumber,
    required String factoryType,
    required String supplierName,
    required String materialCode,
    required String factoryArea,
    required String factoryNo,
    required String userNumber,
    required String trackNo,
  }) {
    state.getTemporaryList(
      startDate: startDate,
      endDate: endDate,
      temporaryNo: temporaryNo,
      productionNumber: productionNumber,
      factoryType: factoryType,
      supplierName: supplierName,
      materialCode: materialCode,
      factoryArea: factoryArea,
      factoryNo: factoryNo,
      userNumber: userNumber,
      trackNo: trackNo,
      error: (msg) => errorDialog(content: msg),
    );
  }

  void deleteTemporaryOrder({
    required String temporaryNo,
    required String reason,
    required Function(String) success,
  }) {
    state.deleteTemporaryOrder(
      reason: reason,
      temporaryNo: temporaryNo,
      success: success,
      error: (msg) => errorDialog(content: msg),
    );
  }

  void viewTemporaryOrderDetail({
    required String temporaryNo,
    required String materialCode,
    required Function()? success,
  }) {
    state.getTemporaryOrderDetail(
      temporaryNo: temporaryNo,
      materialCode: materialCode,
      success: () {
        Get.to(() => const TemporaryOrderDetailPage())?.then((v) {
          if (v == true) {
            success!.call();
          }
        });
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  bool checkToInspection() {
    var checkNum = 0;

    state.detailInfo!.receipt
        ?.where((data) => data.isSelected.value == true)
        .toList()
        .forEach((c) {
      if (c.inspectionQuantity! > 0 || c.hasLengthCheckData!.isNotEmpty) {
        checkNum = checkNum + 1;
      }
    });

    if (checkNum >= 1) {
      showSnackBar(message: 'quality_inspection_have_already'.tr);
      return false;
    } else {
      return true;
    }
  }

   void selectAllMaterial(TemporaryOrderDetailReceiptInfo data,bool isSelected) {
    state.detailInfo!.receipt!.where((v)=>v.materialCode==data.materialCode).forEach((v){
      v.isSelected.value=isSelected;
    });
   }
}
