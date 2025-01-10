import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_ink_color_match_info.dart';
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
              Expanded(child: Text('添加调色物料')),
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
                      hintText: '请输入物料名称',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: IconButton(
                          onPressed: () => controller.clear(),
                          icon: const Icon(
                            Icons.replay_circle_filled,
                            color: Colors.red,
                          )),
                      suffixIcon: CombinationButton(
                        text: '新增物料',
                        click: () {
                          if (scalePortList.isEmpty) {
                            showSnackBar(
                              title: '错误',
                              message: '无可用设备！',
                              isWarning: true,
                            );
                            return;
                          }
                          if (showList.isEmpty) {
                            showSnackBar(
                              title: '错误',
                              message: '请选择物料！',
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
                                return Center(
                                    child: Text(
                                  '(${data.materialCode}) ${data.materialName}',
                                ));
                              }).toList(),
                              materialController,
                            )
                          : Center(
                              child: Text(
                                '无可用物料!',
                                style: TextStyle(
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
                                '无可用设备!',
                                style: TextStyle(
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
          title: Text('试做结果'),
          content: SizedBox(
            width: 300,
            height: 200,
            child: ListView(
              children: [
                textSpan(
                  hint: '调色单：',
                  text: orderNumber,
                  textColor: Colors.green,
                ),
                textSpan(
                  hint: '型体：',
                  text: typeBody,
                  textColor: Colors.green,
                ),
                Obx(() => textSpan(
                      hint: '单位用量：',
                      text: actualDosage.value.toMaxString(),
                    )),
                Row(
                  children: [
                    Text('试做数量：', style: style),
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
                    Text('双', style: style),
                  ],
                ),
                Row(
                  children: [
                    Text('混合物试做后重量：', style: style),
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
                    Text('损耗：', style: style),
                    Expanded(
                      child: NumberDecimalEditText(
                        max: 100,
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
                    title: '错误',
                    message: '请填写试做数量！',
                    isWarning: true,
                  );
                  return;
                }
                if (inputMixWeight.value == 0) {
                  showSnackBar(
                    title: '错误',
                    message: '请填写混合物试做后重量！',
                    isWarning: true,
                  );
                  return;
                }
                if (inputMixWeight.value == mixWeight) {
                  showSnackBar(
                    title: '错误',
                    message: '混合物试做后重量填写错误！',
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
    loading: '正在提交试做结果...',
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
