import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'print_pallet_state.dart';

class PrintPalletLogic extends GetxController {
  final PrintPalletState state = PrintPalletState();

  scanPallet(String code) {
    if (code.isPallet()) {
      state.getPalletInfo(
        pallet: code,
        success: _setPalletList,
        error: (msg) => errorDialog(content: msg),
      );
    } else {
      errorDialog(content: '请扫描托盘码！');
    }
  }

  addPallet() {
    if (state.palletNo.value.isPallet()) {
      state.getPalletInfo(
        pallet: state.palletNo.value,
        success: _setPalletList,
        error: (msg) => errorDialog(content: msg),
      );
    } else {
      errorDialog(content: '请输入正确的托盘号！');
    }
  }

  _setPalletList(List<SapPalletDetailInfo> list) {
    if (state.palletList
        .none((v) => v.first.palletNumber == list.first.palletNumber)) {
      state.palletList.add(list);
      state.selectedList.add(true.obs);
      state.palletNo.value='';
    } else {
      errorDialog(content: '托盘已存在！');
    }
  }

  deletePallet(int index) {
    state.palletList.removeAt(index);
    state.selectedList.removeAt(index);
  }
}
