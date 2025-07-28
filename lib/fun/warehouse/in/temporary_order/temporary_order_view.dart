import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/home_button.dart';
import 'package:jd_flutter/bean/http/response/temporary_order_info.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/check_box_widget.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';

import 'temporary_order_logic.dart';
import 'temporary_order_state.dart';

class TemporaryOrderPage extends StatefulWidget {
  const TemporaryOrderPage({super.key});

  @override
  State<TemporaryOrderPage> createState() => _TemporaryOrderPageState();
}

class _TemporaryOrderPageState extends State<TemporaryOrderPage> {
  final TemporaryOrderLogic logic = Get.put(TemporaryOrderLogic());
  final TemporaryOrderState state = Get.find<TemporaryOrderLogic>().state;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var tecMaterialCode = TextEditingController();
  var tecTemporaryNo = TextEditingController();
  var tecProductionOrderNo = TextEditingController();
  var tecTypeBody = TextEditingController();
  var tecTrackNo = TextEditingController();
  var tecInspectorNumber = TextEditingController();
  var opcCompany = OptionsPickerController(
    hasAll: true,
    PickerType.sapCompany,
    saveKey: '${RouteConfig.temporaryOrder.name}${PickerType.sapCompany}',
  );
  var opcSupplier = OptionsPickerController(
    hasAll: true,
    PickerType.sapSupplier,
    saveKey: '${RouteConfig.temporaryOrder.name}${PickerType.sapSupplier}',
  );
  var opcFactory = OptionsPickerController(
    hasAll: true,
    PickerType.sapFactory,
    saveKey: '${RouteConfig.temporaryOrder.name}${PickerType.sapFactory}',
  );
  var dpcStartDate = DatePickerController(
    PickerType.startDate,
    saveKey: '${RouteConfig.temporaryOrder.name}${PickerType.startDate}',
  )..firstDate = DateTime(
      DateTime.now().year - 3,
      DateTime.now().month,
      DateTime.now().day,
    );
  var dpcEndDate = DatePickerController(
    PickerType.endDate,
    saveKey: '${RouteConfig.temporaryOrder.name}${PickerType.endDate}',
  );

  _query() {
    scaffoldKey.currentState?.closeEndDrawer();
    logic.queryTemporaryOrders(
      startDate: dpcStartDate.getDateFormatYMD(),
      endDate: dpcEndDate.getDateFormatYMD(),
      temporaryNo: tecTemporaryNo.text,
      productionNumber: tecProductionOrderNo.text,
      factoryType: tecTypeBody.text,
      supplierName: opcSupplier.selectedId.value,
      materialCode: tecMaterialCode.text,
      factoryArea: opcCompany.selectedId.value,
      factoryNo: opcFactory.selectedId.value,
      userNumber: tecInspectorNumber.text,
      trackNo: tecTrackNo.text,
    );
  }

  Widget _item(int index) {
    var group = state.temporaryOrderList[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
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
                          hint: 'temporary_order_supplier'.tr,
                          hintColor: Colors.black54,
                          text: group[0].supplierName ?? '',
                          textColor: Colors.red,
                        ),
                        expandedTextSpan(
                          flex: 2,
                          hint: 'temporary_order_final_customer'.tr,
                          isBold: false,
                          hintColor: Colors.black54,
                          text: group[0].finalCustomer ?? '',
                          textColor: Colors.blue.shade900,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        expandedTextSpan(
                          hint: 'temporary_order_temporary_no'.tr,
                          isBold: false,
                          hintColor: Colors.black54,
                          text: group[0].temporaryNo ?? '',
                          textColor: Colors.blue.shade900,
                        ),
                        expandedTextSpan(
                          hint: 'temporary_order_temporary_date'.tr,
                          isBold: false,
                          hintColor: Colors.black54,
                          text: group[0].billDate ?? '',
                          textColor: Colors.blue.shade900,
                        ),
                        expandedTextSpan(
                          hint: 'temporary_order_temporary_worker'.tr,
                          isBold: false,
                          hintColor: Colors.black54,
                          text: group[0].biller ?? '',
                          textColor: Colors.blue.shade900,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        expandedTextSpan(
                          hint: 'temporary_order_factory'.tr,
                          isBold: false,
                          hintColor: Colors.black54,
                          text: group[0].factoryName ?? '',
                          textColor: Colors.blue.shade900,
                        ),
                        expandedTextSpan(
                          hint: 'temporary_order_storage_location'.tr,
                          isBold: false,
                          hintColor: Colors.black54,
                          text: group[0].storageLocationName ?? '',
                          textColor: Colors.blue.shade900,
                        ),
                        expandedTextSpan(
                          hint: 'temporary_order_remark'.tr,
                          isBold: false,
                          hintColor: Colors.black54,
                          text: group[0].remark ?? '',
                          textColor: Colors.blue.shade900,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => checkUserPermission('105180203')
                    ? reasonInputPopup(
                        title: [
                          Center(
                            child: Text(
                              'temporary_order_delete'.tr,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          )
                        ],
                        hintText: 'temporary_order_delete_reason'.tr,
                        tips: 'temporary_order_delete_tips'.tr,
                        isCanCancel: true,
                        confirm: (s) => logic.deleteTemporaryOrder(
                          temporaryNo: group[0].temporaryNo ?? '',
                          reason: s,
                          success: (msg) => successDialog(
                            content: msg,
                            back: () {
                              Get.back();
                              _query();
                            },
                          ),
                        ),
                      )
                    : errorDialog(content: 'temporary_order_no_permission'.tr),
                icon: const Icon(
                  Icons.delete_forever,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          for (var subItem in group) _subItem(subItem),
        ],
      ),
    );
  }

  Widget _subItem(TemporaryOrderInfo data) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Column(
        children: [
          const Divider(),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        expandedTextSpan(
                          flex: 3,
                          hint: 'temporary_order_material'.tr,
                          isBold: false,
                          hintColor: Colors.black54,
                          text: '(${data.materialCode}) ${data.materialName}',
                          textColor: Colors.blue.shade900,
                        ),
                        expandedTextSpan(
                          hint: 'temporary_order_temporary_qty'.tr,
                          isBold: false,
                          hintColor: Colors.black54,
                          text: data.temporaryQty(),
                          textColor: Colors.blue.shade900,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        expandedTextSpan(
                          hint: 'temporary_order_type_body'.tr,
                          isBold: false,
                          hintColor: Colors.black54,
                          text: data.model.ifEmpty(data.distributionType ?? ''),
                          textColor: Colors.blue.shade900,
                        ),
                        expandedTextSpan(
                          flex: 2,
                          hint: 'temporary_order_remark'.tr,
                          isBold: false,
                          hintColor: Colors.black54,
                          text: data.detailRemark ?? '',
                          textColor: Colors.blue.shade900,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              CombinationButton(
                text: 'temporary_order_view_detail'.tr,
                click: () => logic.viewTemporaryOrderDetail(
                  temporaryNo: data.temporaryNo ?? '',
                  materialCode: data.materialCode ?? '', success: () {
                  logic.queryTemporaryOrders(
                    startDate: dpcStartDate.getDateFormatYMD(),
                    endDate: dpcEndDate.getDateFormatYMD(),
                    temporaryNo: tecTemporaryNo.text,
                    productionNumber: tecProductionOrderNo.text,
                    factoryType: tecTypeBody.text,
                    supplierName: opcSupplier.selectedId.value,
                    materialCode: tecMaterialCode.text,
                    factoryArea: opcCompany.selectedId.value,
                    factoryNo: opcFactory.selectedId.value,
                    userNumber: tecInspectorNumber.text,
                    trackNo: tecTrackNo.text,
                  );
                },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: backgroundColor(),
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(functionTitle),
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
                        hint: 'temporary_order_material_number_query'.tr,
                        controller: tecMaterialCode,
                      ),
                    ),
                    Expanded(
                      child: EditText(
                        hint: 'temporary_order_temporary_no_query'.tr,
                        controller: tecTemporaryNo,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: EditText(
                        hint: 'temporary_order_production_no_query'.tr,
                        controller: tecProductionOrderNo,
                      ),
                    ),
                    Expanded(
                      child: EditText(
                        hint: 'temporary_order_type_body_query'.tr,
                        controller: tecTypeBody,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: EditText(
                        hint: 'temporary_order_track_no_query'.tr,
                        controller: tecTrackNo,
                      ),
                    ),
                    Expanded(
                      child: EditText(
                        hint: 'temporary_order_inspector_number_query'.tr,
                        controller: tecInspectorNumber,
                      ),
                    ),
                    Expanded(
                      child: Obx(() => CheckBox(
                            onChanged: (v) =>
                                state.showInspectionAbnormal.value = v,
                            name: 'temporary_order_show_inspect_exception'.tr,
                            value: state.showInspectionAbnormal.value,
                          )),
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
                      flex: 2,
                      child: OptionsPicker(
                        pickerController: opcSupplier,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: OptionsPicker(
                        pickerController: opcFactory,
                      ),
                    ),
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Obx(() => CheckBox(
                          onChanged: (v) => state.orderType.value = 1,
                          name: 'temporary_order_type_all'.tr,
                          value: state.orderType.value == 1,
                        )),
                    Obx(() => CheckBox(
                          onChanged: (v) => v
                              ? state.orderType.value = 2
                              : state.orderType.value = 1,
                          name: 'temporary_order_type_not_inspect'.tr,
                          value: state.orderType.value == 2,
                        )),
                    Obx(() => CheckBox(
                          onChanged: (v) => v
                              ? state.orderType.value = 3
                              : state.orderType.value = 1,
                          name: 'temporary_order_type_inspected'.tr,
                          value: state.orderType.value == 3,
                        )),
                    Obx(() => CheckBox(
                          onChanged: (v) => v
                              ? state.orderType.value = 4
                              : state.orderType.value = 1,
                          name: 'temporary_order_deleted'.tr,
                          value: state.orderType.value == 4,
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
              if (!didPop) exitDialog(content: 'temporary_order_exit_tips'.tr);
            }
          },
          child: Obx(
            () => ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.temporaryOrderList.length,
              itemBuilder: (c, i) => _item(i),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<TemporaryOrderLogic>();
    super.dispose();
  }
}
