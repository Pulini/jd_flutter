import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/stuff_quality_inspection_info.dart';
import 'package:jd_flutter/fun/warehouse/in/quality_inspection_list/quality_inspection_list_state.dart';
import 'package:jd_flutter/fun/warehouse/in/stuff_quality_inspection/stuff_quality_inspection_view.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
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
  bool checkSameData() {
    var name = <String>[];
    for (var data in state.showDataList) {
      for (var c in data.where((v) => v.isSelected.value)) {
        if (!name.contains(c.inspectionOrderNo)) {
          name.add(c.inspectionOrderNo.toString());
        }
      }
    }
    return name.length == 1;
  }

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
          batch: '合计',
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
                    name: '',
                    code: data.materialCode,
                    color: '分色合计',
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
                    name: '',
                    code: data.materialCode,
                    color: '冲销合计',
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
        if (v.isSelected.value == true) {
          position = i;
          selectCode = v.code!;
          selectCode = v.name!;
        }
      });

      var subAllQty = 0.0;
      var remainQty = 0.0;

      state.showReceiptColorList
          .where((v) => v.code == selectCode && v.subItem == '1')
          .forEach((v) {
        subAllQty = subAllQty + v.qty!;
      });

      state.showReceiptColorList
          .where((v) => v.code == selectCode && v.subItem == '2')
          .forEach((v) {
        remainQty = v.allQty! - subAllQty;
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
      logger.f('没有');
    } else {
      allQty = state.showReceiptColorList
          .where((data) => data.code == selectCode && data.subItem == '1')
          .map((v) => v.qty ?? 0.0)
          .reduce((a, b) => a.add(b));
      logger.f('有');
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
        checkQty = checkQty + 1;
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
  colorSubmit({required String reason}) {
    state.colorSubmit(
      reason: reason,
      success: (msg) => successDialog(
        content: msg,
        back: () => Get.back(result: true),
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
    required Function() needColorSet,
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
              selectList: selected,
              success: () {
                needColorSet.call();
                //--------------
              },
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
}
