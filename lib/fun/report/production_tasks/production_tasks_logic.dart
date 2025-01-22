import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/production_tasks_info.dart';
import 'package:jd_flutter/fun/report/production_tasks/production_tasks_detail_view.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

import '../../../widget/dialogs.dart';
import 'production_tasks_state.dart';

class ProductionTasksLogic extends GetxController {
  final ProductionTasksState state = ProductionTasksState();

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  refreshTable({
    required Function() refresh,
  }) {
    state.getProductionOrderSchedule(
      success: () => refresh.call(),
      error: (msg) => showSnackBar(title: '错误', message: msg, isWarning: true),
    );
  }

  WorkCardSizeInfos getTotalItem() => WorkCardSizeInfos(
        size: '合计',
        qty: (state.orderList[0].workCardSizeInfo ?? [])
            .map((v) => v.qty ?? 0)
            .reduce((a, b) => a.add(b)),
        productScannedQty: (state.orderList[0].workCardSizeInfo ?? [])
            .map((v) => v.productScannedQty ?? 0)
            .reduce((a, b) => a.add(b)),
        manualScannedQty: (state.orderList[0].workCardSizeInfo ?? [])
            .map((v) => v.manualScannedQty ?? 0)
            .reduce((a, b) => a.add(b)),
        scannedQty: (state.orderList[0].workCardSizeInfo ?? [])
            .map((v) => v.scannedQty ?? 0)
            .reduce((a, b) => a.add(b)),
        installedQty: (state.orderList[0].workCardSizeInfo ?? [])
            .map((v) => v.installedQty ?? 0)
            .reduce((a, b) => a.add(b)),
      );

  ProductionTasksDetailItemInfo getDetailTotalItem() =>
      ProductionTasksDetailItemInfo(
        size: '合计',
        qty: state.detailTableInfo
            .map((v) => v.qty ?? 0)
            .reduce((a, b) => a.add(b)),
        productScannedQty: state.detailTableInfo
            .map((v) => v.productScannedQty ?? 0)
            .reduce((a, b) => a.add(b)),
        manualScannedQty: state.detailTableInfo
            .map((v) => v.manualScannedQty ?? 0)
            .reduce((a, b) => a.add(b)),
        scannedQty: state.detailTableInfo
            .map((v) => v.scannedQty ?? 0)
            .reduce((a, b) => a.add(b)),
        installedQty: state.detailTableInfo
            .map((v) => v.installedQty ?? 0)
            .reduce((a, b) => a.add(b)),
      );

  changeSort(
      {required int oldIndex,
      required int newIndex,
      required Function() refresh}) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    var newLine = <ProductionTasksSubInfo>[...state.orderList];
    newLine.insert(newIndex, newLine.removeAt(oldIndex));
    state.changeSort(
      newLine: newLine,
      success: (msg) {
        showSnackBar(
          title: 'molding_scan_bulletin_report_sort'.tr,
          message: msg,
        );
        refresh.call();
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  getDetail({String? ins, String? po, required String imageUrl}) {
    state.getProductionOrderScheduleDetail(
      ins: ins ?? '',
      po: po ?? '',
      success: () {
        if (ins != null && ins.isNotEmpty) {
          Get.to(
            () => const ProductionTasksDetailPage(),
            arguments: {'isInstruction': true, 'imageUrl': imageUrl},
          );
        } else if (po != null && po.isNotEmpty) {
          Get.to(
            () => const ProductionTasksDetailPage(),
            arguments: {'isInstruction': false, 'imageUrl': imageUrl},
          );
        }
      },
      error: (msg) => showSnackBar(title: '错误', message: msg, isWarning: true),
    );
  }
}
