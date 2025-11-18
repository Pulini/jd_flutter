import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_ink_color_match_info.dart';
import 'package:jd_flutter/fun/maintenance/sap_ink_color_matching/sap_ink_color_matching_detail_view.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'sap_ink_color_matching_state.dart';

class SapInkColorMatchingLogic extends GetxController {
  final SapInkColorMatchingState state = SapInkColorMatchingState();

  void queryOrder({
    required String startDate,
    required String endDate,
    required String typeBody,
    Function()? refresh,
  }) {
    state.queryOrder(
      startDate: startDate,
      endDate: endDate,
        typeBody:typeBody,
      error: (msg) => errorDialog(content: msg),
    );
  }

  void createMixOrder({
    required String newTypeBody,
    required Function refresh,
  }) {
    if (newTypeBody.trim().isEmpty) {
      errorDialog(content: 'sap_ink_color_matching_input_type_body_tips'.tr);
      return;
    }
    state.checkTypeBody(
      isNew: true,
      newTypeBody: newTypeBody,
      success: () {
        Get.to(
          () => const SapInkColorMatchingDetailPage(),
          arguments: {'index': -1},
        )?.then((v) {
          if (v != null && (v as bool)) {
            refresh.call();
          }
        });
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  void modifyOrder({
    required int index,
    required Function refresh,
  }) {
    state.checkTypeBody(
      isNew: false,
      newTypeBody: state.orderList[index].typeBody ?? '',
      success: () {
        Get.to(
          () => const SapInkColorMatchingDetailPage(),
          arguments: {'index': index},
        )?.then((v) {
          if (v != null && (v as bool)) {
            refresh.call();
          }
        });
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  List<SapInkColorMatchTypeBodyMaterialInfo> getMaterialList() =>
      state.typeBodyMaterialList
          .where((v) =>
              !state.inkColorList
                  .where((v) => v.isNewItem)
                  .any((v2) => v2.materialName == v.materialName) &&
              v.materialName?.trim().isNotEmpty == true)
          .toList();

  List<SapInkColorMatchTypeBodyScalePortInfo> getScalePortList() =>
      state.typeBodyScalePortList
          .where((v) =>
              !state.inkColorList.any((v2) => v2.scalePort == v.scalePort) &&
              v.isMix?.isEmpty == true)
          .toList();

  void initModifyBodyData({required int index,required Function(String) refreshRemarks}) {
    state.readMixDeviceWeight.value = state.orderList[index].mixtureWeight ?? 0;
    state.inkColorList.value = [
      for (var item in (state.orderList[index].materialList ??
          <SapInkColorMatchMaterialInfo>[]))
        SapInkColorMatchItemInfo(
          deviceName: '',
          deviceIp: '',
          scalePort: 0,
          materialCode: item.materialCode ?? '',
          materialName: item.materialName ?? '',
          materialColor: item.materialColor ?? '',
          weightBeforeColorMix: item.weightBeforeColorMix,
          weightAfterColorMix: item.weightAfterColorMix,
        )..unit.value = item.unit ?? ''
    ];
    refreshRemarks.call( state.orderList[index].remarks ?? '');
  }

  void readBeforeWeight() {
    for (var v in state.inkColorList) {
      if (!v.weightBeforeLock.value && v.isNewItem) {
        v.weightBeforeColorMix.value = v.weight.value;
        // v.weightBeforeColorMix.value = randomDouble(5.0001, 9.9999);
        v.weightBeforeLock.value = true;
        v.weightAfterLock.value = false;
      }
    }
  }

  void readAfterWeight() {
    for (var v in state.inkColorList) {
      if (v.weightBeforeColorMix.value > 0 &&
          !v.weightAfterLock.value &&
          v.isNewItem) {
        v.weightAfterColorMix.value = v.weight.value;
        // v.weightAfterColorMix.value = randomDouble(0.0001, 5);
        v.weightAfterLock.value = true;
      }
    }
  }

  void readMixWeight() {
    state.readMixDeviceWeight.value = state.mixDeviceWeight;
  }

  bool hasReadBeforeWeight() => state.inkColorList
      .where((v) => v.isNewItem)
      .any((v) => v.weightAfterColorMix.value == 0);

  bool hasReadAfterWeight() => state.inkColorList
      .where((v) => v.isNewItem)
      .any((v) => v.weightBeforeColorMix.value > 0);

  void checkSubmit({required bool isModify, required Function() submit}) {
    var submitData = state.inkColorList.where((v) => v.isNewItem);
    if (submitData.isEmpty) {
      errorDialog(content: 'sap_ink_color_matching_no_material_submit'.tr);
      return;
    }
    for (var v in submitData) {
      if (v.weightBeforeColorMix.value <= 0) {
        errorDialog(
          content: 'sap_ink_color_matching_not_read_before_toning'.trArgs([
            v.materialName,
          ]),
        );
        return;
      }
      if (v.weightAfterColorMix.value <= 0) {
        errorDialog(
          content: 'sap_ink_color_matching_not_read_after_toning'.trArgs([
            v.materialName,
          ]),
        );
        return;
      }
      if (v.weightAfterColorMix.value.sub(v.weightBeforeColorMix.value) == 0) {
        errorDialog(
          content: 'sap_ink_color_matching_loss_cant_be_zero'.trArgs([
            v.materialName,
          ]),
        );
        return;
      }
    }
    if (!isModify) {
      if (state.mixDeviceSocket == null) {
        errorDialog(
            content: 'sap_ink_color_matching_server_not_config_mix_device'.tr);
        return;
      }
      if (state.readMixDeviceWeight.value <= 0) {
        errorDialog(
          content: 'sap_ink_color_matching_mix_weight_not_read'.trArgs([
            state.mixDeviceName,
          ]),
        );
        return;
      }
    }
    submit.call();
  }

  void submitModifyOrder({required int index, required String remarks}) {
    checkSubmit(
        isModify: true,
        submit: () {
          var newItemWeight = state.inkColorList
              .where((v) => v.isNewItem)
              .map((v) => v.consumption())
              .reduce((a, b) => a.add(b));
          var mixActualWeight =
              state.readMixDeviceWeight.value.add(newItemWeight);
          var mixTheoreticalWeight = state.inkColorList
              .map((v) => v.consumption())
              .reduce((a, b) => a.add(b));
          state.submitOrder(
            orderNumber: state.orderList[index].orderNumber ?? '',
            inkMaster: state.orderList[index].inkMaster ?? '',
            mixActualWeight: mixActualWeight,
            mixTheoreticalWeight: mixTheoreticalWeight,
            remarks: remarks,
            success: (msg) => successDialog(
              content: msg,
              back: () => Get.back(result: true),
            ),
            error: (msg) => errorDialog(content: msg),
          );
        });
  }

  void submitCreateOrder({required String remarks}) {
    checkSubmit(
        isModify: false,
        submit: () => state.submitOrder(
              orderNumber: '',
              inkMaster: userInfo?.name ?? '',
              mixActualWeight: state.readMixDeviceWeight.value,
              mixTheoreticalWeight: state.inkColorList
                  .map((v) => v.consumption())
                  .reduce((a, b) => a.add(b)),
              remarks: remarks,
              success: (msg) => successDialog(
                content: msg,
                back: () => Get.back(result: true),
              ),
              error: (msg) => errorDialog(content: msg),
            ));
  }

  List<List> getRatioColorLine(int index) {
    var ratioColorLine = <List>[];
    state.orderList[index].materialList?.forEach((v) {
      ratioColorLine.add([v.ratio ?? 0.0, v.materialColor ?? '']);
    });
    return ratioColorLine;
  }

  void initRecreateItemData(int index) {
    state.presetInkColorList = [
      for (var item in (state.orderList[index].materialList ??
          <SapInkColorMatchMaterialInfo>[]))
        SapRecreateInkColorItemInfo(
          materialCode: item.materialCode ?? '',
          materialName: item.materialName ?? '',
          materialColor: item.materialColor ?? '',
          ratio: item.ratio ?? 0,
        )
    ];
  }

  List<List> getRecreateRatioColorLine() {
    var ratioColorLine = <List>[];
    for (var v in state.presetInkColorList) {
      ratioColorLine.add([v.ratio, v.materialColor]);
    }
    return ratioColorLine;
  }

  void setPresetWeight(double weight) {
    state.finalWeight.value = weight;
    for (var v in state.presetInkColorList) {
      var preset = weight.mul(v.ratio.div(100));
      v.actualWeight.value = 0;
      v.presetWeight.value = preset;
      v.finalWeight.value = preset;
      v.repairWeight.value = preset;
    }
  }

  double getNowWeight(int index) {
    var nowWeight = 0.0;
    if (state.presetInkColorList[index].actualWeight.value > 0) {
      nowWeight = state.presetInkColorList
          .map((v) => v.actualWeight.value)
          .reduce((a, b) => a.add(b));
    } else {
      for (var i = 0; i < state.presetInkColorList.length; ++i) {
        if (i != index) {
          nowWeight =
              nowWeight.add(state.presetInkColorList[i].actualWeight.value);
        }
      }
    }
    return nowWeight;
  }

  void refreshItemList(int index) {
    var item = state.presetInkColorList[index];
    var preset = item.actualWeight.value.div((item.ratio.div(100)));
    if (preset > state.finalWeight.value) {
      state.finalWeight.value = preset;
      for (var v in state.presetInkColorList) {
        v.finalWeight.value = preset.mul(v.ratio.div(100));
        v.repairWeight.value = v.finalWeight.value.sub(v.actualWeight.value);
      }
    } else {
      item.repairWeight.value =
          item.finalWeight.value.sub(item.actualWeight.value);
    }
  }

  void refreshAll() {
    state.finalWeight.value = 0;
    for (var v in state.presetInkColorList) {
      v.actualWeight.value = 0;
      v.presetWeight.value = 0;
      v.repairWeight.value = 0;
    }
  }
}
