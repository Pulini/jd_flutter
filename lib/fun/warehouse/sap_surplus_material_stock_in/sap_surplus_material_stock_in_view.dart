import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_surplus_material_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';

import '../../../route.dart';
import '../../../widget/picker/picker_controller.dart';
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

  _item1(SapSurplusMaterialLabelInfo data) {
    var controller = TextEditingController();
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5, bottom: 10),
      padding: const EdgeInsets.only(left: 7, top: 10, right: 7, bottom: 10),
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
          Column(
            children: [
              expandedTextSpan(
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
                    width: 80,
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
                    onPressed: () {},
                    icon: Icon(
                      Icons.monitor_weight_rounded,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              )
            ],
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.delete_forever,
              color: Colors.red,
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
      deviceNotConnected: () {
        state.weight.value = 0;
        showSnackBar(title: 'USB监测', message: '地磅未连接！！！', isWarning: true);
      },
      deviceOpen: (isOpen) {
        if (isOpen) {
          showSnackBar(title: 'USB监测', message: '地磅连接成功！！！');
        } else {
          state.weight.value = 0;
        }
      },
      readWeight: (weight) => state.weight.value = weight,
      readError: () {
        state.weight.value = 0;
        showSnackBar(title: 'USB监测', message: '地磅连接异常！！！', isWarning: true);
      },
    );
    pdaScanner(scan: (code) {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(
          const Duration(milliseconds: 500), () => weighbridgeOpen());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      onKeyEvent: (key) {
        if (key.logicalKey == LogicalKeyboardKey.enter) {
          state.interceptorText = '';
        } else if (key.logicalKey.keyLabel.isNotEmpty) {
          state.interceptorText += key.logicalKey.keyLabel;
        }
      },
      focusNode: FocusNode(),
      child: pageBody(
        actions: [
          TextButton(onPressed: () => weighbridgeOpen(), child: Text('重新连接'))
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
                      child: Row(
                        children: [
                          expandedTextSpan(
                              hint: '派工单号：',
                              text: state.dispatchOrderNumber.value),
                          Text(
                            state.weight.value.toShowString(),
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 20),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.materialList.length,
                        itemBuilder: (c, i) => _item1(state.materialList[i]),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: CombinationButton(
                        text: '过账',
                        click: () {},
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
                      child: ListView.builder(
                        itemCount: 20,
                        itemBuilder: (c, i) => Text('1'),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: CombinationButton(
                        text: '查询历史',
                        click: () {},
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
