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
    required Function() refresh,
  }) {
    state.queryOrder(
      startDate: startDate,
      endDate: endDate,
      success: refresh,
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
        state.mixDeviceScalePort?.mixWeight.value =
            state.orderList[index].mixtureWeight ?? 0;
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

  getMaterialList() => state.typeBodyMaterialList
      .where((v) =>
          !state.inkColorList
              .where((v) => v.isNewItem)
              .any((v2) => v2.materialName == v.materialName) &&
          v.materialName?.trim().isNotEmpty == true)
      .toList();

  getScalePortList() => state.typeBodyScalePortList
      .where((v) =>
          !state.inkColorList.any((v2) => v2.scalePort == v.scalePort) &&
          v.isMix?.isEmpty == true)
      .toList();

  initModifyBodyData(int index) {
    state.orderList[index].materialList?.forEach((v) {
      state.inkColorList.add(SapInkColorMatchItemInfo(
        deviceName: '',
        deviceIp: '',
        scalePort: 0,
        materialCode: v.materialCode ?? '',
        materialName: v.materialName ?? '',
        weightBeforeColorMix: v.weightBeforeColorMix,
        weightAfterColorMix: v.weightAfterColorMix,
      )..unit.value = v.unit ?? '');
    });
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
    state.mixDeviceScalePort?.mixWeight.value =
        state.mixDeviceScalePort?.weight.value ?? 0;
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
        continue;
      }
      if (v.weightAfterColorMix.value <= 0) {
        errorDialog(content: '(${v.materialName})调后重量尚未读取！');
        continue;
      }
    }
    if (state.mixDeviceScalePort == null) {
      errorDialog(content: '当前服务器尚未配置混合物秤！');
      return;
    }
    if ((state.mixDeviceScalePort?.mixWeight.value ?? 0) <= 0) {
      errorDialog(
          content: '(${state.mixDeviceScalePort!.deviceName})混合物重量尚未读取！');
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
      var mixActualWeight =
          (state.mixDeviceScalePort?.mixWeight.value ?? 0).add(newItemWeight);
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
          mixActualWeight: state.mixDeviceScalePort?.mixWeight.value ?? 0,
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
}
