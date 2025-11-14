import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_info.dart';
import 'package:jd_flutter/fun/warehouse/in/sap_put_on_shelves/sap_put_on_shelves_scan_view.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'sap_put_on_shelves_state.dart';

class SapPutOnShelvesLogic extends GetxController {
  final SapPutOnShelvesState state = SapPutOnShelvesState();

  void refreshLabelList({
    required String warehouse,
    required Function() refresh,
  }) {
    state.getPalletList(
      warehouse: warehouse,
      refresh: refresh,
      error: (msg) => errorDialog(content: msg),
    );
  }

  void scanCode({
    required String code,
    required String warehouse,
    required Function() refresh,
  }) {
    if (code.isPallet()) {
      var index =
          state.labelList.indexWhere((v) => v[0][0].palletNumber == code);
      if (index == -1) {
        errorDialog(content: 'sap_put_on_shelves_not_find_pallet'.tr);
      } else {
        _goScan(index, warehouse, refresh);
      }
      return;
    }
    if (code.isLabel()) {
      var index = state.labelList.indexWhere(
          (v) => v.any((v2) => v2.any((v3) => v3.labelNumber == code)));
      if (index == -1) {
        errorDialog(content: 'sap_put_on_shelves_not_find_label'.tr);
      } else {
        _goScan(index, warehouse, refresh);
      }
      return;
    }
  }

  void _goScan(int index, String warehouse, Function() refresh) {
    Get.to(
      () => const SapPutOnShelvesScanPage(),
      arguments: {'index': index, 'warehouse': warehouse},
    )?.then((v) {
      if (v != null && v) {
        refreshLabelList(warehouse: warehouse, refresh: refresh);
      }
    });
  }

  void initLabelList({
    required int index,
    required Function(String) location,
  }) {
    var list = <PalletDetailItem1Info>[];
    for (var v in state.labelList[index]) {
      list.addAll(v);
    }
    state.scanLabelList.value = list;
    state.palletNumber.value = list[0].palletNumber ?? '';
    state.getRecommendLocation(
      factory: state.scanLabelList[0].factoryNumber ?? '',
      warehouse: state.scanLabelList[0].warehouseNumber ?? '',
      palletNumber: state.scanLabelList[0].palletNumber ?? '',
      location: location,
      error: (msg) => errorDialog(content: msg),
    );
  }

  void puttingOnShelves({
    required String location,
    required String warehouse,
    required Function() refresh,
  }) {
    if (location.isEmpty) {
      showSnackBar(
        message: 'sap_put_on_shelves_input_storage_location'.tr,
        isWarning: true,
      );
    } else {
      state.puttingOnShelves(
        warehouse: warehouse,
        location: location,
        success: (msg) => successDialog(content: msg, back: refresh),
        error: (msg) => errorDialog(content: msg),
      );
    }
  }
}
