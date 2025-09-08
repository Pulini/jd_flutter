import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/stuff_quality_inspection_info.dart';
import 'package:jd_flutter/fun/warehouse/in/quality_inspection_list/quality_inspection_list_color_binding_label_view.dart';
import 'package:jd_flutter/fun/warehouse/in/quality_inspection_list/quality_inspection_list_state.dart';
import 'package:jd_flutter/fun/warehouse/in/stuff_quality_inspection/stuff_quality_inspection_view.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class QualityInspectionListLogic extends GetxController {
  final QualityInspectionListState state = QualityInspectionListState();

  List<StuffQualityInspectionInfo> getSelectData() => [
        for (var data in state.showDataList)
          ...data.where((v) => v.isSelected.value)
      ];

  //获取品检单列表
  getInspectionList({
    required int orderType,
    required String typeBody,
    required String materialCode,
    required String instruction,
    required String inspectionOrder,
    required String temporaryReceipt,
    required String receiptVoucher,
    required String trackingNumber,
    required String startDate,
    required String endDate,
    required String supplier,
    required String sapCompany,
    required String factory,
  }) {
    state.orderType.value = orderType;
    state.getInspectionList(
      typeBody: typeBody,
      materialCode: materialCode,
      instruction: instruction,
      inspectionOrder: inspectionOrder,
      temporaryReceipt: temporaryReceipt,
      receiptVoucher: receiptVoucher,
      trackingNumber: trackingNumber,
      startDate: startDate,
      endDate: endDate,
      supplier: supplier,
      sapCompany: sapCompany,
      factory: factory,
      error: (msg) => errorDialog(content: msg),
    );
  }

  //删除判断
  checkDelete({
    required Function success,
  }) {
    if (checkUserPermission('105180503')) {
      if (state.showDataList.any((v) => v.any((v2) => v2.isSelected.value))) {
        if (checkSameData()) {
          success.call();
        } else {
          showSnackBar(message: 'quality_inspection_different_order'.tr);
        }
      } else {
        showSnackBar(message: 'quality_inspection_select_data'.tr);
      }
    } else {
      showSnackBar(message: 'quality_inspection_no_delete'.tr);
    }
  }

  //验证是否是同一个品检单
  bool checkSameData() =>
      groupBy(<StuffQualityInspectionInfo>[
        for (var data in state.showDataList)
          ...data.where((v) => v.isSelected.value)
      ], (v) => v.inspectionOrderNo ?? '').length ==
      1;

  //删除品检单
  deleteData({
    required String reason,
    required Function() refresh,
  }) {
    state.deleteOrder(
      reason: reason,
      success: (msg) => successDialog(content: msg, back: refresh),
      error: (msg) => errorDialog(content: msg),
    );
  }

  //入库
  store({
    required String date,
    required String store1,
    required Function() refresh,
  }) {
    state.store(
      date: date,
      store1: store1,
      success: (msg) => successDialog(
        content: msg,
        back: refresh,
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  //验证是否是同一个检验单
  checkSame({
    required Function success,
  }) {
    if (state.showDataList.any((v) => v.any((v2) => v2.isSelected.value))) {
      if (checkSameData()) {
        success.call();
      } else {
        showSnackBar(message: 'quality_inspection_different_order'.tr);
      }
    } else {
      showSnackBar(message: 'quality_inspection_select_data'.tr);
    }
  }

  //获取品检单货位信息
  getLocation({
    required String store,
    required Function(List<StuffQualityInspectionDetailInfo>) success,
  }) {
    state.getLocation(
      store: store,
      success: (list) => success.call(list),
      error: (msg) => errorDialog(content: msg),
    );
  }

  //更改货位
  changeLocation({
    required String location,
    required List<StuffQualityInspectionDetailInfo> locationList,
    required Function() refresh,
  }) {
    state.changeLocation(
      location: location,
      locationList: locationList,
      success: (msg) => successDialog(content: msg, back: refresh),
      error: (msg) => errorDialog(content: msg),
    );
  }

  //获取分色信息
  getColor({required Function(List<StuffColorSeparationList>) callback}) {
    state.getLocation(
      success: (list) {
        var colors = <StuffColorSeparationList>[];
        var allQty = 0.0;
        for (var data in list) {
          data.stuffColorSeparationList?.forEach((sub) {
            allQty = allQty.add(sub.colorSeparationQuantity.toDoubleTry());
            colors.add(sub);
          });
        }
        colors.add(StuffColorSeparationList(
          batch: 'quality_inspection_color_item_total'.tr,
          colorSeparationQuantity: allQty.toShowString(),
        ));
        callback.call(colors);
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  //验证是否可以冲销
  receiptReversal(
      {required Function() reason, required Function() toReverseColor}) {
    if (state.showDataList.any((v) => v.any((v2) => v2.isSelected.value))) {
      if (checkSameData()) {
        state.reversal(
          success: (list) {
            if (list.isNotEmpty) {
              var selectList = getSelectData();
              var showList = <QualityInspectionShowColor>[];

              for (String name
                  in groupBy(selectList, (v) => v.materialCode ?? '').keys) {
                for (var data
                    in list.where((receipt) => receipt.materialCode == name)) {
                  data.item?.forEach((sub) {
                    showList.add(QualityInspectionShowColor(
                      subItem: '1',
                      name: data.materialDescription,
                      code: data.materialCode,
                      color: sub.batch,
                      qty: sub.qty,
                      allQty: 0.0,
                    ));
                  });

                  showList.add(QualityInspectionShowColor(
                    subItem: '2',
                    name: data.materialDescription,
                    code: data.materialCode,
                    color: 'quality_inspection_item_color_total'.tr,
                    qty: data.item
                            ?.map((v) => v.qty ?? 0.0)
                            .reduce((a, b) => a.add(b)) ??
                        0.0,
                    allQty: data.item
                            ?.map((v) => v.qty ?? 0.0)
                            .reduce((a, b) => a.add(b)) ??
                        0.0,
                  ));

                  showList.add(QualityInspectionShowColor(
                    subItem: '3',
                    name: data.materialDescription,
                    code: data.materialCode,
                    color: 'quality_inspection_item_reverse_total'.tr,
                    qty: selectList
                        .where((select) => select.materialCode == name)
                        .map((v) => v.storageQuantity.toDoubleTry())
                        .reduce((a, b) => a.add(b)),
                    allQty: 0.0,
                  ));
                }
              }
              state.showReceiptColorList.value = showList;
              toReverseColor.call();
            }
          },
          error: reason,
        );
      } else {
        showSnackBar(message: 'quality_inspection_different_order'.tr);
      }
    } else {
      showSnackBar(message: 'quality_inspection_select_data'.tr);
    }
  }

  //选中分色数据
  selectColorSubItem(int position) {
    for (var sub in state.showReceiptColorList.where((v) => v.subItem == '1')) {
      sub.isSelected.value = false;
    }

    state.showReceiptColorList[position].isSelected.value = true;
    state.showReceiptColorList.refresh();
  }

  //是否选中数据
  bool havaColorSelect() {
    if (state.showReceiptColorList.none((v) => v.isSelected.value == true)) {
      showSnackBar(message: 'quality_inspection_color_select'.tr);
      return false;
    } else {
      return true;
    }
  }

  //新增
  colorAdd() {
    if (havaColorSelect()) {
      var position = 0;
      var selectCode = '';
      var selectName = '';

      state.showReceiptColorList.forEachIndexed((i, v) {
        if (v.isSelected.value == true && v.subItem == '1') {
          position = i;
          selectCode = v.code!;
          selectName = v.name!;
        }
      });

      var subAllQty = 0.0;
      var remainQty = 0.0;

      state.showReceiptColorList
          .where((v) => v.code == selectCode && v.subItem == '1')
          .forEach((v) {
        subAllQty = subAllQty.add(v.qty!);
      });

      state.showReceiptColorList
          .where((v) => v.code == selectCode && v.subItem == '3')
          .forEach((v) {
        remainQty = v.allQty!.sub(subAllQty);
      });

      if (remainQty <= 0) {
        showSnackBar(message: 'quality_inspection_no_qty'.tr);
      } else {
        state.showReceiptColorList.insert(
            position + 1,
            QualityInspectionShowColor(
              subItem: '1',
              name: selectName,
              code: selectCode,
              color: '',
              qty: remainQty,
            ));
        state.showReceiptColorList
                .firstWhere(
                    (data) => data.code == selectCode && data.subItem == '2')
                .qty =
            state.showReceiptColorList
                .where((data) => data.subItem == '1' && data.code == selectCode)
                .toList()
                .map((v) => v.qty ?? 0)
                .reduce((a, b) => a.add(b));
        state.showReceiptColorList.refresh();
      }
    }
  }

  //设置分色数量
  colorInputQty(double qty, int position, String code) {
    state.showReceiptColorList[position].qty = qty;
    state.showReceiptColorList.refresh();
    setShowColorAllQty(code);
  }

  //设置分色合计
  setShowColorAllQty(String selectCode) {
    var allQty = 0.0;

    if (state.showReceiptColorList
        .none((data) => data.code == selectCode && data.subItem == '1')) {
      allQty = 0.0;
    } else {
      allQty = state.showReceiptColorList
          .where((data) => data.code == selectCode && data.subItem == '1')
          .map((v) => v.qty ?? 0.0)
          .reduce((a, b) => a.add(b));
    }

    for (var c in state.showReceiptColorList) {
      if (c.code == selectCode && c.subItem == '2') {
        c.qty = allQty;
      }
    }
  }

  //输入色系
  inputColor(String inputColor, int position) {
    state.showReceiptColorList[position].color = inputColor;
    state.showReceiptColorList.refresh();
  }

  //删除
  colorDelete() {
    var position = 0;
    var selectCode = '';

    state.showReceiptColorList.forEachIndexed((i, v) {
      if (v.isSelected.value == true) {
        position = i;
        selectCode = v.code!;
      }
    });

    if (havaColorSelect()) {
      state.showReceiptColorList.removeAt(position);
    }
    setShowColorAllQty(selectCode);
  }

  //验证是否可以提交
  bool checkSubmit() {
    var checkQty = 0;
    for (var s
        in groupBy(state.showReceiptColorList, (v) => v.code ?? '').keys) {
      if ((state.showReceiptColorList
              .where((data) => data.code == s && data.subItem == '2')
              .toList()[0]
              .qty) !=
          (state.showReceiptColorList
              .where((data) => data.code == s && data.subItem == '3')
              .toList()[0]
              .qty)) {
        checkQty++;
      }
    }

    if (checkQty == 0) {
      return true;
    } else {
      showSnackBar(message: 'quality_inspection_color_no_same'.tr);
      return false;
    }
  }

  //提交
  colorSubmit({
    required String reason,
    required Function() success,
  }) {
    state.colorSubmit(
      reason: reason,
      success: (msg) => successDialog(
        content: msg,
        back: () => success.call(),
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

//验证是否可以品检
  inspection({
    required Function() refresh,
  }) {
    if (checkUserPermission('105180502')) {
      if (state.showDataList.any((v) => v.any((v2) => v2.isSelected.value))) {
        if (checkSameData()) {
          Get.to(() => const StuffQualityInspectionPage(), arguments: {
            'inspectionType': '1',
            //品检单列表
            'dataList':
                jsonEncode(getSelectData().map((v) => v.toJson()).toList()),
            //品检单列表
          })?.then((v) {
            if (v) refresh.call();
          });
        } else {
          showSnackBar(message: 'quality_inspection_different_order'.tr);
        }
      } else {
        showSnackBar(message: 'quality_inspection_select_data'.tr);
      }
    } else {
      showSnackBar(message: 'quality_inspection_no_inspection'.tr);
    }
  }

  String inspectionTotalQtyText(List<StuffQualityInspectionInfo> list) => list
      .map((v) => v.inspectionQuantity.toDoubleTry())
      .reduce((a, b) => a.add(b))
      .toShowString();

  String samplingTotalQtyText(List<StuffQualityInspectionInfo> list) => list
      .map((v) => v.samplingQuantity.toDoubleTry())
      .reduce((a, b) => a.add(b))
      .toShowString();

  String unqualifiedTotalQtyText(List<StuffQualityInspectionInfo> list) => list
      .map((v) => v.unqualifiedQuantity.toDoubleTry())
      .reduce((a, b) => a.add(b))
      .toShowString();

  String shortCodesTotalQtyText(List<StuffQualityInspectionInfo> list) => list
      .map((v) => v.shortCodesNumber.toDoubleTry())
      .reduce((a, b) => a.add(b))
      .toShowString();

  String qualifiedTotalQtyText(List<StuffQualityInspectionInfo> list) => list
      .map((v) => v.qualifiedQuantity.toDoubleTry())
      .reduce((a, b) => a.add(b))
      .toShowString();

  String storageTotalQtyText(List<StuffQualityInspectionInfo> list) => list
      .map((v) => v.storageQuantity.toDoubleTry())
      .reduce((a, b) => a.add(b))
      .toShowString();

  checkOrderType({
    required Function() bindingLabel,
    required Function() stockIn,
  }) {
    if (checkUserPermission('105180401')) {
      var selected = getSelectData();
      if (selected.isNotEmpty) {
        var name = groupBy(selected, (v) => v.taxCode ?? '').keys;
        if (name.length > 1) {
          showSnackBar(message: 'quality_inspection_different_order'.tr);
        } else {
          if (selected.any((v) => v.colorDistinguishEnable == true)) {
            state.getOrderColorLabelInfo(
              selectList: groupBy(
                selected.where((v) => v.colorDistinguishEnable == true),
                (v) => v.inspectionOrderNo ?? '',
              ).keys.toList(),
              success: bindingLabel,
              error: (msg) => errorDialog(content: msg),
            );
          } else {
            stockIn.call();
          }
        }
      } else {
        showSnackBar(message: 'quality_inspection_select_data'.tr);
      }
    } else {
      showSnackBar(message: 'quality_inspection_no_store_inspection'.tr);
    }
  }

  List<QualityInspectionLabelBindingInfo> getColorMaterialLabelList(int index) {
    var material = state.colorOrderList[index].materialCode ?? '';
    var labelList = <QualityInspectionLabelBindingInfo>[];
    var usedLabel = <QualityInspectionLabelBindingInfo>[];
    for (var i = 0; i < state.colorOrderList.length; ++i) {
      if (i != index) {
        usedLabel.addAll(state.colorOrderList[i].bindingLabels);
      }
    }
    for (var label in state.labelList) {
      for (var m in label.materialList!) {
        labelList.add(QualityInspectionLabelBindingInfo(
          pieceNo: label.pieceNo ?? '',
          labelID: label.labelID ?? '',
          materialNumber: m.materialNumber ?? '',
          materialName: m.materialName ?? '',
          commonQty: m.commonQty ?? 0,
          commonUnit: m.commonUnit ?? '',
        )..isScanned.value = state.colorOrderList[index].bindingLabels.any(
            (v) => v.dataId() == m.dataId(),
          ));
      }
    }

    for (var used in usedLabel) {
      if (labelList.any((v) => v.dataId() == used.dataId())) {
        labelList.removeWhere((v) => v.dataId() == used.dataId());
      }
    }
    return labelList.where((v) => v.materialNumber == material).toList();
  }

  scanLabel(String code, QualityInspectionColorInfo colorInfo) {
    if (colorInfo.bindingLabels.isNotEmpty &&
        colorInfo.bindingLabels.any((v) => v.labelID == code)) {
      errorDialog(content: 'quality_inspection_label_exists_tips'.tr);
    } else {
      late QualityInspectionLabelInfo label;
      late QualityInspectionLabelMaterialInfo labelMaterial;
      try {
        label = state.labelList.firstWhere((v) => v.labelID == code);
      } on StateError catch (_) {
        errorDialog(content: 'quality_inspection_label_error_tips'.tr);
        return;
      }
      try {
        labelMaterial = label.materialList!
            .firstWhere((v) => v.materialNumber == colorInfo.materialCode);
      } on StateError catch (_) {
        errorDialog(content: 'quality_inspection_label_color_error_tips'.tr);
        return;
      }

      try {
        var bound = state.colorOrderList.firstWhere(
          (v) => v.bindingLabels
              .any((v2) => v2.dataId() == labelMaterial.dataId()),
        );
        errorDialog(
            content: 'quality_inspection_label_has_bond_tips'.trArgs(
          [bound.batchNo ?? ''],
        ));
      } on StateError catch (_) {
        var surplusQty = colorInfo.qty.sub(colorInfo.getMaterialTotalQty());
        if (surplusQty < (labelMaterial.commonQty ?? 0)) {
          errorDialog(
              content: 'quality_inspection_label_qty_exceed_tips'.trArgs(
            [
              labelMaterial.commonQty.toShowString(),
              surplusQty.toShowString(),
            ],
          ));
        } else {
          colorInfo.bindingLabels.add(state.scanList
              .firstWhere((v) => v.dataId() == labelMaterial.dataId())
            ..isScanned.value = true);
          state.scanList.refresh();
        }
      }
    }
  }

  selectAllData(bool select) {
    for (var data in state.showDataList) {
      for (var subData in data) {
        subData.isSelected.value = select;
      }
    }
    state.showDataList.refresh();
  }

  submitColorLabelBinding({
    required String location,
    required String postDate,
  }) {
    state.colorLabelBindingStockIn(
      location: location,
      postDate: postDate,
      success: (msg) => successDialog(
          content: msg,
          back: () {
            Get.back(result: true);
            state.colorOrderList.clear();
            state.labelList.clear();
          }),
      error: (msg) => errorDialog(content: msg),
    );
  }

  toColorLabelBinding(int index) {
    state.scanList.value = getColorMaterialLabelList(index);
    Get.to(() => const ColorBindingLabelPage(), arguments: {'index': index});
  }
}
