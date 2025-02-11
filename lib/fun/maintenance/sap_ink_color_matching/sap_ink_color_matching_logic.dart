import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_ink_color_match_info.dart';
import 'package:jd_flutter/fun/maintenance/sap_ink_color_matching/sap_ink_color_matching_detail_view.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'sap_ink_color_matching_state.dart';

class SapInkColorMatchingLogic extends GetxController {
  final SapInkColorMatchingState state = SapInkColorMatchingState();

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  queryOrder({
    required String startDate,
    required String endDate,
    Function()? refresh,
  }) {
    state.queryOrder(
      startDate: startDate,
      endDate: endDate,
      error: (msg) => errorDialog(content: msg),
    );
  }

  createMixOrder({
    required String newTypeBody,
    required Function refresh,
  }) {
    if (newTypeBody.trim().isEmpty) {
      errorDialog(content: '请输入型体！');
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
          if (v != null && v) {
            refresh.call();
          }
        });
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  modifyOrder({
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
          if (v != null && v) {
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

  initModifyBodyData(int index) {
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
  }

  readBeforeWeight() {
    for (var v in state.inkColorList) {
      if (!v.weightBeforeLock.value && v.isNewItem) {
        v.weightBeforeColorMix.value = v.weight.value;
        // v.weightBeforeColorMix.value = randomDouble(5.0001, 9.9999);
        v.weightBeforeLock.value = true;
        v.weightAfterLock.value = false;
      }
    }
  }

  readAfterWeight() {
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

  readMixWeight() {
    state.readMixDeviceWeight.value = state.mixDeviceWeight;
  }

  bool hasReadBeforeWeight() => state.inkColorList
      .where((v) => v.isNewItem)
      .any((v) => v.weightAfterColorMix.value == 0);

  bool hasReadAfterWeight() => state.inkColorList
      .where((v) => v.isNewItem)
      .any((v) => v.weightBeforeColorMix.value > 0);

  checkSubmit(Function submit) {
    var submitData = state.inkColorList.where((v) => v.isNewItem);
    if (submitData.isEmpty) {
      errorDialog(content: '没有可提交的物料信息！');
      return;
    }
    for (var v in submitData) {
      if (v.weightBeforeColorMix.value <= 0) {
        errorDialog(content: '(${v.materialName})调前重量尚未读取！');
        return;
      }
      if (v.weightAfterColorMix.value <= 0) {
        errorDialog(content: '(${v.materialName})调后重量尚未读取！');
        return;
      }
    }
    if (state.mixDeviceSocket == null) {
      errorDialog(content: '当前服务器尚未配置混合物秤！');
      return;
    }
    if (state.readMixDeviceWeight.value <= 0) {
      errorDialog(content: '(${state.mixDeviceName})混合物重量尚未读取！');
      return;
    }
    submit.call();
  }

  submitModifyOrder(int index) {
    checkSubmit(() {
      var newItemWeight = state.inkColorList
          .where((v) => v.isNewItem)
          .map((v) => v.consumption())
          .reduce((a, b) => a.add(b));
      var mixActualWeight = state.readMixDeviceWeight.value.add(newItemWeight);
      var mixTheoreticalWeight = state.inkColorList
          .map((v) => v.consumption())
          .reduce((a, b) => a.add(b));
      state.submitOrder(
        orderNumber: state.orderList[index].orderNumber ?? '',
        inkMaster: state.orderList[index].inkMaster ?? '',
        mixActualWeight: mixActualWeight,
        mixTheoreticalWeight: mixTheoreticalWeight,
        success: (msg) => successDialog(
          content: msg,
          back: () => Get.back(result: true),
        ),
        error: (msg) => errorDialog(content: msg),
      );
    });
  }

  submitCreateOrder() {
    checkSubmit(() => state.submitOrder(
          orderNumber: '',
          inkMaster: userInfo?.name ?? '',
          mixActualWeight: state.readMixDeviceWeight.value,
          mixTheoreticalWeight: state.inkColorList
              .map((v) => v.consumption())
              .reduce((a, b) => a.add(b)),
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

  initRecreateItemData(int index) {
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

  setPresetWeight(double weight) {
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

  refreshItemList(int index) {
    var item = state.presetInkColorList[index];
    var preset = item.actualWeight.value.div((item.ratio.div(100)));
    if (preset > state.finalWeight.value) {
      state.finalWeight.value = preset;
      for (var v in state.presetInkColorList) {
        v.finalWeight.value = preset.mul(v.ratio.div(100));
        v.repairWeight.value = v.finalWeight.value.sub(v.actualWeight.value);
      }
    }else{
      item.repairWeight.value = item.finalWeight.value.sub(item.actualWeight.value);
    }
  }

  refreshAll() {
    state.finalWeight.value = 0;
    for (var v in state.presetInkColorList) {
      v.actualWeight.value = 0;
      v.presetWeight.value = 0;
      v.repairWeight.value = 0;
    }
  }
}
