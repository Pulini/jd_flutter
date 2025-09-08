import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/maintenance/sap_ink_color_matching/sap_ink_color_matching_dialog.dart';
import 'package:jd_flutter/fun/maintenance/sap_ink_color_matching/sap_ink_color_matching_recreate_view.dart';
import 'package:jd_flutter/fun/maintenance/sap_ink_color_matching/sap_ink_color_matching_state.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/socket_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';

import 'sap_ink_color_matching_logic.dart';

class SapInkColorMatchingDetailPage extends StatefulWidget {
  const SapInkColorMatchingDetailPage({super.key});

  @override
  State<SapInkColorMatchingDetailPage> createState() =>
      _SapInkColorMatchingDetailPageState();
}

class _SapInkColorMatchingDetailPageState
    extends State<SapInkColorMatchingDetailPage> {
  final SapInkColorMatchingLogic logic = Get.find<SapInkColorMatchingLogic>();
  final SapInkColorMatchingState state =
      Get.find<SapInkColorMatchingLogic>().state;
  int index = Get.arguments['index'];
  var canAdd = false;
  var tecRemarks = TextEditingController();

  _item(int i) {
    var data = state.inkColorList[i];
    var ballColor = data.materialColor.getColorByDescription();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [
            data.isNewItem ? Colors.green.shade100 : Colors.grey.shade400,
            Colors.white
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: data.isNewItem
          ? Column(
              children: [
                Row(
                  children: [
                    Obx(() => SizedBox(
                          width: 60,
                          child: data.isConnecting.value
                              ? const Center(child: CircularProgressIndicator())
                              : IconButton(
                                  onPressed: () {
                                    data.connect();
                                  },
                                  icon: Icon(
                                    data.isConnect.value
                                        ? Icons.leak_add
                                        : Icons.leak_remove,
                                    color: data.isConnect.value
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                        )),
                    expandedTextSpan(
                      hint: 'sap_ink_color_matching_detail_device'.tr,
                      text: data.deviceName,
                    ),
                    IconButton(
                      onPressed: () => askDialog(
                        content:
                            'sap_ink_color_matching_detail_delete_tips'.trArgs([
                          data.deviceName,
                        ]),
                        confirm: () {
                          data.close();
                          state.inkColorList.remove(data);
                        },
                      ),
                      icon: const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 30,
                      width: 30,
                      margin: const EdgeInsets.only(right: 5),
                      decoration: BoxDecoration(
                        color: data.materialColor.getColorByDescription(),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white,
                          width: 1,
                        ),
                      ),
                      child: ballColor == Colors.transparent
                          ? Center(
                              child:
                                  Text('sap_ink_color_matching_detail_null'.tr),
                            )
                          : null,
                    ),
                    expandedTextSpan(
                      flex: 3,
                      hint: 'sap_ink_color_matching_detail_material'.tr,
                      text: '(${data.materialCode})${data.materialName}',
                      textColor: Colors.black87,
                    ),
                    Expanded(
                      flex: 2,
                      child: Obx(() => Row(
                            children: [
                              textSpan(
                                hint:
                                    'sap_ink_color_matching_detail_before_toning_weight'
                                        .tr,
                                text:
                                    '${data.weightBeforeColorMix.value.toFixed(4).toShowString()} ${data.unit.value}',
                                textColor: data.weightBeforeLock.value
                                    ? Colors.red
                                    : Colors.green,
                              ),
                              if (data.isNewItem)
                                IconButton(
                                  onPressed: () {
                                    if (data.weightAfterColorMix.value == 0) {
                                      data.weightBeforeLock.value =
                                          !data.weightBeforeLock.value;
                                    }
                                  },
                                  icon: Icon(
                                    data.weightBeforeLock.value
                                        ? Icons.lock_outline
                                        : Icons.lock_open_sharp,
                                    color: data.weightBeforeLock.value
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                )
                            ],
                          )),
                    ),
                    Expanded(
                      flex: 2,
                      child: Obx(() => Row(
                            children: [
                              textSpan(
                                hint:
                                    'sap_ink_color_matching_detail_after_toning_weight'
                                        .tr,
                                text:
                                    '${data.weightAfterColorMix.value.toFixed(4).toShowString()} ${data.unit.value}',
                                textColor: data.weightAfterLock.value
                                    ? Colors.red
                                    : Colors.green,
                              ),
                              if (data.isNewItem)
                                IconButton(
                                  onPressed: () {
                                    if (data.weightBeforeColorMix.value > 0) {
                                      data.weightAfterLock.value =
                                          !data.weightAfterLock.value;
                                    }
                                  },
                                  icon: Icon(
                                    data.weightAfterLock.value
                                        ? Icons.lock_outline
                                        : Icons.lock_open_sharp,
                                    color: data.weightAfterLock.value
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                )
                            ],
                          )),
                    ),
                    Obx(() => expandedTextSpan(
                          flex: 2,
                          hint: 'sap_ink_color_matching_detail_loss'.tr,
                          text:
                              '${(data.weightBeforeColorMix.value.sub(data.weightAfterColorMix.value)).toFixed(4).toShowString()} ${data.unit.value}',
                          textColor: Colors.blueAccent,
                        )),
                    Obx(() => Text(
                          data.errorUnit.value
                              ? 'sap_ink_color_matching_detail_device_unit_error'
                                  .tr
                              : '',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ],
                )
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 30,
                  width: 30,
                  margin: const EdgeInsets.only(right: 5),
                  decoration: BoxDecoration(
                    color: data.materialColor.getColorByDescription(),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
                  child: ballColor == Colors.transparent
                      ? Center(
                          child: Text('sap_ink_color_matching_detail_null'.tr))
                      : null,
                ),
                expandedTextSpan(
                  flex: 3,
                  hint: 'sap_ink_color_matching_detail_material'.tr,
                  text: '(${data.materialCode})${data.materialName}',
                  textColor: Colors.black87,
                ),
                expandedTextSpan(
                  flex: 2,
                  hint: 'sap_ink_color_matching_detail_before_toning_weight'.tr,
                  text:
                      '${data.weightBeforeColorMix.value.toFixed(4).toShowString()} ${data.unit.value}',
                  textColor:
                      data.weightBeforeLock.value ? Colors.red : Colors.green,
                ),
                expandedTextSpan(
                  flex: 2,
                  hint: 'sap_ink_color_matching_detail_after_toning_weight'.tr,
                  text:
                      '${data.weightAfterColorMix.value.toFixed(4).toShowString()} ${data.unit.value}',
                  textColor:
                      data.weightAfterLock.value ? Colors.red : Colors.green,
                ),
                expandedTextSpan(
                  flex: 2,
                  hint: 'sap_ink_color_matching_detail_loss'.tr,
                  text:
                      '${(data.weightBeforeColorMix.value.sub(data.weightAfterColorMix.value)).toFixed(4).toShowString()} ${data.unit.value}',
                  textColor: Colors.blueAccent,
                )
              ],
            ),
    );
  }

  _body() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
        bottom: 10,
      ),
      child: Column(children: [
        if (index >= 0)
          ratioBarChart(ratioList: logic.getRatioColorLine(index)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            textSpan(
              hint: 'sap_ink_color_matching_detail_type_body'.tr,
              text: index >= 0
                  ? '${state.orderList[index].typeBody}'
                  : state.newTypeBody,
              textColor: Colors.green.shade700,
            ),
            if (index >= 0)
              textSpan(
                hint: 'sap_ink_color_matching_detail_color_toning_order_no'.tr,
                text: state.orderList[index].orderNumber ?? '',
                textColor: Colors.green.shade700,
              ),
            if (index >= 0)
              textSpan(
                hint: 'sap_ink_color_matching_detail_color_toning_date'.tr,
                text: state.orderList[index].mixDate ?? '',
                textColor: Colors.black87,
              ),
            textSpan(
              hint: 'sap_ink_color_matching_detail_inkmaster'.tr,
              text: index >= 0
                  ? '${state.orderList[index].inkMaster}'
                  : '${userInfo?.name}',
              textColor: Colors.black87,
            ),
            if (state.mixDeviceSocket != null)
              state.mixDeviceConnectState == ConnectState.connecting
                  ? Row(
                      children: [
                        Text('${state.mixDeviceName}：'),
                        const CircularProgressIndicator()
                      ],
                    )
                  : state.mixDeviceConnectState == ConnectState.connected
                      ? state.mixDeviceUnit != 'kg'
                          ? textSpan(
                              hint: '${state.mixDeviceName}：',
                              text:
                                  'sap_ink_color_matching_detail_device_unit_error'
                                      .tr,
                              hintColor: Colors.red,
                              textColor: Colors.red,
                            )
                          : Row(
                              children: [
                                Obx(() => textSpan(
                                      hint:
                                          'sap_ink_color_matching_detail_theoretical_loss'
                                              .tr,
                                      text:
                                          '${state.inkColorList.map((v) => v.consumption()).reduce((a, b) => a.add(b)).toFixed(4).toShowString()} ${state.mixDeviceUnit}',
                                    )),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20),
                                  child: Obx(() => textSpan(
                                        hint:
                                            'sap_ink_color_matching_detail_offset'
                                                .tr,
                                        text:
                                            '${state.inkColorList.map((v) => v.consumption()).reduce((a, b) => a.add(b)).sub(state.readMixDeviceWeight.value).toFixed(4).toShowString()} ${state.mixDeviceUnit}',
                                      )),
                                ),
                                textSpan(
                                  hint: '${state.mixDeviceName}：',
                                  text:
                                      '${state.readMixDeviceWeight.value.toFixed(4).toShowString()} ${state.mixDeviceUnit}',
                                  textColor: Colors.green,
                                )
                              ],
                            )
                      : Row(
                          children: [
                            Text('${state.mixDeviceName}：'),
                            const Icon(Icons.leak_remove, color: Colors.red)
                          ],
                        )
          ],
        ),
        Expanded(
          child: Obx(() => ListView.builder(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                itemCount: state.inkColorList.length,
                itemBuilder: (c, i) => _item(i),
              )),
        )
      ]),
    );
  }

  @override
  void initState() {
    canAdd = index < 0 || (index >= 0 && state.orderList[index].trialQty == 0);
    if (index >= 0) {
      logic.initModifyBodyData(
        index: index,
        refreshRemarks: (s) => tecRemarks.text = s,
      );
    } else {
      state.mixDeviceSocket = SocketClientUtil(
        ip: state.mixDeviceServerIp,
        port: state.mixDeviceScalePort,
        weightListener: (weight, unit) {
          setState(() {
            state.mixDeviceWeight = weight;
            state.mixDeviceUnit = unit;
          });
        },
        connectListener: (connectState) {
          setState(() {
            state.mixDeviceConnectState = connectState;
          });
        },
      )..connect();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: canAdd
          ? [
              SizedBox(
                width: getScreenSize().width * 0.35,
                child: EditText(
                  hint: 'sap_ink_color_matching_detail_remakes'.tr,
                  controller: tecRemarks,
                ),
              ),
              CombinationButton(
                text: 'sap_ink_color_matching_detail_add_material'.tr,
                click: () {
                  selectMaterialDialog(
                    deviceIp: state.typeBodyServerIp,
                    materialList: logic
                        .getMaterialList()
                        .where((v) => v.materialColor?.isNotEmpty == true)
                        .toList(),
                    scalePortList: logic.getScalePortList(),
                    addItem: (item) {
                      state.inkColorList.add(item);
                      item.connect();
                    },
                  );
                },
                combination: Combination.left,
              ),
              Obx(() {
                return Row(
                  children: [
                    if (logic.hasReadBeforeWeight())
                      CombinationButton(
                        text:
                            'sap_ink_color_matching_detail_read_before_toning_weight'
                                .tr,
                        click: () => logic.readBeforeWeight(),
                        combination: Combination.middle,
                      ),
                    if (logic.hasReadAfterWeight())
                      CombinationButton(
                        text:
                            'sap_ink_color_matching_detail_read_after_toning_weight'
                                .tr,
                        click: () => logic.readAfterWeight(),
                        combination: Combination.middle,
                      ),
                  ],
                );
              }),
              if (index < 0)
                CombinationButton(
                  text: 'sap_ink_color_matching_detail_read_mix_weight'.tr,
                  click: () => logic.readMixWeight(),
                  combination: Combination.middle,
                ),
              CombinationButton(
                text: 'sap_ink_color_matching_detail_color_toning_finish'.tr,
                click: () {
                  if (index >= 0) {
                    logic.submitModifyOrder(
                        index: index, remarks: tecRemarks.text);
                  } else {
                    logic.submitCreateOrder(remarks: tecRemarks.text);
                  }
                },
                combination: Combination.right,
              ),
            ]
          : [
              CombinationButton(
                text: 'sap_ink_color_matching_detail_toning_again'.tr,
                click: () => Get.off(
                  () => const SapInkColorMatchingRecreatePage(),
                  arguments: {
                    'index': index,
                    'deviceName': state.mixDeviceName,
                    'deviceServerIp': state.mixDeviceServerIp,
                    'deviceScalePort': state.mixDeviceScalePort,
                  },
                ),
              ),
            ],
      title: index >= 0
          ? (state.orderList[index].trialQty ?? 0) > 0
              ? 'sap_ink_color_matching_detail_color_toning_detail'.tr
              : 'sap_ink_color_matching_detail_modify_color_toning'.tr
          : 'sap_ink_color_matching_detail_create_color_toning'.tr,
      popTitle: index >= 0
          ? (state.orderList[index].trialQty ?? 0) > 0
              ? ''
              : 'sap_ink_color_matching_detail_exit_modify_tips'.tr
          : 'sap_ink_color_matching_detail_exit_create_tips'.tr,
      body: _body(),
    );
  }

  @override
  void dispose() {
    state.clean();
    super.dispose();
  }
}
