import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/delivery_order_info.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/check_box_widget.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';

import 'delivery_order_logic.dart';
import 'delivery_order_state.dart';

class DeliveryOrderPage extends StatefulWidget {
  const DeliveryOrderPage({super.key});

  @override
  State<DeliveryOrderPage> createState() => _DeliveryOrderPageState();
}

class _DeliveryOrderPageState extends State<DeliveryOrderPage> {
  final DeliveryOrderLogic logic = Get.put(DeliveryOrderLogic());
  final DeliveryOrderState state = Get.find<DeliveryOrderLogic>().state;
  var scaffoldKey = GlobalKey<ScaffoldState>();

  var tecTypeBody = TextEditingController();
  var tecInstruction = TextEditingController();
  var tecPurchaseOrder = TextEditingController();
  var tecMaterialCode = TextEditingController();
  var tecWorkerNumber = TextEditingController();

  var opcCompany = OptionsPickerController(
    hasAll: true,
    PickerType.sapCompany,
    saveKey: '${RouteConfig.deliveryOrder.name}${PickerType.sapProcessFlow}',
  );

  var opcSupplier = OptionsPickerController(
    hasAll: true,
    PickerType.sapSupplier,
    saveKey: '${RouteConfig.deliveryOrder.name}${PickerType.sapSupplier}',
  );

  var lopcFactoryWarehouse = LinkOptionsPickerController(
    hasAll: true,
    PickerType.sapFactoryWarehouse,
    saveKey:
        '${RouteConfig.deliveryOrder.name}${PickerType.sapFactoryWarehouse}-Factory',
  );
  var opcWorkCenter = OptionsPickerController(
    hasAll: true,
    PickerType.sapWorkCenter,
    saveKey: '${RouteConfig.deliveryOrder.name}${PickerType.sapSupplier}',
  );

  var dpcStartDate = DatePickerController(
    PickerType.startDate,
    saveKey: '${RouteConfig.deliveryOrder.name}${PickerType.startDate}',
  )..firstDate = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day - 7,
    );

  var dpcEndDate = DatePickerController(
    PickerType.endDate,
    saveKey: '${RouteConfig.deliveryOrder.name}${PickerType.endDate}',
  );

  _query() {
    scaffoldKey.currentState?.closeEndDrawer();
    logic.queryDeliveryOrders(
      startDate: dpcStartDate.getDateFormatYMD(),
      endDate: dpcEndDate.getDateFormatYMD(),
      typeBody: tecTypeBody.text.toString(),
      instruction: tecInstruction.text.toString(),
      supplier: opcSupplier.selectedId.value,
      purchaseOrder: tecPurchaseOrder.text.toString(),
      materialCode: tecMaterialCode.text.toString(),
      company: opcCompany.selectedId.value,
      workerNumber: tecWorkerNumber.text.toString(),
      workCenter: opcWorkCenter.selectedId.value,
      warehouse: lopcFactoryWarehouse.getOptionsPicker2().pickerId(),
      factory: lopcFactoryWarehouse.getOptionsPicker1().pickerId(),
    );
  }

  Widget _item(int index) {
    var data = state.deliveryOrderList[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      foregroundDecoration: data[0].hasSubscript()
          ? RotatedCornerDecoration.withColor(
              color: data[0].isInspected() ? Colors.yellow : Colors.green,
              badgeCornerRadius: const Radius.circular(8),
              badgeSize: const Size(45, 45),
              textSpan: TextSpan(
                text: data[0].isInspected() ? '已清点' : '已暂收',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            )
          : null,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        expandedTextSpan(
                          hint: '供应商：',
                          text: data[0].supplierName ?? '',
                          textColor: Colors.red,
                        ),
                        expandedTextSpan(
                          hint: '客户：',
                          hintColor: Colors.black45,
                          text: data[0].companyCode ?? '',
                          textColor: Colors.black45,
                        ),
                        expandedTextSpan(
                          hint: '工厂：',
                          hintColor: Colors.black45,
                          text: data[0].factoryName ?? '',
                          textColor: Colors.black45,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        expandedTextSpan(
                          hint: '送货单号：',
                          hintColor: Colors.black45,
                          text: data[0].deliNo ?? '',
                          textColor: Colors.black45,
                        ),
                        expandedTextSpan(
                          hint: '送货地点：',
                          hintColor: Colors.black45,
                          text: data[0].deliveryLocation ?? '',
                          textColor: Colors.black45,
                        ),
                        expandedTextSpan(
                          hint: '制单日期：',
                          hintColor: Colors.black45,
                          text: data[0].billDate ?? '',
                          textColor: Colors.black45,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        expandedTextSpan(
                          hint: '件数：',
                          hintColor: Colors.black45,
                          text: data[0].numPage ?? '',
                        ),
                        expandedTextSpan(
                          hint: '存储仓库：',
                          hintColor: Colors.black45,
                          text: data[0].locationName ?? '',
                          textColor: Colors.black45,
                        ),
                        expandedTextSpan(
                          hint: '配码：',
                          hintColor: Colors.black45,
                          text: data[0].matchCode ?? '',
                          textColor: Colors.black45,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        expandedTextSpan(
                          hint: '最终客户：',
                          hintColor: Colors.black45,
                          text: data[0].finalCustomer ?? '',
                          textColor: Colors.black45,
                        ),
                        expandedTextSpan(
                          flex: 2,
                          hint: '备注：',
                          hintColor: Colors.black45,
                          text: data[0].remark ?? '',
                          textColor: Colors.black45,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Checkbox(
                  value: data.every((v) => v.isSelected.value),
                  onChanged: (c) {
                    for (var v in data) {
                      v.isSelected.value = c!;
                    }
                  })
            ],
          ),
          const Divider(indent: 10, endIndent: 10),
          for (var item in data) _subItem(item),
          Row(
            children: [
              CombinationButton(text: '仓库员清点', click: (){}),
              Expanded(child: Container()),
              if(data[0].isExempt==true)
                Text('')
            ],
          )
        ],
      ),
    );
  }

  Widget _subItem(DeliveryOrderInfo item) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textSpan(
              hint: '物料：', text: '(${item.materialCode}) ${item.materialName}'),
          Row(
            children: [
              expandedTextSpan(
                flex: 2,
                hint: '送货数量：',
                text: item.deliveryQty().toShowString(),
              ),
              expandedTextSpan(
                flex: 2,
                hint: '核对数量：',
                text: item.deliveryQty().toShowString(),
              ),
              expandedTextSpan(
                flex: 4,
                hint: '工厂型体：',
                text: item.model??'',
              ),
              expandedTextSpan(
                hint: '系数：',
                text: item.coefficient??'',
              ),
              expandedTextSpan(
                hint: '常用单位：',
                text: item.commUnit??'',
              ),
              expandedTextSpan(
                hint: '基本单位：',
                text: item.baseUnit??'',
              ),
            ],
          ),
          const Divider(indent: 10, endIndent: 10),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: backgroundColor,
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(getFunctionTitle()),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              ),
            ),
          ],
        ),
        endDrawer: SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          child: Drawer(
            child: ListView(
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: EditText(
                        hint: '型体',
                        controller: tecTypeBody,
                      ),
                    ),
                    Expanded(
                      child: EditText(
                        hint: '指令',
                        controller: tecInstruction,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: EditText(
                        hint: '采购单号',
                        controller: tecPurchaseOrder,
                      ),
                    ),
                    Expanded(
                      child: EditText(
                        hint: '物料编码',
                        controller: tecMaterialCode,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: OptionsPicker(
                        pickerController: opcCompany,
                      ),
                    ),
                    Expanded(
                      child: OptionsPicker(
                        pickerController: opcSupplier,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: LinkOptionsPicker(
                        pickerController: lopcFactoryWarehouse,
                      ),
                    ),
                    Expanded(
                      child: OptionsPicker(
                        pickerController: opcWorkCenter,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: DatePicker(
                        pickerController: dpcStartDate,
                      ),
                    ),
                    Expanded(
                      child: DatePicker(
                        pickerController: dpcEndDate,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: EditText(
                        hint: '员工工号',
                        controller: tecWorkerNumber,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Obx(() => CheckBox(
                                onChanged: (v) => state.orderType.value = 1,
                                name: '全部',
                                value: state.orderType.value == 1,
                              )),
                          Obx(() => CheckBox(
                                onChanged: (v) => v
                                    ? state.orderType.value = 2
                                    : state.orderType.value = 1,
                                name: '已生成暂收单',
                                value: state.orderType.value == 2,
                              )),
                          Obx(() => CheckBox(
                                onChanged: (v) => v
                                    ? state.orderType.value = 3
                                    : state.orderType.value = 1,
                                name: '未生成暂收单',
                                value: state.orderType.value == 3,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Obx(() => CheckBox(
                          onChanged: (v) => state.stockType.value = 0,
                          name: '全部',
                          value: state.stockType.value == 0,
                        )),
                    Obx(() => CheckBox(
                          onChanged: (v) => v
                              ? state.stockType.value = 1
                              : state.stockType.value = 0,
                          name: '未入库',
                          value: state.stockType.value == 1,
                        )),
                    Obx(() => CheckBox(
                          onChanged: (v) => v
                              ? state.stockType.value = 2
                              : state.stockType.value = 0,
                          name: '待出库',
                          value: state.stockType.value == 2,
                        )),
                    Obx(() => CheckBox(
                          onChanged: (v) => v
                              ? state.stockType.value = 3
                              : state.stockType.value = 0,
                          name: '已出库',
                          value: state.stockType.value == 3,
                        )),
                  ],
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: CombinationButton(
                    text: 'page_title_with_drawer_query'.tr,
                    click: _query,
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
        body: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (scaffoldKey.currentState?.isEndDrawerOpen == true) {
              scaffoldKey.currentState?.closeEndDrawer();
            } else {
              if (!didPop) exitDialog(content: '确定要推出送货单列表吗？');
            }
          },
          child: Column(
            children: [
              Expanded(
                child: Obx(() => ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: state.deliveryOrderList.length,
                      itemBuilder: (c, i) => _item(i),
                    )),
              ),
              Row(
                children: [
                  Expanded(
                    child: CombinationButton(
                      combination: Combination.left,
                      text: '标签查询',
                      click: () {},
                    ),
                  ),
                  Expanded(
                    child: CombinationButton(
                      combination: Combination.middle,
                      text: '入库',
                      click: () {},
                    ),
                  ),
                  Expanded(
                    child: CombinationButton(
                      combination: Combination.middle,
                      text: '入库冲销',
                      click: () {},
                    ),
                  ),
                  Expanded(
                    child: CombinationButton(
                      combination: Combination.middle,
                      text: '出库',
                      click: () {},
                    ),
                  ),
                  Expanded(
                    child: CombinationButton(
                      combination: Combination.middle,
                      text: '出库冲销',
                      click: () {},
                    ),
                  ),
                  Expanded(
                    child: CombinationButton(
                      combination: Combination.right,
                      text: '生成暂收单',
                      click: () {},
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<DeliveryOrderLogic>();
    super.dispose();
  }
}
