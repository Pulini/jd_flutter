import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_ink_color_match_info.dart';
import 'package:jd_flutter/utils/socket_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';

selectMaterialDialog({
  required String deviceIp,
  required List<SapInkColorMatchTypeBodyMaterialInfo> materialList,
  required List<SapInkColorMatchTypeBodyScalePortInfo> scalePortList,
  required Function(SapInkColorMatchItemInfo) addItem,
}) {
  var controller = TextEditingController();
  var materialController = FixedExtentScrollController();
  var scalePorController = FixedExtentScrollController();
  var showList = <SapInkColorMatchTypeBodyMaterialInfo>[];
  showList = materialList;
  Get.dialog(
    PopScope(
      canPop: false,
      child: StatefulBuilder(builder: (c, dialogSetState) {
        return AlertDialog(
          title: Row(
            children: [
              Expanded(child: Text('sap_ink_color_matching_dialog_add_color_toning_material'.tr)),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          content: SizedBox(
            width: 800,
            height: 240,
            child: ListView(
              children: [
                Container(
                  width: 300,
                  margin: const EdgeInsets.all(5),
                  height: 40,
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(
                        top: 0,
                        bottom: 0,
                        left: 15,
                        right: 10,
                      ),
                      filled: true,
                      fillColor: Colors.white54,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                        ),
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      hintText: 'sap_ink_color_matching_dialog_input_material_name'.tr,
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: IconButton(
                          onPressed: () => controller.clear(),
                          icon: const Icon(
                            Icons.replay_circle_filled,
                            color: Colors.red,
                          )),
                      suffixIcon: CombinationButton(
                        text: 'sap_ink_color_matching_dialog_add_material'.tr,
                        click: () {
                          if (scalePortList.isEmpty) {
                            showSnackBar(
                              message: 'sap_ink_color_matching_dialog_no_available_devices'.tr,
                              isWarning: true,
                            );
                            return;
                          }
                          if (showList.isEmpty) {
                            showSnackBar(
                              message: 'sap_ink_color_matching_dialog_select_material'.tr,
                              isWarning: true,
                            );
                            return;
                          }
                          Get.back();
                          var device =
                              scalePortList[scalePorController.selectedItem];
                          var material =
                              showList[materialController.selectedItem];
                          addItem.call(SapInkColorMatchItemInfo(
                            isNewItem: true,
                            deviceName: device.deviceName ?? '',
                            deviceIp: deviceIp,
                            scalePort: device.scalePort ?? 0,
                            materialCode: material.materialCode ?? '',
                            materialName: material.materialName ?? '',
                            materialColor: material.materialColor ?? '',
                          ));
                        },
                      ),
                    ),
                    onChanged: (search) {
                      dialogSetState(() {
                        if (search.isEmpty) {
                          showList = materialList;
                        } else {
                          showList = materialList.where((v) {
                            return v.materialName!
                                    .toUpperCase()
                                    .contains(search.toUpperCase()) ||
                                v.materialCode!
                                    .toUpperCase()
                                    .contains(search.toUpperCase());
                          }).toList();
                        }
                      });
                    },
                  ),
                ),
                Row(
                  children: [
                    SizedBox(
                      height: 140,
                      width: 600,
                      child: materialList.isNotEmpty
                          ? getCupertinoPicker(
                              showList.map((data) {
                                var color =
                                    data.materialColor.getColorByDescription();
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 20,
                                      width: 20,
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                      ),
                                      child: Text(
                                        '(${data.materialCode}) ${data.materialName}',
                                      ),
                                    ),
                                    Container(
                                      height: 20,
                                      width: 20,
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    )
                                  ],
                                );
                              }).toList(),
                              materialController,
                            )
                          : Center(
                              child: Text(
                                'sap_ink_color_matching_dialog_no_available_material'.tr,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                    ),
                    SizedBox(
                      height: 140,
                      width: 200,
                      child: scalePortList.isNotEmpty
                          ? getCupertinoPicker(
                              scalePortList.map((data) {
                                return Center(
                                    child: Text(data.deviceName ?? ''));
                              }).toList(),
                              scalePorController,
                            )
                          : Center(
                              child: Text(
                                'sap_ink_color_matching_dialog_no_available_devices'.tr,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      }),
    ),
  );
}

trialFinishDialog({
  required String typeBody,
  required String orderNumber,
  required double mixWeight,
  required Function() refresh,
}) {
  var inputTrialQty = 0.0.obs;
  var inputMixWeight = 0.0.obs;
  var inputLossPercent = 0.0.obs;
  var standardDosage = 0.0.obs;
  var actualDosage = 0.0.obs;
  var style = const TextStyle(fontWeight: FontWeight.bold);
  Get.dialog(
    PopScope(
      canPop: false,
      child: StatefulBuilder(builder: (c, dialogSetState) {
        return AlertDialog(
          title: Text('sap_ink_color_matching_dialog_trial_result'.tr),
          content: SizedBox(
            width: 300,
            height: 230,
            child: ListView(
              children: [
                textSpan(
                  hint: 'sap_ink_color_matching_dialog_color_toning_order'.tr,
                  text: orderNumber,
                  textColor: Colors.green,
                ),
                textSpan(
                  hint: '型sap_ink_color_matching_dialog_type_body'.tr,
                  text: typeBody,
                  textColor: Colors.green,
                ),
                Obx(() => textSpan(
                      hint: 'sap_ink_color_matching_dialog_usage'.tr,
                      text: actualDosage.value.toMaxString(),
                    )),
                Row(
                  children: [
                    Text('sap_ink_color_matching_dialog_trial_qty'.tr, style: style),
                    Expanded(
                      child: NumberDecimalEditText(
                        onChanged: (w) {
                          inputTrialQty.value = w;
                          standardDosage.value = mixWeight
                              .sub(inputMixWeight.value)
                              .div(inputTrialQty.value);
                          actualDosage.value = standardDosage.value
                              .mul(1 + (inputLossPercent.value / 100));
                        },
                      ),
                    ),
                    Text('sap_ink_color_matching_dialog_pair_unit'.tr, style: style),
                  ],
                ),
                Row(
                  children: [
                    Text('sap_ink_color_matching_dialog_mix_trial_weight'.tr, style: style),
                    Expanded(
                      child: NumberDecimalEditText(
                        max: mixWeight,
                        onChanged: (w) {
                          inputMixWeight.value = w;
                          standardDosage.value = mixWeight
                              .sub(inputMixWeight.value)
                              .div(inputTrialQty.value);
                          actualDosage.value = standardDosage.value
                              .mul(1 + (inputLossPercent.value / 100));
                        },
                      ),
                    ),
                    Text('kg', style: style),
                  ],
                ),
                Row(
                  children: [
                    Text('sap_ink_color_matching_dialog_loss'.tr, style: style),
                    Expanded(
                      child: NumberDecimalEditText(
                        max: 20,
                        onChanged: (w) {
                          inputLossPercent.value = w;
                          standardDosage.value = mixWeight
                              .sub(inputMixWeight.value)
                              .div(inputTrialQty.value);
                          actualDosage.value = standardDosage.value
                              .mul(1 + (inputLossPercent.value / 100));
                        },
                      ),
                    ),
                    Text('%', style: style),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (inputTrialQty.value == 0) {
                  showSnackBar(
                    message: 'sap_ink_color_matching_dialog_input_trial_qty'.tr,
                    isWarning: true,
                  );
                  return;
                }
                if (inputMixWeight.value == 0) {
                  showSnackBar(
                    message: 'sap_ink_color_matching_dialog_input_mix_trial_weight'.tr,
                    isWarning: true,
                  );
                  return;
                }
                if (inputMixWeight.value == mixWeight) {
                  showSnackBar(
                    message: 'sap_ink_color_matching_dialog_weight_error'.tr,
                    isWarning: true,
                  );
                  return;
                }
                _submitTrialFinish(
                  orderNumber: orderNumber,
                  trialQty: inputTrialQty.value,
                  mixWeight: inputMixWeight.value,
                  lossPercent: inputLossPercent.value,
                  standardDosage: standardDosage.value,
                  actualDosage: actualDosage.value,
                  success: (msg) => successDialog(
                    content: msg,
                    back: () {
                      Get.back();
                      refresh.call();
                    },
                  ),
                  error: (msg) => errorDialog(content: msg),
                );
              },
              child: Text(
                'dialog_default_confirm'.tr,
              ),
            ),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'dialog_default_back'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        );
      }),
    ),
  );
}

_submitTrialFinish({
  required String orderNumber,
  required double trialQty,
  required double mixWeight,
  required double lossPercent,
  required double standardDosage,
  required double actualDosage,
  required Function(String) success,
  required Function(String) error,
}) {
  sapPost(
    loading: 'sap_ink_color_matching_dialog_submitting_trial'.tr,
    method: webApiSapSubmitTrialFinish,
    body: {
      "WOFNR": orderNumber,
      "MENGE": trialQty,
      "ZMIXNTGEW_AFT": mixWeight,
      "AUSCH": lossPercent,
      "ZMENG1": standardDosage,
      "ZMENG2": actualDosage
    },
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      success.call(response.message ?? '');
    } else {
      error.call(response.message ?? 'query_default_error'.tr);
    }
  });
}

puttingDialog({
  required SapRecreateInkColorItemInfo data,
  required String deviceName,
  required String deviceServerIp,
  required int deviceScalePort,
  required double nowWeight,
  required Function() refresh,
}) {
  var actual = data.actualWeight.value;
  var ballColor = data.materialColor.getColorByDescription();
  var mixDeviceWeight = (0.0).obs;
  var mixDeviceUnit = ''.obs;
  var connectState = 0.obs;
  var styleBlue = const TextStyle(
    color: Colors.blue,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  var styleRed = const TextStyle(
    color: Colors.red,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  var styleGreen = const TextStyle(
    color: Colors.green,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  SocketClientUtil mixDeviceSocket = SocketClientUtil(
    ip: deviceServerIp,
    port: deviceScalePort,
    weightListener: (weight, unit) {
      mixDeviceWeight.value = weight;
      mixDeviceUnit.value = unit;
    },
    connectListener: (state) {
      connectState.value = state.value;
    },
  )..connect();
  Get.dialog(
    PopScope(
      canPop: false,
      child: StatefulBuilder(builder: (c, dialogSetState) {
        return AlertDialog(
          title: Row(
            children: [
              Container(
                height: 30,
                width: 30,
                margin: const EdgeInsets.only(right: 5),
                decoration: BoxDecoration(
                  color: ballColor,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white,
                    width: 1,
                  ),
                ),
                child: ballColor == Colors.transparent
                    ? Center(child: Text('sap_ink_color_matching_dialog_null'.tr))
                    : null,
              ),
              expandedTextSpan(
                flex: 3,
                hint: 'sap_ink_color_matching_dialog_material'.tr,
                text: '(${data.materialCode})${data.materialName}',
                textColor: Colors.black87,
              ),
            ],
          ),
          content: SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => connectState.value == ConnectState.connecting.value
                    ? Row(
                        children: [
                          Text('$deviceName：', style: styleBlue),
                          Container(
                            width: 30,
                            height: 30,
                            margin: const EdgeInsets.only(left: 5, right: 10),
                            child: const CircularProgressIndicator(),
                          ),
                          Text('sap_ink_color_matching_dialog_connecting'.tr, style: styleBlue),
                        ],
                      )
                    : connectState.value == ConnectState.connected.value
                        ? mixDeviceUnit.value != 'kg'
                            ? Text('$deviceName：sap_ink_color_matching_dialog_device_unit_error'.tr, style: styleRed)
                            : Text('$deviceName：sap_ink_color_matching_dialog_connected'.tr, style: styleGreen)
                        : Row(
                            children: [
                              Text('$deviceName：', style: styleRed),
                              const Icon(
                                Icons.leak_remove,
                                color: Colors.red,
                                size: 30,
                              ),
                              Text('sap_ink_color_matching_dialog_device_exception'.tr, style: styleRed),
                            ],
                          )),
                Obx(() => textSpan(
                      hint: 'sap_ink_color_matching_dialog_mix_weight'.tr,
                      fontSize: 24,
                      text:
                          '${mixDeviceWeight.value.toShowString()} ${mixDeviceUnit.value}',
                    )),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: Column(
                    children: [
                      Obx(() {
                        var v = mixDeviceWeight.value
                            .sub(nowWeight)
                            .add(actual)
                            .clamp(0.0, double.infinity);
                        return percentIndicator(
                          max: data.finalWeight.value,
                          value: v,
                          color: v > data.finalWeight.value
                              ? Colors.red
                              : Colors.green,
                        );
                      }),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(() => textSpan(
                                hint: 'sap_ink_color_matching_dialog_should_poured_in'.tr,
                                text:
                                    '${data.finalWeight.value.toFixed(4).toShowString()} ${mixDeviceUnit.value}',
                              )),
                          Obx(() => textSpan(
                                hint: 'sap_ink_color_matching_dialog_already_poured_in'.tr,
                                text:
                                    '${data.actualWeight.value.toFixed(4).toShowString()} ${mixDeviceUnit.value}',
                              )),
                          Obx(() => textSpan(
                                hint: 'sap_ink_color_matching_dialog_need_poured_in'.tr,
                                text:
                                    '${data.finalWeight.value.sub(data.actualWeight.value).toFixed(4).toShowString()} ${mixDeviceUnit.value}',
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: Center(
                    child: Obx(() {
                      var materialWeight = mixDeviceWeight.value
                          .sub(nowWeight)
                          .clamp(0.0, double.infinity);
                      return Text(
                        '${materialWeight.toShowString()} ${mixDeviceUnit.value}',
                        style: const TextStyle(
                          fontSize: 70,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      );
                    }),
                  ),
                ),
                Obx(() => SizedBox(
                      width: double.infinity,
                      child: CombinationButton(
                        isEnabled: mixDeviceUnit.value.isNotEmpty,
                        text: 'sap_ink_color_matching_dialog_mix_finish'.tr,
                        click: () {
                          if (connectState.value ==
                                  ConnectState.connected.value &&
                              mixDeviceUnit.value == 'kg') {
                            mixDeviceSocket.clean();
                            var materialWeight = mixDeviceWeight.value
                                .sub(nowWeight)
                                .clamp(0.0, double.infinity);
                            if (data.actualWeight.value > 0) {
                              data.actualWeight.value =
                                  data.actualWeight.value.add(materialWeight);
                            } else {
                              data.actualWeight.value = materialWeight;
                            }
                            refresh.call();
                          }
                          Get.back();
                        },
                      ),
                    ))
              ],
            ),
          ),
        );
      }),
    ),
  );
}
