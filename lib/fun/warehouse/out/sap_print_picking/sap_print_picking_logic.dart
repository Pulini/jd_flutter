import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'sap_print_picking_state.dart';

class SapPrintPickingLogic extends GetxController {
  final SapPrintPickingState state = SapPrintPickingState();

  queryOrder({
    required String instructionNo,
    required String typeBody,
    required String picker,
    required String purchaseOrder,
    required String supplier,
    required String noticeNo,
    required String startDate,
    required String endDate,
    required String workCenter,
    required String factory,
    required String warehouse,
    required int orderType,
  }) {
    state.getMaterialPickingOrderList(
      instructionNo: instructionNo,
      typeBody: typeBody,
      process: 'PQ',
      picker: picker,
      purchaseOrder: purchaseOrder,
      supplier: supplier,
      noticeNo: noticeNo,
      orderType: orderType == 2 ? 3 : orderType,
      startDate: startDate,
      endDate: endDate,
      workCenter: workCenter,
      warehouse: warehouse,
      error: (msg) => errorDialog(content: msg),
    );
  }

  getOrderDetail() {
    state.getMaterialPickingOrderDetail(
      error: (msg) => errorDialog(content: msg),
    );
  }

  scanCode(String code) {
    if (state.orderDetailOrderList.any((v) => v.order.location == '1001') ==
        true) {
      showSnackBar(
        message: 'sap_print_picking_raw_material_no_need_scan'.tr,
        isWarning: true,
      );
      return;
    }
    if (code.isLabel()) {
      try {
        var label =
            state.orderDetailLabels.firstWhere((v) => v.labelCode == code);
        //不在标签列表内 或标签类型为禁止领料
        if (label.pickingType == 'B2') {
          showSnackBar(
            message: 'sap_print_picking_label_not_belong_pick_order'.tr,
            isWarning: true,
          );
          return;
        }
        if (label.distribution.isNotEmpty) {
          showSnackBar(
            message: 'sap_print_picking_label_scanned'.tr,
            isWarning: true,
          );
          return;
        }
        //标签类型为整箱领料需要判断是否超过需求数量
        if (label.pickingType == 'B0') {
          double materialRemainder = state.orderDetailOrderList
              .where((v) {
                if (v.order.orderType == '3') {
                  return v.order.sizeMaterialNumber == label.sizeMaterialCode;
                } else {
                  return v.order.materialNumber == label.materialCode;
                }
              })
              .map((v) => v.order.getRemainder())
              .reduce((a, b) => a.add(b));

          if (materialRemainder < (label.quantity ?? 0)) {
            showSnackBar(
              message:
                  'sap_print_picking_exceed_material_pick_requirements_tips'.tr,
              isWarning: true,
            );
            return;
          }
        }
        distributionLabel(label);
        if (label.distribution.isEmpty) {
          var surplus = state.orderDetailOrderList
              .where((v) {
                if (v.order.orderType == '3') {
                  return v.order.sizeMaterialNumber == label.sizeMaterialCode;
                } else {
                  return v.order.materialNumber == label.materialCode;
                }
              })
              .map((v) => v.pickQty)
              .reduce((a, b) => a.add(b));
          successDialog(
            content: 'sap_print_picking_contents_cargo_box_exceed_pick_qty_tips'
                .trArgs([
              surplus.toShowString(),
            ]),
          );
        }
      } catch (e) {
        //不在标签列表内 或标签类型为禁止领料
        showSnackBar(
          message: 'sap_print_picking_label_not_belong_pick_order'.tr,
          isWarning: true,
        );
        return;
      }
      showScanTips();
      state.orderDetailLabels.refresh();

      return;
    }

    if (code.isPallet()) {
      List<SapPickingDetailLabelInfo> pallet = state.orderDetailLabels
          .where((v) =>
              v.palletNumber == code &&
              (v.pickingType == 'B0' || v.pickingType == 'B1'))
          .toList();
      if (pallet.isEmpty) {
        showSnackBar(
          message: 'sap_print_picking_label_not_belong_pick_order'.tr,
          isWarning: true,
        );
        return;
      }
      if (pallet.every((v) => v.distribution.isNotEmpty)) {
        showSnackBar(
          message: 'sap_print_picking_label_scanned'.tr,
          isWarning: true,
        );
        return;
      }
      pallet.where((v) => v.distribution.isEmpty).forEach((label) {
        if (label.pickingType == 'B0') {
          double materialRemainder = state.orderDetailOrderList
              .where((v) {
                if (v.order.orderType == '3') {
                  return v.order.sizeMaterialNumber == label.sizeMaterialCode;
                } else {
                  return v.order.materialNumber == label.materialCode;
                }
              })
              .map((v) => v.order.getRemainder())
              .reduce((a, b) => a.add(b));
          if (materialRemainder >= (label.quantity ?? 0)) {
            distributionLabel(label);
          }
        } else {
          distributionLabel(label);
        }
      });
      var msgList = <String>[];
      pallet.where((v) => v.distribution.isEmpty).forEach((label) {
        var surplus = state.orderDetailOrderList
            .where((v) {
              if (v.order.orderType == '3') {
                return v.order.sizeMaterialNumber == label.sizeMaterialCode;
              } else {
                return v.order.materialNumber == label.materialCode;
              }
            })
            .map((v) => v.pickQty)
            .reduce((a, b) => a.add(b));
        msgList.add(
          'sap_print_picking_label_exceed_order_surplus_qty_tips'.trArgs([
            label.size ?? '',
            label.quantity.toShowString(),
            label.unit ?? '',
            surplus.toShowString(),
          ]),
        );
      });
      if (msgList.isNotEmpty) {
        errorDialog(content: msgList.join('\n'));
      }

      showScanTips();
      state.orderDetailLabels.refresh();

      return;
    }
    showSnackBar(
      message: 'sap_print_picking_scan_wrong_barcode_tips'.tr,
      isWarning: true,
    );
  }

  distributionLabel(SapPickingDetailLabelInfo label) {
    //整箱分配
    state.orderDetailOrderList.where((v) {
      if (v.order.orderType == '3') {
        return v.order.sizeMaterialNumber == label.sizeMaterialCode;
      } else {
        return v.order.materialNumber == label.materialCode;
      }
    }).forEach((v) {
      //剩余可领 >= 本箱数量 说明本箱物料可以分配给此行工单
      if (v.order.getRemainder() >= (label.quantity ?? 0) &&
          label.distribution.isEmpty) {
        //给标签添加分配信息
        label.distribution.add(
            //全部分完 分配数量为箱容
            DistributableInfo(v.dataId, label.quantity ?? 0));

        //累加所有分配到此工单箱容
        v.pickQty = getSum(v.dataId);
      }
    });

    //分配失败 拆箱分配
    if (label.distribution.isEmpty == true) {
      var disQty = 0.0;
      state.orderDetailOrderList.where((v) {
        if (v.order.orderType == '3') {
          return v.order.sizeMaterialNumber == label.sizeMaterialCode;
        } else {
          return v.order.materialNumber == label.materialCode;
        }
      }).forEach((v) {
        var surplus = label.quantity.sub(disQty);
        if (surplus > 0) {
          var qty = 0.0;
          if (surplus > v.order.getRemainder()) {
            qty = v.order.getRemainder();
          } else {
            qty = surplus;
          }
          label.distribution.add(DistributableInfo(v.dataId, qty));
          v.pickQty = getSum(v.dataId);
          disQty = disQty.add(qty);
        }
      });
    }
    state.orderDetailOrderList.refresh();
  }

  getSum(int dataId) {
    var sum = 0.0;
    sum = state.orderDetailLabels.map((v) {
      return v.distribution.isEmpty
          ? 0.0
          : v.distribution
              .where((v2) => v2.ascriptionId == dataId)
              .map((v2) => v2.qty)
              .reduce((a, b) => a.add(b));
    }).reduce((a, b) => a.add(b));
    return sum;
  }

  checkSubmitSelect({
    required Function(bool, List<PrintPickingDetailInfo>) pick,
  }) {
    var selectList = state.orderDetailOrderList
        .where((v) => v.select && v.canPicking())
        .toList();
    if (selectList.isEmpty) {
      showSnackBar(
        message: 'sap_print_picking_select_pick_material'.tr,
        isWarning: true,
      );
      return;
    }
    var rawMaterial = selectList.any((v) => v.order.location == '1001');
    var sizeMaterial = selectList.any((v) => v.order.location != '1001');
    if (rawMaterial && sizeMaterial) {
      showSnackBar(
        message: 'sap_print_picking_material_size_type_different_tips'.tr,
        isWarning: true,
      );
      return;
    }
    if (rawMaterial) {
      pick.call(false, selectList);
    } else {
      var msgList = <String>[];
      for (var v in selectList) {
        var surplus = v.order.getRemainder().sub(v.pickQty);
        if (surplus > 0) {
          msgList.add(
            'sap_print_picking_pick_still_unfinished_tips'.trArgs([
              v.order.typeBody ?? '',
              surplus.toShowString(),
            ]),
          );
        }
      }
      if (msgList.isNotEmpty) {
        askDialog(
          content: 'sap_print_picking_submit_pick_tips'.trArgs([
            msgList.join(','),
          ]),
          confirm: () => pick.call(true, selectList),
        );
      } else {
        pick.call(true, selectList);
      }
    }
  }

  List<SapPickingDetailLabelInfo> getLabelListWhereId(int dataID) {
    var palletNumber = <String>[];
    state.orderDetailLabels
        .where((v) => v.distribution.any((v2) => v2.ascriptionId == dataID))
        .forEach((v) {
      if (!palletNumber.contains(v.palletNumber)) {
        palletNumber.add(v.palletNumber ?? '');
      }
    });

    return dataID < 0
        ? state.orderDetailLabels
        : state.orderDetailLabels.where((v) {
            for (var v2 in palletNumber) {
              if (v.palletNumber == v2) {
                return true;
              }
            }
            return false;
          }).toList();
  }

  sizeMaterialPicking({
    required String pickerNumber,
    required ByteData pickerSignature,
    required String userNumber,
    required ByteData userSignature,
    required Function() transfer,
  }) {
    state.submitSizeMaterialPrintPicking(
      pickerNumber: pickerNumber,
      pickerSignature: pickerSignature,
      userNumber: userNumber,
      userSignature: userSignature,
      relocation: (list) {
        askDialog(
            content: 'sap_print_picking_pallet_has_material_cannot_transfer'.tr,
            confirm: () {
              state.checkPallet(
                pallets: list,
                success: (info) {
                  groupBy(
                    info.item1 ?? <PalletDetailItem1Info>[],
                    (v) => v.palletNumber,
                  ).forEach((k, v) {
                    state.transferList.add(v);
                  });
                  transfer.call();
                },
                error: (msg) => errorDialog(content: msg),
              );
            });
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  materialPicking({
    required String pickerNumber,
    required ByteData pickerSignature,
    required String userNumber,
    required ByteData userSignature,
  }) {
    state.submitMaterialPrintPicking(
      pickerNumber: pickerNumber,
      pickerSignature: pickerSignature,
      userNumber: userNumber,
      userSignature: userSignature,
      success: (msg) => successDialog(
        content: msg,
        back: () => getOrderDetail(),
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  scannedLabelDelete(SapPickingDetailLabelInfo label) {
    label.distribution.clear();
    state.orderDetailLabels
        .firstWhere((v) => v.labelCode == label.labelCode)
        .distribution
        .clear();
    state.orderDetailLabels.refresh();
    for (var v in state.orderDetailOrderList) {
      v.pickQty = getSum(v.dataId);
    }
  }

  transferScanCode(String code) {
    if (code.isLabel()) {
      for (var list in state.transferList) {
        list.where((v) => v.labelNumber == code).forEach((item) {
          item.select = !item.select;
        });
      }
      showScanTips();
      return;
    }
    if (code.isPallet()) {
      var list =
          state.transferList.firstWhere((v) => v[0].palletNumber == code);
      if (list.every((v) => v.select)) {
        for (var v in list) {
          v.select = false;
        }
      } else {
        for (var v in list) {
          v.select = true;
        }
      }
      showScanTips();
      return;
    }
    showSnackBar(
      message: 'sap_print_picking_scan_wrong_barcode_tips'.tr,
      isWarning: true,
    );
  }

  checkPalletAndTransfer({
    required String pallet,
    required Function() refresh,
  }) {
    state.checkPallet(
      pallets: [pallet],
      success: (info) {
        if (info.item2![0].palletExistence == 'X') {
          switch (info.item2![0].palletState) {
            case '' || 'X':
              state.transfer(
                targetPallet: info.item2![0],
                success: () {
                  var list = <PalletDetailItem1Info>[];
                  for (var pallet in state.transferList) {
                    list.addAll(pallet.where((v) => !v.select));
                  }
                  if (list.isEmpty) {
                    successDialog(
                      content: 'sap_print_picking_all_material_transfer_completed'.tr,
                      back: () => Get.back(),
                    );
                  } else {
                    state.transferList.clear();
                    groupBy(list, (v) => v.palletNumber).forEach((k, v) {
                      state.transferList.add(v);
                    });
                    refresh.call();
                  }
                },
                error: (msg) => errorDialog(content: msg),
              );
              break;
            case 'Y':
              errorDialog(content: 'sap_print_picking_pallet_already_occupied'.tr);
              break;
          }
        } else {
          errorDialog(content: 'sap_print_picking_pallet_not_exists'.tr);
        }
      },
      error: (msg) => errorDialog(content: msg),
    );
  }
}
