import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/delivery_order_info.dart';
import 'package:jd_flutter/fun/warehouse/in/delivery_order/delivery_order_check_view.dart';
import 'package:jd_flutter/fun/warehouse/in/delivery_order/delivery_order_detail_view.dart';
import 'package:jd_flutter/fun/warehouse/in/delivery_order/delivery_order_dialog.dart';
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
    saveKey: '${RouteConfig.deliveryOrder.name}${PickerType.sapCompany}',
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
      DateTime.now().year - 3,
      DateTime.now().month,
      DateTime.now().day,
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
    return GestureDetector(
      onTap: () => logic.getOrderDetail(
          isExempt: data[0].isExempt ?? false,
          isCheckOrder: false,
          produceOrderNo: data[0].produceOrderNo ?? '',
          factoryNumber: data[0].factoryName ?? '',
          deliNo: data[0].deliNo ?? '',
          workCenterID:
              userInfo?.sapRole == '003' ? opcWorkCenter.selectedId.value : '',
          goTo: () => Get.to(() => const DeliveryOrderDetailPage())),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        foregroundDecoration: data[0].hasSubscript()
            ? RotatedCornerDecoration.withColor(
                color: data[0].isInspected() ? Colors.orange : Colors.green,
                badgeCornerRadius: const Radius.circular(8),
                badgeSize: const Size(45, 45),
                textSpan: TextSpan(
                  text: data[0].isInspected() ? 'delivery_order_checked'.tr : 'delivery_order_temporarily_received'.tr,
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
                            hint: 'delivery_order_supplier'.tr,
                            text: data[0].supplierName ?? '',
                            textColor: Colors.red,
                          ),
                          expandedTextSpan(
                            hint: 'delivery_order_company'.tr,
                            hintColor: Colors.black45,
                            text: data[0].companyCode ?? '',
                            textColor: Colors.black45,
                          ),
                          expandedTextSpan(
                            hint: 'delivery_order_factory'.tr,
                            hintColor: Colors.black45,
                            text: data[0].factoryName ?? '',
                            textColor: Colors.black45,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          expandedTextSpan(
                            hint: 'delivery_order_deliver_no'.tr,
                            hintColor: Colors.black45,
                            text: data[0].deliNo ?? '',
                            textColor: Colors.black45,
                          ),
                          expandedTextSpan(
                            hint: 'delivery_order_delivery_location'.tr,
                            hintColor: Colors.black45,
                            text: data[0].deliveryLocation ?? '',
                            textColor: Colors.black45,
                          ),
                          expandedTextSpan(
                            hint: 'delivery_order_build_date'.tr,
                            hintColor: Colors.black45,
                            text: data[0].billDate ?? '',
                            textColor: Colors.black45,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          expandedTextSpan(
                            hint: 'delivery_order_piece'.tr,
                            hintColor: Colors.black45,
                            text: data[0].numPage ?? '',
                          ),
                          expandedTextSpan(
                            hint: 'delivery_order_location_storage'.tr,
                            hintColor: Colors.black45,
                            text: data[0].locationName ?? '',
                            textColor: Colors.black45,
                          ),
                          expandedTextSpan(
                            hint: 'delivery_order_match_code'.tr,
                            hintColor: Colors.black45,
                            text: data[0].matchCode ?? '',
                            textColor: Colors.black45,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          expandedTextSpan(
                            hint: 'delivery_order_final_customer'.tr,
                            hintColor: Colors.black45,
                            text: data[0].finalCustomer ?? '',
                            textColor: Colors.black45,
                          ),
                          expandedTextSpan(
                            hint: 'delivery_order_track_no'.tr,
                            hintColor: Colors.black45,
                            text: data[0].trackNo ?? '',
                            textColor: Colors.black45,
                          ),
                          expandedTextSpan(
                            hint: 'delivery_order_remark'.tr,
                            hintColor: Colors.black45,
                            text: data[0].remark ?? '',
                            textColor: Colors.black45,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Obx(() => Checkbox(
                      value: data.every((v) => v.isSelected.value),
                      onChanged: (c) {
                        for (var v in data) {
                          v.isSelected.value = c!;
                        }
                      },
                    )),
              ],
            ),
            const Divider(indent: 10, endIndent: 10),
            for (var item in data) _subItem(item),
            Row(
              children: [
                CombinationButton(
                  text: 'delivery_order_check'.tr,
                  click: () => logic.getOrderDetail(
                    isExempt: data[0].isExempt ?? false,
                    isCheckOrder: false,
                    produceOrderNo: data[0].produceOrderNo ?? '',
                    factoryNumber: data[0].factoryName ?? '',
                    deliNo: data[0].deliNo ?? '',
                    workCenterID: userInfo?.sapRole == '003'
                        ? opcWorkCenter.selectedId.value
                        : '',
                    goTo: () => Get.to(
                      () => const DeliveryOrderCheckPage(),
                    )?.then((v) {
                      logic.cleanCheck();
                      if (v != null && v) _query();
                    }),
                  ),
                ),
                Expanded(child: Container()),
                Text(
                  data[0].isExempt == true ? 'delivery_order_exempt'.tr : 'delivery_order_not_exempt'.tr,
                  style: TextStyle(
                    color: data[0].isExempt == true ? Colors.blue : Colors.red,
                  ),
                ),
                const SizedBox(width: 20),
                Text(
                  data[0].isPackingMaterials == true ? 'delivery_order_in_and_out'.tr : 'delivery_order_not_in_and_out'.tr,
                  style: TextStyle(
                    color: data[0].isPackingMaterials == true
                        ? Colors.blue
                        : Colors.red,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _subItem(DeliveryOrderInfo item) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textSpan(
              hint: 'delivery_order_material'.tr, text: '(${item.materialCode}) ${item.materialName}'),
          Row(
            children: [
              expandedTextSpan(
                flex: 2,
                hint: 'delivery_order_delivery_qty'.tr,
                text: item.deliveryQty().toShowString(),
              ),
              expandedTextSpan(
                flex: 2,
                hint: 'delivery_order_check_qty'.tr,
                text: item.deliveryQty().toShowString(),
              ),
              expandedTextSpan(
                flex: 4,
                hint: 'delivery_order_factory_type_body'.tr,
                text: item.model ?? '',
              ),
              expandedTextSpan(
                hint: 'delivery_order_coefficient'.tr,
                text: item.coefficient ?? '',
              ),
              expandedTextSpan(
                hint: 'delivery_order_comm_unit'.tr,
                text: item.commUnit ?? '',
              ),
              expandedTextSpan(
                hint: 'delivery_order_base_unit'.tr,
                text: item.baseUnit ?? '',
              ),
            ],
          ),
          const Divider(indent: 10, endIndent: 10),
        ],
      );

  _inputReason({required Function(String) callback}) {
    reasonInputPopup(
      title: [
        Center(
          child: Text(
            'delivery_order_revere_reason'.tr,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        )
      ],
      hintText: 'delivery_order_input_reason'.tr,
      confirmText: 'delivery_order_reverse'.tr,
      confirm: callback,
      isCanCancel: true,
    );
  }

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
                        hint: 'delivery_order_type_body'.tr,
                        controller: tecTypeBody,
                      ),
                    ),
                    Expanded(
                      child: EditText(
                        hint: 'delivery_order_instruction'.tr,
                        controller: tecInstruction,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: EditText(
                        hint: 'delivery_order_purchase_no'.tr,
                        controller: tecPurchaseOrder,
                      ),
                    ),
                    Expanded(
                      child: EditText(
                        hint: 'delivery_order_material_code'.tr,
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
                        hint: 'delivery_order_worker_number'.tr,
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
                                name: 'delivery_order_all'.tr,
                                value: state.orderType.value == 1,
                              )),
                          Obx(() => CheckBox(
                                onChanged: (v) => v
                                    ? state.orderType.value = 2
                                    : state.orderType.value = 1,
                                name: 'delivery_order_created_temporary'.tr,
                                value: state.orderType.value == 2,
                              )),
                          Obx(() => CheckBox(
                                onChanged: (v) => v
                                    ? state.orderType.value = 3
                                    : state.orderType.value = 1,
                                name: 'delivery_order_not_created_temporary'.tr,
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
                          name: 'delivery_order_all'.tr,
                          value: state.stockType.value == 0,
                        )),
                    Obx(() => CheckBox(
                          onChanged: (v) => v
                              ? state.stockType.value = 1
                              : state.stockType.value = 0,
                          name: 'delivery_order_not_stock_in'.tr,
                          value: state.stockType.value == 1,
                        )),
                    Obx(() => CheckBox(
                          onChanged: (v) => v
                              ? state.stockType.value = 2
                              : state.stockType.value = 0,
                          name: 'delivery_order_wait_stock_out'.tr,
                          value: state.stockType.value == 2,
                        )),
                    Obx(() => CheckBox(
                          onChanged: (v) => v
                              ? state.stockType.value = 3
                              : state.stockType.value = 0,
                          name: 'delivery_order_stock_outed'.tr,
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
              if (!didPop) exitDialog(content: 'delivery_order_exit_tips'.tr);
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
              Obx(() => Row(
                    children: [
                      Expanded(
                        child: CombinationButton(
                          combination: Combination.left,
                          isEnabled: state.deliveryOrderList.any(
                            (v) => v.any((v2) => v2.isSelected.value),
                          ),
                          text: 'delivery_order_stock_in'.tr,
                          click: () => stockInDialog(
                            submitList: logic.getSelectedList(),
                            workerCenterId: opcWorkCenter.selectedId.value,
                            refresh: _query,
                          ),
                        ),
                      ),
                      Expanded(
                        child: CombinationButton(
                          combination: Combination.middle,
                          isEnabled: state.deliveryOrderList.any(
                            (v) => v.any((v2) => v2.isSelected.value),
                          ),
                          text: 'delivery_order_stock_in_reverse'.tr,
                          click: () => logic.checkReversalStockIn(
                            reversalWithCode: (list) {
                              //标签功能尚未使用，先执行直接冲销
                              _inputReason(
                                callback: (reason) => logic.reversalStockIn(
                                  workCenterID: opcWorkCenter.selectedId.value,
                                  reason: reason,
                                  labels: list,
                                  refresh: _query,
                                ),
                              );
                            },
                            reversal: () => _inputReason(
                              callback: (reason) => logic.reversalStockIn(
                                workCenterID: opcWorkCenter.selectedId.value,
                                reason: reason,
                                refresh: _query,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: CombinationButton(
                          combination: Combination.middle,
                          isEnabled: state.deliveryOrderList.any(
                            (v) => v.any((v2) => v2.isSelected.value),
                          ),
                          text: 'delivery_order_stock_out'.tr,
                          click: () => stockOutDialog(
                            workerCenterId: opcWorkCenter.selectedId.value,
                            submitList: logic.getSelectedList(),
                            refresh: () {},
                          ),
                        ),
                      ),
                      Expanded(
                        child: CombinationButton(
                          combination: Combination.middle,
                          isEnabled: state.deliveryOrderList.any(
                            (v) => v.any((v2) => v2.isSelected.value),
                          ),
                          text: 'delivery_order_stock_out_reverse'.tr,
                          click: () => logic.checkReversalStockOut(
                            reversal: () => _inputReason(
                              callback: (reason) => logic.reversalStockOut(
                                workCenterID: opcWorkCenter.selectedId.value,
                                reason: reason,
                                refresh: _query,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: CombinationButton(
                          combination: Combination.right,
                          isEnabled: state.deliveryOrderList.any(
                            (v) => v.any((v2) => v2.isSelected.value),
                          ),
                          text: 'delivery_order_create_temporary'.tr,
                          click: () => stockOutReversalDialog(
                            submitList: logic.getSelectedList(),
                            refresh: _query,
                          ),
                        ),
                      ),
                    ],
                  ))
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
