import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/preview_label_list_widget.dart';
import 'package:jd_flutter/widget/preview_label_widget.dart';
import 'package:jd_flutter/widget/tsc_label_templates/110w_dynamic_label.dart';

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

  addPallet(Function() clearInput) {
    if (state.palletNo.value.isPallet()) {
      state.getPalletInfo(
        pallet: state.palletNo.value,
        success: (list) {
          _setPalletList(list);
          hidKeyboard();
          state.palletNo.value = '';
          clearInput.call();
        },
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
    } else {
      errorDialog(content: '托盘已存在！');
    }
  }

  deletePallet(int index) {
    state.palletList.removeAt(index);
    state.selectedList.removeAt(index);
  }

  printPallet() {
    var list = <Widget>[];
    for (var i = 0; i < state.selectedList.length; ++i) {
      if (state.selectedList[i].value) {
        var materialList = <List>[];
        var mixMaterialList = <List>[];
        var pieceList = <SapPalletDetailInfo>[];
        groupBy(state.palletList[i], (v) => v.pieceNo ?? '').forEach((k, v) {
          if (v.length > 1) {
            mixMaterialList.add([
              for (var item in v)
                [item.materialCode ?? '', item.quantity ?? 0, item.unit ?? '']
            ]);
          } else {
            pieceList.add(v.first);
          }
        });
        groupBy(pieceList, (v) => v.materialCode ?? '').forEach((k, v) {
          materialList.add([
            k,
            v.first.unit ?? '',
            v.map((v2) => v2.quantity ?? 0).toList(),
          ]);
        });
        list.add(dynamicPalletDetail(
          palletNo: state.palletList[i].first.palletNumber ?? '',
          materialList: materialList,
          mixMaterialList: mixMaterialList,
        ));
      }
    }
    toPrintView(list);
  }

  toPrintView(List<Widget> labelView) {
    Get.to(() => labelView.length > 1
        ? PreviewLabelList(labelWidgets: labelView, isDynamic: true)
        : PreviewLabel(labelWidget: labelView[0], isDynamic: true));
  }
}
