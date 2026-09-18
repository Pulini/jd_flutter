import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_scan_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'sap_packing_scan_state.dart';

class SapPackingScanLogic extends GetxController {
  final SapPackingScanState state = SapPackingScanState();

  void scanCode(String code) {
    if (state.materialList.isEmpty) {
      _getMaterialInfo(code);
    } else {
      if (state.destination!.pickerId() == 'ID') {
        //已扫标的免税类型
        var containerDutyFree = state.materialList
            .where((v) => v.labelList!.any((v2) => v2.isScanned.value))
            .toList();
        //当前标的免税类型
        var labelDutyFree = state.materialList
            .where((v) => v.labelList!.any((v2) => v2.labelNumber == code))
            .toList();

        if (groupBy(labelDutyFree, (v) => v.isDutyFree).length > 1) {
          errorDialog(content: 'sap_packing_scan_duty_free_mix_error'.tr);
          return;
        }

        if (containerDutyFree.isNotEmpty && labelDutyFree.isNotEmpty) {
          if (containerDutyFree[0].isDutyFree != labelDutyFree[0].isDutyFree) {
            if (labelDutyFree[0].isDutyFree == '') {
              errorDialog(content: 'sap_packing_scan_contains_duty_free_error'.tr);
            } else {
              errorDialog(content: 'sap_packing_scan_contains_non_duty_free_error'.tr);
            }
            return;
          }
        }
      }
      for (var material in state.materialList) {
        if (material.labelList!
            .any((v) => v.labelNumber == code && v.isScanned.value)) {
          errorDialog(content: 'sap_packing_scan_label_scanned'.tr);
          return;
        }
        double total = material.labelList!.any((v) => v.isScanned.value)
            ? material.labelList!
                .where((v) => v.isScanned.value)
                .map((v) => v.quality ?? 0)
                .reduce((a, b) => a.add(b))
            : 0;

        double qty = material.labelList!.any((v) => v.labelNumber == code)
            ? material.labelList!
                .where((v) => v.labelNumber == code)
                .map((v) => v.quality ?? 0)
                .reduce((a, b) => a.add(b))
            : 0;
        if (total.add(qty) > (material.quality ?? 0)) {
          errorDialog(
              content:
                  'sap_packing_scan_qty_exceed'.trArgs(['(<${material.materialNumber}>${material.materialName} ${'sap_packing_scan_track_no'.tr}:${material.trackNo})']));
          return;
        }
      }
      var labelExist = false;
      for (var material in state.materialList) {
        for (var label in material.labelList!) {
          if (label.labelNumber == code) {
            label.isScanned.value = true;
            labelExist = true;
          }
        }
      }
      if (!labelExist) {
        _getMaterialInfo(code);
      } else {
        state.materialList.refresh();
      }
    }
  }

  void _addMaterial(String code, List<SapPackingScanMaterialInfo> list) {
    for (var material in list) {
      for (var label in material.labelList!) {
        if (label.labelNumber == code) {
          label.isScanned.value = true;
        }
      }
    }
    for (var newMaterial in list) {
      try {
        var material = state.materialList
            .firstWhere((v) => v.materialID() == newMaterial.materialID());
        material.quality = newMaterial.quality;
        for (var label in newMaterial.labelList!) {
          if (material.labelList!.none((v) => v.labelID() == label.labelID())) {
            material.labelList!.add(label);
          }
        }
        state.materialList.refresh();
      } on StateError catch (_) {
        state.materialList.add(newMaterial);
      }
    }
  }

  int getScanned() {
    var scanned = <SapPackingScanLabelInfo>[];
    for (var material in state.materialList) {
      scanned.addAll(material.labelList!.where((v) => v.isScanned.value));
    }
    return groupBy(scanned, (v) => v.labelNumber).length;
  }

  void _getMaterialInfo(String code) {
    state.getContainerLoadingInfo(
      code: code,
      success: (list) {
        var codeList = list
            .where((v) => v.labelList!.any((v2) => v2.labelNumber == code))
            .toList();
        if (groupBy(codeList, (v) => v.isDutyFree).length > 1) {
          errorDialog(content: 'sap_packing_scan_duty_free_two_types'.tr);
        } else {
          if (state.materialList.isEmpty) {
            _addMaterial(code, list);
          } else {
            if (state.destination!.pickerId() == 'ID' &&
                codeList[0].isDutyFree != state.materialList[0].isDutyFree) {
              if (list[0].isDutyFree == '') {
                errorDialog(content: 'sap_packing_scan_contains_duty_free_error'.tr);
              } else {
                errorDialog(content: 'sap_packing_scan_contains_non_duty_free_error'.tr);
              }
            } else {
              _addMaterial(code, list);
            }
          }
        }
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  List<SapPackingScanMaterialInfo> showMaterialList() {
    var list = state.materialList
        .where((v) => v.labelList!.any((v2) => v2.isScanned.value))
        .toList();
    if (state.materialSearchText.isEmpty) {
      return list;
    } else {
      return list
          .where((v) =>
              (v.materialName ?? '').contains(state.materialSearchText.value) ||
              (v.materialNumber ?? '')
                  .contains(state.materialSearchText.value) ||
              (v.trackNo ?? '').contains(state.materialSearchText.value))
          .toList();
    }
  }

  List<PieceMaterialInfo> pieceList(String searchText) {
    var piece = <String>[];
    for (var material in state.materialList) {
      material.labelList!.where((v) => v.isScanned.value).forEach((label) {
        if (!piece.contains(label.pieceNumber)) {
          piece.add(label.pieceNumber ?? '');
        }
      });
    }
    var pieceList = <PieceMaterialInfo>[];
    for (var p in piece) {
      var materialList = <SapPackingScanMaterialInfo>[];
      for (var material in state.materialList) {
        if (material.labelList!.any((v) => v.pieceNumber == p)) {
          materialList.add(material);
        }
      }
      pieceList.add(PieceMaterialInfo(pieceId: p, materials: materialList));
    }
    if (searchText.isEmpty) {
      return pieceList;
    } else {
      return pieceList
          .where(
            (v) => v.materials
                .any((v2) => v2.search(state.materialSearchText.value)),
          )
          .toList();
    }
  }

  void deleteLabels() {
    for (var p in state.pieceList.where((v) => v.isSelected.value)) {
      for (var material in state.materialList) {
        material.labelList!
            .where((v) => v.pieceNumber == p.pieceId)
            .forEach((v) => v.isScanned.value = false);
      }
    }
    state.pieceList.removeWhere((v) => v.isSelected.value);
  }

  void sealingCabinet() {
    state.checkContainer(
      success: (msg) => askDialog(
        title: 'sap_packing_scan_seal_cabinet'.tr,
        content: msg,
        confirm: () => state.sealingCabinet(
          success: (msg) => successDialog(content: msg),
          error: (msg) => errorDialog(content: msg),
        ),
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  void checkMaterialSubmitData(Function(List<String>) callback) {
    var list = <String>[];
    for (var material in state.materialList) {
      material.labelList!.where((v) => v.isScanned.value).forEach((v) {
        if (!list.contains(v.labelNumber ?? '')) {
          list.add(v.labelNumber ?? '');
        }
      });
    }
    if (list.isEmpty) {
      errorDialog(content: 'sap_packing_scan_no_submit_data'.tr);
      return;
    }
    if (state.actualCabinet.isEmpty) {
      errorDialog(content: 'sap_packing_scan_please_fill_cabinet'.tr);
      return;
    }
    callback.call(list);
  }

  void submit({
    required String postingDate,
    required List<String> submitList,
  }) {
    state.submit(
      postingDate: postingDate,
      list: submitList,
      success: (msg) => successDialog(content: msg),
      error: (msg) => errorDialog(content: msg),
      save: (abnormalList, msg) => askDialog(
        title: 'sap_packing_scan_save_abnormal'.tr,
        content: 'sap_packing_scan_post_fail_cache'.trArgs([msg]),
        confirm: () => state.saveAbnormalPiece(
          abnormalList: abnormalList,
          success: (msg) => successDialog(content: msg),
          error: (msg) => errorDialog(content: msg),
        ),
      ),
    );
  }

  void saveLog({
    required String postingDate,
    required List<String> submitList,
  }) {
    state.saveLog(
      postingDate: postingDate,
      list: submitList,
      success: (msg) => successDialog(content: msg),
      error: (msg) => errorDialog(content: msg),
    );
  }


  void queryDeliveryOrders({
    required String plannedDate,
    required String destination,
    required String cabinetNumber,
    required Function() toDeliveryOrderList,
  }) {
    state.queryDeliveryOrders(
      plannedDate: plannedDate,
      destination: destination,
      cabinetNumber: cabinetNumber,
      success: toDeliveryOrderList,
      error: (msg) => errorDialog(content: msg),
    );
  }

  List<PickingScanDeliveryOrderInfo> getDeliveryOrders() {
    if (state.deliveryOrderSearchText.isEmpty) {
      return state.deliveryOrderList;
    } else {
      return state.deliveryOrderList
          .where((v) =>
              (v.orderNo ?? '').contains(state.deliveryOrderSearchText.value) ||
              (v.orderDate ?? '').contains(state.deliveryOrderSearchText.value))
          .toList();
    }
  }

  void modifyDeliveryOrderDate({
    required String deliveryOrderNo,
    required String modifyDate,
    required Function() callback,
  }) {
    state.modifyDeliveryOrderDate(
      deliveryOrders: [deliveryOrderNo],
      modifyDate: modifyDate,
      success: (msg) {
        state.deliveryOrderList
            .firstWhere((v) => v.orderNo == deliveryOrderNo)
            .orderDate = modifyDate;
        state.deliveryOrderList.refresh();
        successDialog(content: msg, back: callback);
      },
      error: (msg) => errorDialog(content: msg),
    );
  }
}
