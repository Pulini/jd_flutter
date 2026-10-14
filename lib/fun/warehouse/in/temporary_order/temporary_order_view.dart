import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/home_button.dart';
import 'package:jd_flutter/bean/http/response/temporary_order_info.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/extension_util.dart';
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
  var opcDivision = OptionsPickerController(
    hasAll: true,
    PickerType.sapDivision,
    saveKey: '${RouteConfig.temporaryOrder.name}${PickerType.sapDivision}',
  );
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

  void _query() {
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
      divisionId: opcDivision.selectedId.value,
      userNumber: tecInspectorNumber.text,
      trackNo: tecTrackNo.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    var materialCode = EditText(
      hint: 'temporary_order_material_number_query'.tr,
      controller: tecMaterialCode,
    );
    var temporaryNo = EditText(
      hint: 'temporary_order_temporary_no_query'.tr,
      controller: tecTemporaryNo,
    );
    var productionOrderNo = EditText(
      hint: 'temporary_order_production_no_query'.tr,
      controller: tecProductionOrderNo,
    );
    var typeBody = EditText(
      hint: 'temporary_order_type_body_query'.tr,
      controller: tecTypeBody,
    );
    var trackNo = EditText(
      hint: 'temporary_order_track_no_query'.tr,
      controller: tecTrackNo,
    );
    var inspectorNumber = EditText(
      hint: 'temporary_order_inspector_number_query'.tr,
      controller: tecInspectorNumber,
    );
    var showInspectionAbnormal = Obx(() => CheckBox(
          onChanged: (v) => state.showInspectionAbnormal.value = v,
          name: 'temporary_order_show_inspect_exception'.tr,
          value: state.showInspectionAbnormal.value,
        ));
    var company = OptionsPicker(pickerController: opcCompany);
    var supplier = OptionsPicker(pickerController: opcSupplier);
    var division = OptionsPicker(pickerController: opcDivision);
    var factory = OptionsPicker(pickerController: opcFactory);
    var startDate = DatePicker(pickerController: dpcStartDate);
    var endDate = DatePicker(pickerController: dpcEndDate);
    var orderTypeAll = Obx(() => CheckBox(
          onChanged: (v) => state.orderType.value = 1,
          name: 'temporary_order_type_all'.tr,
          value: state.orderType.value == 1,
        ));
    var orderTypeNotInspect = Obx(() => CheckBox(
          onChanged: (v) =>
              v ? state.orderType.value = 2 : state.orderType.value = 1,
          name: 'temporary_order_type_not_inspect'.tr,
          value: state.orderType.value == 2,
        ));
    var orderTypeInspected = Obx(() => CheckBox(
          onChanged: (v) =>
              v ? state.orderType.value = 3 : state.orderType.value = 1,
          name: 'temporary_order_type_inspected'.tr,
          value: state.orderType.value == 3,
        ));
    var orderDeleted = Obx(() => CheckBox(
          onChanged: (v) =>
              v ? state.orderType.value = 4 : state.orderType.value = 1,
          name: 'temporary_order_deleted'.tr,
          value: state.orderType.value == 4,
        ));
    var queryButton = SizedBox(
      width: double.infinity,
      child: CombinationButton(
        text: 'page_title_with_drawer_query'.tr,
        click: _query,
      ),
    );
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
          width: getScreenSize().width * (isPad() ? 0.6 : 0.8),
          child: Drawer(
            child: ListView(
              children: isPad()
                  ? [
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: materialCode),
                          Expanded(child: temporaryNo),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: productionOrderNo),
                          Expanded(child: typeBody),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(flex: 2, child: trackNo),
                          Expanded(child: inspectorNumber),
                          Expanded(child: showInspectionAbnormal),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: company),
                          Expanded(child: supplier),
                          Expanded(child: division),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: factory),
                          Expanded(child: startDate),
                          Expanded(child: endDate),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          orderTypeAll,
                          orderTypeNotInspect,
                          orderTypeInspected,
                          orderDeleted,
                        ],
                      ),
                      const SizedBox(height: 30),
                      queryButton,
                      const SizedBox(height: 30),
                    ]
                  : [
                      materialCode,
                      temporaryNo,
                      productionOrderNo,
                      typeBody,
                      trackNo,
                      inspectorNumber,
                      showInspectionAbnormal,
                      company,
                      supplier,
                      division,
                      factory,
                      startDate,
                      endDate,
                      orderTypeAll,
                      orderTypeNotInspect,
                      orderTypeInspected,
                      orderDeleted,
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 30),
                        child: queryButton,
                      ),
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
              itemBuilder: (c, i) => isPad()
                  ? _TmpOrderItem(
                      index: i,
                      state: state,
                      logic: logic,
                      onQuery: () => _query(),
                    )
                  : _TmpOrderPhoneItem(
                      index: i,
                      state: state,
                      logic: logic,
                      onQuery: () => _query(),
                    ),
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

class _TmpOrderItem extends StatelessWidget {
  final int index;
  final TemporaryOrderState state;
  final TemporaryOrderLogic logic;
  final VoidCallback onQuery;

  const _TmpOrderItem({
    required this.index,
    required this.state,
    required this.logic,
    required this.onQuery,
  });

  @override
  Widget build(BuildContext context) {
    var group = state.temporaryOrderList[index];
    var fromToday = group[0].fromToday();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey, width: 2),
        gradient: LinearGradient(
          colors: [
            group[0].finishType == 'X'
                ? Colors.blue.shade50
                : fromToday >= 5
                    ? Colors.red.shade200
                    : fromToday == 4
                        ? Colors.orange.shade100
                        : Colors.blue.shade50,
            Colors.white
          ],
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
                              onQuery();
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
          for (var subItem in group)
            _TmpOrderSubItem(data: subItem, logic: logic, onQuery: onQuery),
        ],
      ),
    );
  }
}

class _TmpOrderPhoneItem extends StatelessWidget {
  final int index;
  final TemporaryOrderState state;
  final TemporaryOrderLogic logic;
  final VoidCallback onQuery;

  const _TmpOrderPhoneItem({
    required this.index,
    required this.state,
    required this.logic,
    required this.onQuery,
  });

  @override
  Widget build(BuildContext context) {
    var group = state.temporaryOrderList[index];
    var fromToday = group[0].fromToday();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey, width: 2),
        gradient: LinearGradient(
          colors: [
            group[0].finishType == 'X'
                ? Colors.blue.shade50
                : fromToday >= 5
                    ? Colors.red.shade200
                    : fromToday == 4
                        ? Colors.orange.shade100
                        : Colors.blue.shade50,
            Colors.white
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    textSpan(
                      hint: 'temporary_order_supplier'.tr,
                      hintColor: Colors.black54,
                      text: group[0].supplierName ?? '',
                      textColor: Colors.red,
                    ),
                    textSpan(
                      hint: 'temporary_order_final_customer'.tr,
                      isBold: false,
                      hintColor: Colors.black54,
                      text: group[0].finalCustomer ?? '',
                      textColor: Colors.blue.shade900,
                    ),
                    textSpan(
                      hint: 'temporary_order_temporary_no'.tr,
                      isBold: false,
                      hintColor: Colors.black54,
                      text: group[0].temporaryNo ?? '',
                      textColor: Colors.blue.shade900,
                    ),
                    textSpan(
                      hint: 'temporary_order_temporary_date'.tr,
                      isBold: false,
                      hintColor: Colors.black54,
                      text: group[0].billDate ?? '',
                      textColor: Colors.blue.shade900,
                    ),
                    textSpan(
                      hint: 'temporary_order_temporary_worker'.tr,
                      isBold: false,
                      hintColor: Colors.black54,
                      text: group[0].biller ?? '',
                      textColor: Colors.blue.shade900,
                    ),
                    textSpan(
                      hint: 'temporary_order_factory'.tr,
                      isBold: false,
                      hintColor: Colors.black54,
                      text: group[0].factoryName ?? '',
                      textColor: Colors.blue.shade900,
                    ),
                    textSpan(
                      hint: 'temporary_order_storage_location'.tr,
                      isBold: false,
                      hintColor: Colors.black54,
                      text: group[0].storageLocationName ?? '',
                      textColor: Colors.blue.shade900,
                    ),
                    textSpan(
                      hint: 'temporary_order_remark'.tr,
                      isBold: false,
                      maxLines: 3,
                      hintColor: Colors.black54,
                      text: group[0].remark ?? '',
                      textColor: Colors.blue.shade900,
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
                              onQuery();
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
          for (var subItem in group)
            _TmpOrderPhoneSubItem(
                data: subItem, logic: logic, onQuery: onQuery),
        ],
      ),
    );
  }
}

class _TmpOrderSubItem extends StatelessWidget {
  final TemporaryOrderInfo data;
  final TemporaryOrderLogic logic;
  final VoidCallback onQuery;

  const _TmpOrderSubItem({
    required this.data,
    required this.logic,
    required this.onQuery,
  });

  @override
  Widget build(BuildContext context) {
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
                          flex: 3,
                          hint: 'temporary_order_type_body'.tr,
                          isBold: false,
                          hintColor: Colors.black54,
                          text: data.model.ifEmpty(data.distributionType ?? ''),
                          textColor: Colors.blue.shade900,
                        ),
                        expandedTextSpan(
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
                  text: 'temporary_order_detail_inspection'.tr,
                  combination: Combination.left,
                  click: () {
                    if (checkUserPermission('105180501')) {
                      logic.viewTemporaryOrderDetail(
                          inspection: true,
                          temporaryNo: data.temporaryNo ?? '',
                          materialCode: data.materialCode ?? '',
                          success: () {
                            onQuery();
                          });
                    } else {
                      errorDialog(
                        content: 'temporary_order_detail_no_permission'.tr,
                      );
                    }
                  }),
              CombinationButton(
                text: 'temporary_order_view_detail'.tr,
                combination: Combination.right,
                click: () => logic.viewTemporaryOrderDetail(
                  inspection: false,
                  temporaryNo: data.temporaryNo ?? '',
                  materialCode: data.materialCode ?? '',
                  success: () {
                    onQuery();
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _TmpOrderPhoneSubItem extends StatelessWidget {
  final TemporaryOrderInfo data;
  final TemporaryOrderLogic logic;
  final VoidCallback onQuery;

  const _TmpOrderPhoneSubItem({
    required this.data,
    required this.logic,
    required this.onQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          textSpan(
            hint: 'temporary_order_material'.tr,
            isBold: false,
            maxLines: 2,
            hintColor: Colors.black54,
            text: '(${data.materialCode}) ${data.materialName}',
            textColor: Colors.blue.shade900,
          ),
          textSpan(
            hint: 'temporary_order_temporary_qty'.tr,
            isBold: false,
            hintColor: Colors.black54,
            text: data.temporaryQty(),
            textColor: Colors.blue.shade900,
          ),
          textSpan(
            hint: 'temporary_order_type_body'.tr,
            isBold: false,
            hintColor: Colors.black54,
            text: data.model.ifEmpty(data.distributionType ?? ''),
            textColor: Colors.blue.shade900,
          ),
          textSpan(
            hint: 'temporary_order_remark'.tr,
            isBold: false,
            hintColor: Colors.black54,
            text: data.detailRemark ?? '',
            textColor: Colors.blue.shade900,
          ),
          Row(
            children: [
              Expanded(
                child: CombinationButton(
                    text: 'temporary_order_detail_inspection'.tr,
                    combination: Combination.left,
                    click: () {
                      if (checkUserPermission('105180501')) {
                        logic.viewTemporaryOrderDetail(
                            inspection: true,
                            temporaryNo: data.temporaryNo ?? '',
                            materialCode: data.materialCode ?? '',
                            success: () {
                              onQuery();
                            });
                      } else {
                        errorDialog(
                          content: 'temporary_order_detail_no_permission'.tr,
                        );
                      }
                    }),
              ),
              Expanded(
                child: CombinationButton(
                  text: 'temporary_order_view_detail'.tr,
                  combination: Combination.right,
                  click: () => logic.viewTemporaryOrderDetail(
                    inspection: false,
                    temporaryNo: data.temporaryNo ?? '',
                    materialCode: data.materialCode ?? '',
                    success: () {
                      onQuery();
                    },
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
