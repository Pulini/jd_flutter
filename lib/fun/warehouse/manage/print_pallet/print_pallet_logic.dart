import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/printer/pdf_paper_template.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/preview_label_list_widget.dart';
import 'package:jd_flutter/widget/preview_label_widget.dart';
import 'package:jd_flutter/widget/tsc_label_templates/dynamic_label_110w.dart';
import 'package:jd_flutter/widget/web_page.dart';

import 'print_pallet_state.dart';

class PrintPalletLogic extends GetxController {
  final PrintPalletState state = PrintPalletState();

  void scanPallet(String code) {
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

  void addPallet(Function() clearInput) {
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

  void _setPalletList(List<SapPalletDetailInfo> list) {
    if (state.palletList
        .none((v) => v.first.palletNumber == list.first.palletNumber)) {
      state.palletList.add(list);
      state.selectedList.add(true.obs);
    } else {
      errorDialog(content: '托盘已存在！');
    }
  }

  void deletePallet(int index) {
    state.palletList.removeAt(index);
    state.selectedList.removeAt(index);
  }

  void printPallet() {
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

  void printPalletSizeMaterial() {
    // var pdf = pw.Document();
    // var a4PaperByteList = <Uint8List>[];
    var printTask = <List>[];
    for (var i = 0; i < state.selectedList.length; ++i) {
      if (state.selectedList[i].value) {
        // palletList.add(state.palletList[i].first.palletNumber ?? '');
        //尺码物料组
        var sizeMaterialTable = <List>[];
        var sizeMaterials =
            state.palletList[i].where((v) => !v.size.isNullOrEmpty()).toList();

        //一般物理组
        var materialTable = <List>[];
        var materials =
            state.palletList[i].where((v) => v.size.isNullOrEmpty()).toList();

        groupBy(sizeMaterials, (v) => v.instructionsNo ?? '').forEach((k1, v1) {
          var sizeList = groupBy(v1, (v) => v.size ?? '').keys.toList();
          sizeList.sort((a, b) => a.compareTo(b));

          var sizeMaterialList = <SapPalletDetailInfo>[];
          var singleDataList = <Map<String, List<double>>>[];
          var singleListTotalQty = 0.0;
          var singleListTotalPiece = 0;

          var mixMaterialList = <List<SapPalletDetailInfo>>[];
          var mixDataList = <Map<String, List<List>>>[];
          var mixListTotalQty = 0.0;
          var mixListTotalPiece = 0;

          groupBy(v1, (v) => v.pieceNo ?? '').forEach((k, v) {
            if (v.length > 1) {
              // debugPrint('--件：$k 混装< ${v.map((v2)=>'尺码：${v2.size}  数量：${v2.quantity}').toList()} >');
              mixMaterialList.add(v);
              mixListTotalQty = mixListTotalQty.add(
                  v.map((v) => v.quantity ?? 0.0).reduce((a, b) => a.add(b)));
              mixListTotalPiece++;
            } else {
              // debugPrint('--件：$k 单装< ${v.first.size}  数量：${v.first.quantity}>');
              sizeMaterialList.add(v.first);
              singleListTotalQty =
                  singleListTotalQty.add(v.first.quantity ?? 0.0);
              singleListTotalPiece++;
            }
          });

          for (var size in sizeList) {
            if (sizeMaterialList.any((v) => v.size == size)) {
              singleDataList.add({
                size: sizeMaterialList
                    .where((v) => v.size == size)
                    .map((v) => v.quantity ?? 0)
                    .toList()
              });
            }
          }

          for (var m in mixMaterialList) {
            mixDataList.add({
              m.first.pieceNo ?? '': [
                for (var size in sizeList)
                  if (m.any((v) => v.size == size))
                    [size, m.firstWhere((v) => v.size == size).quantity ?? 0.0]
              ]
            });
          }

          // debugPrint('----------singleDataList：$singleDataList');
          // debugPrint('----------mixDataList：$mixDataList');

          sizeMaterialTable.add([
            k1,
            singleDataList,
            singleListTotalQty,
            singleListTotalPiece,
            mixDataList,
            mixListTotalQty,
            mixListTotalPiece,
          ]);
        });

        groupBy(materials, (v) => v.materialCode ?? '').forEach((k1, v1) {
          materialTable.add([
            k1,
            v1.first.unit ?? '',
            v1.map((v2) => v2.quantity ?? 0.0).toList(),
          ]);
        });

        printTask.add([
          createA4PaperMaterialListPdf(
            paperTitle: '金帝集团股份有限公司托盘清单',
            factoryName: state.palletList[i].first.factoryName ?? '',
            orderType: state.palletList[i].first.orderType ?? '',
            customsDeclarationType:
                state.palletList[i].first.customsDeclarationType ?? '',
            palletNumber: state.palletList[i].first.palletNumber ?? '',
            sizeMaterialTable: sizeMaterialTable,
            materialTable: materialTable,
          ),
          state.palletList[i].first.palletNumber ?? ''
        ]);
      }
    }
    debugPrint('printTask=${printTask.length}');
    Get.to(() => WebPrinter(palletTaskList: printTask));
  }

  void toPrintView(List<Widget> labelView) {
    Get.to(() => labelView.length > 1
        ? PreviewLabelList(labelWidgets: labelView, isDynamic: true)
        : PreviewLabel(labelWidget: labelView[0], isDynamic: true));
  }

  void deleteLabel() {
    var list = <List<String>>[];
    for (var p in state.palletList) {
      for (var label in p.where((v) => v.isSelect.value)) {
        list.add([label.palletNumber ?? '', label.pieceNo ?? '']);
      }
    }
    state.deleteLabel(
      list: list,
      success: (msg) {
        for (var p in state.palletList) {
          p.removeWhere((v) => v.isSelect.value);
        }
        for (var i = 0; i < state.palletList.length; ++i) {
          if (state.palletList[i].isEmpty) {
            state.selectedList.removeAt(i);
          }
        }
        state.palletList.removeWhere((v) => v.isEmpty);
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  bool isSelectedAllItem(int index) =>
      state.palletList[index].every((v) => v.isSelect.value);

  void selectAllSubItem(int index, bool isSelect) {
    for (var v in state.palletList[index]) {
      v.isSelect.value = isSelect;
    }
  }
}
