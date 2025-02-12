import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/maintenance/sap_ink_color_matching/sap_ink_color_matching_dialog.dart';
import 'package:jd_flutter/fun/maintenance/sap_ink_color_matching/sap_ink_color_matching_recreate_view.dart';
import 'package:jd_flutter/fun/maintenance/sap_ink_color_matching/sap_ink_color_matching_state.dart';
import 'package:jd_flutter/utils/socket_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

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
                      hint: '设备：',
                      text: data.deviceName,
                    ),
                    IconButton(
                      onPressed: () => askDialog(
                        content: '确定要删除<${data.deviceName}>的物料吗？',
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
                              child: Text('无'),
                            )
                          : null,
                    ),
                    expandedTextSpan(
                      flex: 3,
                      hint: '物料：',
                      text: '(${data.materialCode})${data.materialName}',
                      textColor: Colors.black87,
                    ),
                    Expanded(
                      flex: 2,
                      child: Obx(() => Row(
                            children: [
                              textSpan(
                                hint: '调前重量：',
                                text:
                                    '${data.weightBeforeColorMix.value.toMaxString()} ${data.unit.value}',
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
                                hint: '调后重量：',
                                text:
                                    '${data.weightAfterColorMix.value.toMaxString()} ${data.unit.value}',
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
                          hint: '耗量：',
                          text:
                              '${(data.weightBeforeColorMix.value.sub(data.weightAfterColorMix.value)).toMaxString()} ${data.unit.value}',
                          textColor: Colors.blueAccent,
                        )),
                    Obx(() => Text(
                          data.errorUnit.value ? '设备单位错误！' : '',
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
                      ? Center(child: Text('无'))
                      : null,
                ),
                expandedTextSpan(
                  flex: 3,
                  hint: '物料：',
                  text: '(${data.materialCode})${data.materialName}',
                  textColor: Colors.black87,
                ),
                expandedTextSpan(
                  flex: 2,
                  hint: '调前重量：',
                  text:
                      '${data.weightBeforeColorMix.value.toMaxString()} ${data.unit.value}',
                  textColor:
                      data.weightBeforeLock.value ? Colors.red : Colors.green,
                ),
                expandedTextSpan(
                  flex: 2,
                  hint: '调后重量：',
                  text:
                      '${data.weightAfterColorMix.value.toMaxString()} ${data.unit.value}',
                  textColor:
                      data.weightAfterLock.value ? Colors.red : Colors.green,
                ),
                expandedTextSpan(
                  flex: 2,
                  hint: '耗量：',
                  text:
                      '${(data.weightBeforeColorMix.value.sub(data.weightAfterColorMix.value)).toMaxString()} ${data.unit.value}',
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
              hint: '型体：',
              text: index >= 0
                  ? '${state.orderList[index].typeBody}'
                  : state.newTypeBody,
              textColor: Colors.green.shade700,
            ),
            if (index >= 0)
              textSpan(
                hint: '调色单号：',
                text: state.orderList[index].orderNumber ?? '',
                textColor: Colors.green.shade700,
              ),
            if (index >= 0)
              textSpan(
                hint: '调色日期：',
                text: state.orderList[index].mixDate ?? '',
                textColor: Colors.black87,
              ),
            textSpan(
              hint: '油墨师：',
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
                              text: '设备单位错误！',
                              hintColor: Colors.red,
                              textColor: Colors.red,
                            )
                          : textSpan(
                              hint: '${state.mixDeviceName}：',
                              text:
                                  '${state.readMixDeviceWeight.value.toMaxString()} ${state.mixDeviceUnit}',
                              textColor: Colors.green,
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
      logic.initModifyBodyData(index);
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
              CombinationButton(
                text: '新增物料',
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
                        text: '读取调前重量',
                        click: () => logic.readBeforeWeight(),
                        combination: Combination.middle,
                      ),
                    if (logic.hasReadAfterWeight())
                      CombinationButton(
                        text: '读取调后重量',
                        click: () => logic.readAfterWeight(),
                        combination: Combination.middle,
                      ),
                  ],
                );
              }),
              if (index < 0)
                CombinationButton(
                  text: '读取混合物重量',
                  click: () => logic.readMixWeight(),
                  combination: Combination.middle,
                ),
              CombinationButton(
                text: '调色完成',
                click: () {
                  if (index >= 0) {
                    logic.submitModifyOrder(index);
                  } else {
                    logic.submitCreateOrder();
                  }
                },
                combination: Combination.right,
              ),
            ]
          : [
              CombinationButton(
                text: '再做一单',
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
              ? '调色明细'
              : '修改调色'
          : '创建调色',
      popTitle: index >= 0
          ? (state.orderList[index].trialQty ?? 0) > 0
              ? ''
              : '确定要退出 < 修改调色 > 吗?'
          : '确定要退出 < 创建调色 > 吗?',
      body: _body(),
    );
  }

  @override
  void dispose() {
    state.clean();
    super.dispose();
  }
}
