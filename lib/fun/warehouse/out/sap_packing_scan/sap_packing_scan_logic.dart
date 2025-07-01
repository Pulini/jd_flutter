import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_picing_scan_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'sap_packing_scan_state.dart';

class SapPackingScanLogic extends GetxController {
  final SapPackingScanState state = SapPackingScanState();

  scanCode(String code) {
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
          errorDialog(content: '该标签内物料包含了免税和非免税物料，不能一桶装柜！');
          return;
        }

        if (containerDutyFree.isNotEmpty && labelDutyFree.isNotEmpty) {
          if (containerDutyFree[0].isDutyFree != labelDutyFree[0].isDutyFree) {
            if (labelDutyFree[0].isDutyFree == '') {
              errorDialog(content: '该标签内物料包含免税物料，不能与非免税物料一同装柜！');
            } else {
              errorDialog(content: '该标签内物料包含非免税物料，不能与免税物料一同装柜！');
            }
            return;
          }
        }
      }
      for (var material in state.materialList) {
        if (material.labelList!
            .any((v) => v.labelNumber == code && v.isScanned.value)) {
          errorDialog(content: '该标签已扫，请勿重复扫码！');
          return;
        }
        logger.f(material.toJson());
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
                  '物料 (<${material.materialNumber}>${material.materialName}) 超出待装柜数量，请勿再扫该物料！');
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
      }
    }
  }

  _addMaterial(String code, List<SapPackingScanMaterialInfo> list) {
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

  _getMaterialInfo(String code) {
    state.getContainerLoadingInfo(
      code: code,
      success: (list) {
        var codeList = list
            .where((v) => v.labelList!.any((v2) => v2.labelNumber == code))
            .toList();
        if (groupBy(codeList, (v) => v.isDutyFree).length > 1) {
          errorDialog(content: '该标签内物料包含了免税与非免税两种物料，不能一同装柜！');
        } else {
          if (state.materialList.isEmpty) {
            _addMaterial(code, list);
          } else {
            if (state.destination!.pickerId() == 'ID' &&
                codeList[0].isDutyFree != state.materialList[0].isDutyFree) {
              if (list[0].isDutyFree == '') {
                errorDialog(content: '该标签内物料包含免税物料，不能与非免税物料一同装柜！');
              } else {
                errorDialog(content: '该标签内物料包含非免税物料，不能与免税物料一同装柜！');
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
      pieceList.add(PieceMaterialInfo(materials: materialList));
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

  deleteLabels() {
    for (var p in state.pieceList.where((v) => v.isSelected.value)) {
      for (var material in state.materialList) {
        material.labelList!
            .where((v) =>
                v.pieceNumber == p.materials[0].labelList![0].pieceNumber)
            .forEach((v) => v.isScanned.value = false);
      }
    }
    state.pieceList.removeWhere((v) => v.isSelected.value);
  }

  sealingCabinet() {
    if (state.materialList.any(
      (v) => v.labelList!.any((v2) => v2.isScanned.value),
    )) {
      errorDialog(content: '请先提交条码！');
    } else {
      state.checkContainer(
        success: (msg) => askDialog(
          title: '封柜',
          content: msg,
          confirm: () => state.sealingCabinet(
            success: (msg) => successDialog(content: msg),
            error: (msg) => errorDialog(content: msg),
          ),
        ),
        error: (msg) => errorDialog(content: msg),
      );
    }
  }

  checkMaterialSubmitData(Function(List<SapPackingScanLabelInfo>) callback) {
    var list = <SapPackingScanLabelInfo>[];
    for (var material in state.materialList) {
      list.addAll(material.labelList!.where((v) => v.isScanned.value));
    }
    if (list.isEmpty) {
      errorDialog(content: '没有可提交的数据!');
      return;
    }
    if (state.actualCabinet.isEmpty) {
      errorDialog(content: '请填写实际柜号!');
      return;
    }
    callback.call(list);
  }

  submit({
    required String postingDate,
    required List<SapPackingScanLabelInfo> submitList,
  }) {
    state.submit(
      postingDate: postingDate,
      list: submitList,
      success: (msg) => successDialog(content: msg),
      error: (msg) => errorDialog(content: msg),
      save: (abnormalList, msg) => askDialog(
        title: '保存异常单',
        content: '过账失败，是否先缓存？\r\n原因：$msg',
        confirm: () => state.saveAbnormalPiece(
          abnormalList: abnormalList,
          success: (msg) => successDialog(content: msg),
          error: (msg) => errorDialog(content: msg),
        ),
      ),
    );
  }

  getAbnormalOrders(Function() success) {
    state.getAbnormalOrders(
      success: success,
      error: (msg) => errorDialog(content: msg),
    );
  }

  List<List<SapPackingScanAbnormalInfo>> showAbnormalList() {
    if (state.abnormalSearchText.isEmpty) {
      return state.abnormalList;
    } else {
      var list = selectedAbnormalItem();
      var group = <List<SapPackingScanAbnormalInfo>>[];
      groupBy(list, (v) => v.materialNumber ?? '').forEach((k, v) {
        group.add(v);
      });
      return group;
    }
  }

  List<SapPackingScanAbnormalInfo> selectedAbnormalItem() {
    var list = <SapPackingScanAbnormalInfo>[
      for (var g in state.abnormalList)
        for (var s in g.where((v) => v.search(state.abnormalSearchText.value)))
          s
    ];
    return list;
  }

  deleteAbnormal() {
    state.deleteAbnormal(
      success: (msg) => successDialog(content: msg),
      error: (msg) => errorDialog(content: msg),
    );
  }

  checkAbnormalSubmitData(Function(List<SapPackingScanAbnormalInfo>) list) {
    var list = <SapPackingScanAbnormalInfo>[
      ...selectedAbnormalItem().where((v) => v.isSelected.value)
    ];
    if (list.isEmpty) {
      errorDialog(content: '没有可提交的数据!');
      return;
    }
    if (state.actualCabinet.isEmpty) {
      errorDialog(content: '请填写实际柜号!');
      return;
    }
    return list;
  }

  reSubmit({
    required String postingDate,
    required List<SapPackingScanAbnormalInfo> submitList,
  }) {
    state.reSubmit(
      postingDate: postingDate,
      list: submitList,
      success: (msg) => successDialog(content: msg),
      error: (msg) => errorDialog(content: msg),
    );
  }
}
