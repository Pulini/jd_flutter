import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_surplus_material_info.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'sap_surplus_material_stock_in_logic.dart';
import 'sap_surplus_material_stock_in_state.dart';

class SapSurplusMaterialStockInPage extends StatefulWidget {
  const SapSurplusMaterialStockInPage({super.key});

  @override
  State<SapSurplusMaterialStockInPage> createState() =>
      _SapSurplusMaterialStockInPageState();
}

class _SapSurplusMaterialStockInPageState
    extends State<SapSurplusMaterialStockInPage> {
  final SapSurplusMaterialStockInLogic logic =
      Get.put(SapSurplusMaterialStockInLogic());
  final SapSurplusMaterialStockInState state =
      Get.find<SapSurplusMaterialStockInLogic>().state;

  ///日期选择器的控制器
  var dpcStartDate = DatePickerController(
    PickerType.startDate,
    saveKey:
        '${RouteConfig.sapSurplusMaterialStockIn.name}${PickerType.startDate}',
  );

  ///日期选择器的控制器
  var dpcEndDate = DatePickerController(
    PickerType.date,
    saveKey:
        '${RouteConfig.sapSurplusMaterialStockIn.name}${PickerType.endDate}',
  );

  _selectSurplusMaterialType(Function(String index) select) {
    var controller = FixedExtentScrollController();
    Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('选择料头类型'),
          content: SizedBox(
            width: 300,
            height: 160,
            child: getCupertinoPicker(
              surplusMaterialType.map((v) => Center(child: Text(v))).toList(),
              controller,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                select.call('0${controller.selectedItem + 1}');
                Get.back();
              },
              child: Text('dialog_default_confirm'.tr),
            ),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'dialog_default_cancel'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _item1(SurplusMaterialLabelInfo data) {
    var controller = TextEditingController(text: '${data.editQty}');
    return Container(
      margin: const EdgeInsets.only(right: 5, bottom: 10),
      padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [Colors.blue.shade200, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textSpan(
                  hint: '物料：',
                  text: '(${data.number})${data.name}',
                  textColor: Colors.blue.shade700,
                ),
                Row(
                  children: [
                    Text(
                      '料头重量：',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    SizedBox(
                      width: 100,
                      height: 35,
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: controller,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                        ],
                        onChanged: (v) => data.editQty = v.toDoubleTry(),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(
                            top: 0,
                            bottom: 0,
                            left: 10,
                            right: 10,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        data.editQty=state.weight.value;
                        controller.text = state.weight.value.toShowString();
                      },
                      icon: Icon(
                        Icons.monitor_weight_rounded,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          IconButton(
            onPressed: () => askDialog(
              content: '确定要删除此料头数据吗？',
              confirm: () {
                state.materialList.remove(data);
              },
            ),
            icon: const Icon(
              Icons.delete_forever,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  _item2(List<SurplusMaterialHistoryInfo> list) {
    return Card(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              gradient: LinearGradient(
                colors: [Colors.blue.shade200, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textSpan(
                  hint: '料头：',
                  text:
                      '(${list[0].surplusMaterialCode})${list[0].surplusMaterialName}',
                  textColor: Colors.blue.shade700,
                ),
                Row(
                  children: [
                    expandedTextSpan(
                      flex: 4,
                      hint: '型体：',
                      text: list[0].typeBody ?? '',
                      textColor: Colors.blue.shade700,
                    ),
                    expandedTextSpan(
                      hint: '总重量：',
                      text: list
                          .map((v) => v.surplusMaterialQty ?? 0)
                          .reduce((a, b) => a.add(b))
                          .toShowString(),
                    ),
                  ],
                ),
                const Divider(height: 10, color: Colors.black),
              ],
            ),
          ),
          for (var sub in list)
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      expandedTextSpan(
                        flex: 2,
                        hint: '派工单号：',
                        text: sub.dispatchNo ?? '',
                        textColor: Colors.blue.shade700,
                      ),
                      expandedTextSpan(
                        flex: 2,
                        hint: '提交日期：',
                        text: sub.submitDate ?? '',
                        isBold: false,
                        hintColor: Colors.grey.shade700,
                        textColor: Colors.blue.shade700,
                      ),
                      expandedTextSpan(
                        hint: '机台：',
                        text: sub.machine ?? '',
                        isBold: false,
                        hintColor: Colors.grey.shade700,
                        textColor: Colors.blue.shade700,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      expandedTextSpan(
                        flex: 2,
                        hint: '',
                        text: sub.stateText(),
                        isBold: false,
                        hintColor: Colors.grey.shade700,
                        textColor: sub.stateColor(),
                      ),
                      expandedTextSpan(
                        flex: 2,
                        hint: '料头类型：',
                        text: sub.surplusMaterialTypeName ?? '',
                        isBold: false,
                        hintColor: Colors.grey.shade700,
                        textColor: logic.getSurplusMaterialTypeColor(
                            sub.surplusMaterialType ?? '0'),
                      ),
                      expandedTextSpan(
                        hint: '总量：',
                        text: sub.surplusMaterialQty.toShowString(),
                        isBold: false,
                        hintColor: Colors.grey.shade700,
                        textColor: Colors.blue.shade700,
                      ),
                    ],
                  ),
                  const Divider(height: 10, color: Colors.black),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void initState() {
    weighbridgeListener(
      usbAttached: () => showSnackBar(title: 'USB监测', message: '监测到USB设备插入'),
      readWeight: (weight) => state.weight.value = weight,
      weighbridgeState: (state) => logic.setWeighbridgeState(state),
    );
    pdaScanner(scan: (code) => logic.scanCode(code));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        weighbridgeOpen();
        Future.delayed(
          const Duration(milliseconds: 500),
          () => logic.queryHistory(
            startDate: dpcStartDate.getDateFormatSapYMD(),
            endDate: dpcEndDate.getDateFormatSapYMD(),
          ),
        );
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      onKeyEvent: (key) {
        if (key.logicalKey == LogicalKeyboardKey.enter) {
          logic.scanCode(state.interceptorText);
          state.interceptorText = '';
        } else if (key.logicalKey.keyLabel.isNotEmpty) {
          state.interceptorText += key.logicalKey.keyLabel;
        }
      },
      focusNode: FocusNode(),
      child: pageBody(
        actions: [
          Obx(() => state.weighbridgeStateText.value.isEmpty
              ? const CircularProgressIndicator()
              : Text(
                  state.weighbridgeStateText.value,
                  style: TextStyle(
                    color: state.weighbridgeStateTextColor.value,
                    fontWeight: FontWeight.bold,
                  ),
                )),
          const SizedBox(width: 50),
          CombinationButton(
            text: '重新连接',
            click: () {
              state.weighbridgeStateText.value = '';
              weighbridgeOpen();
            },
          )
        ],
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                      child: Obx(() => Row(
                            children: [
                              expandedTextSpan(
                                  hint: '派工单号：',
                                  text: state.dispatchOrderNumber.value),
                              textSpan(
                                hint: '总量：',
                                text: state.weight.value.toShowString(),
                                textColor: Colors.blueAccent,
                              ),
                              const SizedBox(width: 20),
                            ],
                          )),
                    ),
                    Expanded(
                      child: Obx(() => ListView.builder(
                            padding: const EdgeInsets.only(right: 10),
                            itemCount: state.materialList.length,
                            itemBuilder: (c, i) =>
                                _item1(state.materialList[i]),
                          )),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: CombinationButton(
                        text: '过账',
                        click: () {
                          if (logic.checkSubmitData()) {
                            _selectSurplusMaterialType(
                              (type) => logic.submitSurplusMaterial(type: type),
                            );
                          }
                        },
                        combination: Combination.left,
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DatePicker(pickerController: dpcStartDate),
                        ),
                        Expanded(
                          child: DatePicker(pickerController: dpcEndDate),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Obx(() => ListView.builder(
                            padding: const EdgeInsets.only(left: 10),
                            itemCount: state.historyList.length,
                            itemBuilder: (c, i) => _item2(state.historyList[i]),
                          )),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: CombinationButton(
                        text: '查询历史',
                        click: () => logic.queryHistory(
                          startDate: dpcStartDate.getDateFormatSapYMD(),
                          endDate: dpcEndDate.getDateFormatSapYMD(),
                        ),
                        combination: Combination.right,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<SapSurplusMaterialStockInLogic>();
    super.dispose();
  }
}