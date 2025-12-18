import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/home_button.dart';
import 'package:jd_flutter/bean/http/response/wait_picking_material_info.dart';
import 'package:jd_flutter/fun/warehouse/out/wait_picking_material/wait_picking_material_dialog.dart';
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
import 'package:jd_flutter/widget/signature_page.dart';

import 'wait_picking_material_logic.dart';
import 'wait_picking_material_state.dart';

class WaitPickingMaterialPage extends StatefulWidget {
  const WaitPickingMaterialPage({super.key});

  @override
  State<WaitPickingMaterialPage> createState() =>
      _WaitPickingMaterialPageState();
}

class _WaitPickingMaterialPageState extends State<WaitPickingMaterialPage> {
  final WaitPickingMaterialLogic logic = Get.put(WaitPickingMaterialLogic());
  final WaitPickingMaterialState state =
      Get.find<WaitPickingMaterialLogic>().state;
  var scaffoldKey = GlobalKey<ScaffoldState>();

  var tecTypeBody = TextEditingController();
  var tecInstruction = TextEditingController();
  var tecMaterialCode = TextEditingController();
  var tecClientPurchaseOrder = TextEditingController();
  var tecPurchaseVoucher = TextEditingController();
  var tecProductionDemand = TextEditingController();
  var tecPickerNumber = TextEditingController();

  var dpcStartDate = DatePickerController(
    PickerType.startDate,
    saveKey: '${RouteConfig.waitPickingMaterial.name}${PickerType.startDate}',
    buttonName: 'wait_picking_material_order_start_date'.tr,
  )..firstDate = DateTime(
      DateTime.now().year - 5, DateTime.now().month, DateTime.now().day);

  var dpcEndDate = DatePickerController(
    PickerType.endDate,
    buttonName: 'wait_picking_material_order_end_date'.tr,
  );

  var dpcPostingDate = DatePickerController(
    PickerType.date,
    buttonName: 'wait_picking_material_order_post_date'.tr,
  );
  var lopcFactoryWarehouse = LinkOptionsPickerController(
    hasAll: true,
    PickerType.sapFactoryWarehouse,
    saveKey:
        '${RouteConfig.waitPickingMaterial.name}${PickerType.sapFactoryWarehouse}-Factory',
    buttonName: 'wait_picking_material_order_factory_warehouse'.tr,
  );
  var lopcWorkshopWarehouse = LinkOptionsPickerController(
    hasAll: true,
    PickerType.sapFactoryWarehouse,
    saveKey:
        '${RouteConfig.waitPickingMaterial.name}${PickerType.sapFactoryWarehouse}-Workshop',
    buttonName: 'wait_picking_material_order_workshop_warehouse'.tr,
  );
  var opcSupplier = OptionsPickerController(
    hasAll: true,
    PickerType.sapSupplier,
    saveKey: '${RouteConfig.waitPickingMaterial.name}${PickerType.sapSupplier}',
  );

  var opcProcessFlow = OptionsPickerController(
    hasAll: true,
    PickerType.sapProcessFlow,
    saveKey:
        '${RouteConfig.waitPickingMaterial.name}${PickerType.sapProcessFlow}',
  );

  Widget? drawer;

  void _showDepartmentOptions() {
    if (state.companyDepartmentList.isNotEmpty) {
      var groupController = FixedExtentScrollController();
      var subController = FixedExtentScrollController();
      var groupList = <String>[
        for (var group in state.companyDepartmentList) group.companyName ?? ''
      ];
      var subList = <List<String>>[
        for (var group in state.companyDepartmentList)
          (group.departmentList ?? [])
              .map((sub) => sub.departmentName ?? '')
              .toList()

      ];
      showPopup(
        Column(
          children: [
            Container(
              height: 80,
              color: Colors.grey[200],
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'dialog_default_cancel'.tr,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Expanded(child: Container()),
                  TextButton(
                    onPressed: () {
                      Get.back();
                      logic.selectedDepartment(
                        group: groupController.selectedItem,
                        sub: subController.selectedItem,
                      );
                    },
                    child: Text(
                      'dialog_default_confirm'.tr,
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                child: getLinkCupertinoPicker(
              groupItems: groupList,
              subItems: subList,
              groupController: groupController,
              subController: subController,
            )),
          ],
        ),
      );
    }
  }

  void _query() {
    logic.query(
      typeBody: tecTypeBody.text,
      instruction: tecInstruction.text,
      materialCode: tecMaterialCode.text,
      clientPurchaseOrder: tecClientPurchaseOrder.text,
      purchaseVoucher: tecPurchaseVoucher.text,
      productionDemand: tecProductionDemand.text,
      pickerNumber: tecPickerNumber.text,
      startDate: dpcStartDate.getDateFormatYMD(),
      endDate: dpcEndDate.getDateFormatYMD(),
      postingDate: dpcPostingDate.getDateFormatYMD(),
      factory: lopcFactoryWarehouse.getPickItem1().pickerId(),
      factoryWarehouse: lopcFactoryWarehouse.getPickItem2().pickerId(),
      workshopWarehouse: lopcWorkshopWarehouse.getPickItem2().pickerId(),
      supplier: opcSupplier.selectedId.value,
      processFlow: opcProcessFlow.selectedId.value,
    );
  }

  void _clearQueryParam() {
    tecTypeBody.text = '';
    tecInstruction.text = '';
    tecMaterialCode.text = '';
    tecClientPurchaseOrder.text = '';
    tecPurchaseVoucher.text = '';
    tecProductionDemand.text = '';
    tecPickerNumber.text = '';
    dpcStartDate.select(DateTime.now());
    dpcEndDate.select(DateTime.now());
    dpcPostingDate.select(DateTime.now());
    lopcFactoryWarehouse.select(0, 0);
    lopcWorkshopWarehouse.select(0, 0);
    opcSupplier.select(0);
    opcProcessFlow.select(0);
    state.queryParamOrderType.value = 0;
    state.queryParamAllCanPick.value = false;
    state.queryParamShowNoInventory.value = false;
    state.queryParamReceived.value = false;
    state.queryParamIsShowAll.value = false;
  }

  Text _itemSubTitleFlag(String text, bool flag) => Text(
        '$text：${flag ? '√' : 'X'}',
        style: TextStyle(
          color: flag ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      );

  Widget _itemSubTitle({required String title, required String data}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
          Text(
            data,
            style: TextStyle(
              color: Colors.blue.shade900,
            ),
          )
        ],
      ),
    );
  }

  Container _item(WaitPickingMaterialOrderInfo data) {
    var textButtonPadding =
        const EdgeInsets.only(left: 7, top: 3, right: 7, bottom: 3);
    var itemTitle = Row(
      children: [
        Expanded(
          child: Text(
            maxLines: 2,
            '(${data.rawMaterialCode}) ${data.rawMaterialDescription}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade900,
            ),
          ),
        ),
        Text(
          data.factoryName ?? '',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade900,
          ),
        ),
      ],
    );

    var itemBatchModifyButton = Obx(() => GestureDetector(
          onTap: () {
            if (data.canBatchModify()) {
              logic.goDetail(data, -1);
            }
          },
          child: Container(
            padding: textButtonPadding,
            decoration: BoxDecoration(
              border: Border.all(
                color: data.canBatchModify() ? Colors.blue : Colors.red,
                width: 2,
              ),
              borderRadius: data.batchDataNull()
                  ? const BorderRadius.all(
                      Radius.circular(20),
                    )
                  : const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
            ),
            child: Text(
              'wait_picking_material_order_modify_selected'.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: data.canBatchModify() ? Colors.blue : Colors.red,
              ),
            ),
          ),
        ));

    var itemViewBatchButton = Obx(() => GestureDetector(
          onTap: () => batchAndColorSystemDialog(
            data: logic.getDetailBatchSelectedList(data),
          ),
          child: Container(
            padding: const EdgeInsets.only(
              left: 5,
              top: 3,
              right: 5,
              bottom: 3,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: data.canViewBatch() ? Colors.blue : Colors.red,
                width: 2,
              ),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Text(
              'wait_picking_material_order_view_batch'.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: data.canViewBatch() ? Colors.blue : Colors.red,
              ),
            ),
          ),
        ));

    var itemSubTitle = Column(
      children: [
        Row(
          children: [
            expandedTextSpan(
              flex: 3,
              hint: 'wait_picking_material_order_location'.tr,
              text: data.location ?? '',
            ),
            Expanded(
              flex: 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _itemSubTitleFlag(
                    'wait_picking_material_order_color'.tr,
                    data.colorSeparationLogo == 'X',
                  ),
                  _itemSubTitleFlag(
                    'wait_picking_material_order_batch'.tr,
                    data.batchIdentification == 'X',
                  ),
                  _itemSubTitleFlag(
                    'wait_picking_material_order_take_more'.tr,
                    data.multiCollarLogo == 'X',
                  ),
                  Obx(() => textSpan(
                        hint: 'wait_picking_material_order_line_inventory'.tr,
                        text: data.getLineInventory().toFixed(3).toShowString(),
                        textColor: Colors.black54,
                      )),
                  GestureDetector(
                    onTap: () => logic.getRealTimeInventory(
                      show: (list) => realTimeInventoryDialog(list: list),
                    ),
                    child: Container(
                      padding: textButtonPadding,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Obx(() => Text(
                            'wait_picking_material_order_real_time_inventory'
                                .trArgs(
                              [
                                data
                                    .getRealTimeInventory()
                                    .toFixed(3)
                                    .toShowString()
                              ],
                            ),
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                    ),
                  ),
                  data.basicUnit == data.commonUnits
                      ? Padding(
                          padding: textButtonPadding,
                          child: Text(
                            data.getUnit(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: () =>
                              data.isBaseUnit.value = !data.isBaseUnit.value,
                          child: Container(
                            padding: textButtonPadding,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue, width: 2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Obx(() => Text(
                                  data.getUnit(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                )),
                          ),
                        )
                ],
              ),
            )
          ],
        ),
        Row(
          children: [
            Obx(() => Checkbox(
                  activeColor: Colors.blue,
                  side: const BorderSide(
                    color: Colors.red,
                    width: 2,
                  ),
                  value: data.hasSelected(),
                  onChanged: (v) => logic.selectOrderAll(v!, data),
                )),
            const SizedBox(width: 10),
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  itemBatchModifyButton,
                  if (!data.batchDataNull()) itemViewBatchButton,
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: Obx(() => Row(
                    children: [
                      _itemSubTitle(
                        title: 'wait_picking_material_order_total'.tr,
                        data: data.getTotal().toFixed(3).toShowString(),
                      ),
                      _itemSubTitle(
                        title: 'wait_picking_material_order_not_dispatch'.tr,
                        data: data.getUnRelease().toFixed(3).toShowString(),
                      ),
                      _itemSubTitle(
                        title: 'wait_picking_material_order_received_qty'.tr,
                        data: data.getReceived().toFixed(3).toShowString(),
                      ),
                      _itemSubTitle(
                        title: 'wait_picking_material_order_unreceived_qty'.tr,
                        data: data.getUnreceived().toFixed(3).toShowString(),
                      ),
                      _itemSubTitle(
                        title: 'wait_picking_material_order_picking_qty'.tr,
                        data: data.getPickingString(
                          lopcWorkshopWarehouse.getPickItem2().pickerId(),
                        ),
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ],
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade50, Colors.white],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey, width: 2),
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        title: itemTitle,
        subtitle: itemSubTitle,
        children: [
          for (var i = 0; i < (data.items ?? []).length; ++i)
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 55),
              child: _subItem(data, i),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _subItem(WaitPickingMaterialOrderInfo order, int index) {
    WaitPickingMaterialOrderSubInfo data = order.items![index];
    double proportion = order.getProportion();
    RxBool isBaseUnit = order.isBaseUnit;

    return GestureDetector(
      onTap: () => logic.goDetail(order, index),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black54, width: 1),
        ),
        child: Row(
          children: [
            Obx(() => Checkbox(
                  activeColor: Colors.blue,
                  side: const BorderSide(
                    color: Colors.red,
                    width: 2,
                  ),
                  value: data.selectedCount() > 0,
                  onChanged: (v) => logic.selectSubItemAll(v!, data),
                )),
            const SizedBox(width: 10),
            Expanded(
              flex: 4,
              child: Row(
                children: <Widget>[
                  Text(
                    data.getOrderType(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(width: 20),
                  textSpan(
                    isBold: false,
                    hint: 'wait_picking_material_order_instruction'.tr,
                    text: data.moNo ?? '',
                    textColor: Colors.blue.shade900,
                  ),
                  const SizedBox(width: 20),
                  expandedTextSpan(
                    isBold: false,
                    hint: 'wait_picking_material_order_part'.tr,
                    maxLines: 2,
                    text: data.position ?? '',
                    textColor: Colors.blue.shade900,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  Expanded(
                    child: Obx(() => Text(
                          data
                              .getTotal(proportion, isBaseUnit.value)
                              .toFixed(3)
                              .toShowString(),
                          textAlign: TextAlign.end,
                          style: TextStyle(color: Colors.blue.shade900),
                        )),
                  ),
                  Expanded(
                    child: Obx(() => Text(
                          data
                              .getUnRelease(proportion, isBaseUnit.value)
                              .toFixed(3)
                              .toShowString(),
                          textAlign: TextAlign.end,
                          style: TextStyle(color: Colors.blue.shade900),
                        )),
                  ),
                  Expanded(
                    child: Obx(() => Text(
                          data
                              .getReceived(proportion, isBaseUnit.value)
                              .toFixed(3)
                              .toShowString(),
                          textAlign: TextAlign.end,
                          style: TextStyle(color: Colors.blue.shade900),
                        )),
                  ),
                  Expanded(
                    child: Obx(() => Text(
                          data
                              .getUnreceived(proportion, isBaseUnit.value)
                              .toFixed(3)
                              .toShowString(),
                          textAlign: TextAlign.end,
                          style: TextStyle(color: Colors.blue.shade900),
                        )),
                  ),
                  Expanded(
                    child: Obx(() => Text(
                          data
                              .getPicking(proportion, isBaseUnit.value)
                              .toFixed(3)
                              .toShowString(),
                          textAlign: TextAlign.end,
                          style: TextStyle(color: Colors.blue.shade900),
                        )),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickingMaterial({required bool isMove, required bool isPosting}) {
    logic.checkPickingMaterial(
      oneFaceCheck: () {
        //委外
        Get.to(() => SignaturePage(
              name: userInfo?.name ?? '',
              callback: (userBase64) => _picking(
                isMove: isMove,
                isPosting: isPosting,
                userBase64: base64Encode(userBase64.buffer.asUint8List()),
              ),
            ));
        // livenFaceVerification(
        //   faceUrl: userInfo?.picUrl ?? '',
        //   verifySuccess: (userBase64) => _picking(
        //     isMove: isMove,
        //     isPosting: isPosting,
        //     userBase64: userBase64,
        //   ),
        // );
      },
      twoFaceCheck: () {
        //厂内
        if (isPosting) {
          checkPickerDialog(
            confirm: (picker) => Get.to(() => SignaturePage(
                  name: picker.empName ?? '',
                  callback: (pickerBase64) => Get.to(() => SignaturePage(
                        name: userInfo?.name ?? '',
                        callback: (userBase64) => _picking(
                          isMove: isMove,
                          isPosting: isPosting,
                          pickerNumber: picker.empCode ?? '',
                          pickerBase64:
                              base64Encode(pickerBase64.buffer.asUint8List()),
                          userBase64:
                              base64Encode(userBase64.buffer.asUint8List()),
                        ),
                      )),
                )),
          );
          // checkPickerDialog(
          //   confirm: (picker) => livenFaceVerification(
          //     faceUrl: picker.picUrl ?? '',
          //     verifySuccess: (pickerBase64) => livenFaceVerification(
          //       faceUrl: userInfo?.picUrl ?? '',
          //       verifySuccess: (userBase64) => _picking(
          //         isMove: isMove,
          //         isPosting: isPosting,
          //         pickerNumber: picker.empCode ?? '',
          //         pickerBase64: pickerBase64,
          //         userBase64: userBase64,
          //       ),
          //     ),
          //   ),
          // );
        } else {
          errorDialog(content: 'wait_picking_material_order_error_tips'.tr);
        }
      },
    );
  }

  void _picking({
    required bool isMove,
    required bool isPosting,
    String? pickerNumber,
    String? pickerBase64,
    String? userBase64,
  }) {
    logic.pickingMaterial(
      isMove: isMove,
      isPosting: isPosting,
      pickerNumber: pickerNumber,
      pickerBase64: pickerBase64,
      userBase64: userBase64,
      refresh: (msg, number) => askDialog(
        title: 'dialog_default_title_information'.tr,
        content: msg,
        confirmText: 'wait_picking_material_order_print'.tr,
        confirm: () => logic.printMaterialList(number),
        cancel: () => _query(),
      ),
      modifyLocation: (rList, msg, number) {
        modifyLocationDialog(
          list: rList,
          back: () => askDialog(
            content: msg,
            confirmText: 'wait_picking_material_order_print'.tr,
            confirm: () => logic.printMaterialList(number),
            cancel: () => _query(),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
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
          width: getScreenSize().width * 0.6,
          child: Drawer(
            child: ListView(
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: EditText(
                        hint: 'wait_picking_material_order_type_body'.tr,
                        controller: tecTypeBody,
                      ),
                    ),
                    Expanded(
                      child: EditText(
                        hint: 'wait_picking_material_order_sales_order_no'.tr,
                        controller: tecInstruction,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: EditText(
                        hint: 'wait_picking_material_order_material_code'.tr,
                        controller: tecMaterialCode,
                      ),
                    ),
                    Expanded(
                      child: EditText(
                        hint:
                            'wait_picking_material_order_customer_purchase_order_no'
                                .tr,
                        controller: tecClientPurchaseOrder,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: EditText(
                        hint: 'wait_picking_material_order_purchasing_documents'
                            .tr,
                        controller: tecPurchaseVoucher,
                      ),
                    ),
                    Expanded(
                      child: EditText(
                        hint:
                            'wait_picking_material_order_production_demand_qty'
                                .tr,
                        controller: tecProductionDemand,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: EditText(
                          hint: 'wait_picking_material_order_picker_number'.tr,
                          controller: tecPickerNumber,
                          onChanged: (v) {
                            if (v.length >= 6) {
                              state.getPickerInfo(
                                pickerNumber: v,
                                success: () => _showDepartmentOptions(),
                                error: (msg) => errorDialog(content: msg),
                              );
                            }
                          }),
                    ),
                    Obx(() => GestureDetector(
                          onTap: () => _showDepartmentOptions(),
                          child: Text(state.queryParamDepartment.value),
                        )),
                    Expanded(
                      child: DatePicker(
                        pickerController: dpcPostingDate,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: OptionsPicker(
                        pickerController: opcProcessFlow,
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
                      child: LinkOptionsPicker(
                        pickerController: lopcFactoryWarehouse,
                      ),
                    ),
                    Expanded(
                      child: LinkOptionsPicker(
                        pickerController: lopcWorkshopWarehouse,
                      ),
                    ),
                  ],
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Obx(() => CheckBox(
                            onChanged: (v) =>
                                state.queryParamOrderType.value = 0,
                            name: 'wait_picking_material_order_all'.tr,
                            value: state.queryParamOrderType.value == 0,
                          )),
                      Obx(() => CheckBox(
                            onChanged: (v) => v
                                ? state.queryParamOrderType.value = 1
                                : state.queryParamOrderType.value = 0,
                            name:
                                'wait_picking_material_order_positive_order'.tr,
                            value: state.queryParamOrderType.value == 1,
                          )),
                      Obx(() => CheckBox(
                            onChanged: (v) => v
                                ? state.queryParamOrderType.value = 2
                                : state.queryParamOrderType.value = 0,
                            name:
                                'wait_picking_material_order_positive_order_outsource'
                                    .tr,
                            value: state.queryParamOrderType.value == 2,
                          )),
                      Obx(() => CheckBox(
                            onChanged: (v) => v
                                ? state.queryParamOrderType.value = 3
                                : state.queryParamOrderType.value = 0,
                            name: 'wait_picking_material_order_supplement_order'
                                .tr,
                            value: state.queryParamOrderType.value == 3,
                          )),
                      Obx(() => CheckBox(
                            onChanged: (v) => v
                                ? state.queryParamOrderType.value = 4
                                : state.queryParamOrderType.value = 0,
                            name:
                                'wait_picking_material_order_supplement_order_outsource'
                                    .tr,
                            value: state.queryParamOrderType.value == 4,
                          )),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Obx(() => CheckBox(
                            onChanged: (v) =>
                                state.queryParamAllCanPick.value = v,
                            name:
                                'wait_picking_material_order_all_can_pick_material'
                                    .tr,
                            value: state.queryParamAllCanPick.value,
                          )),
                      Obx(() => CheckBox(
                            onChanged: (v) =>
                                state.queryParamShowNoInventory.value = v,
                            name:
                                'wait_picking_material_order_show_no_inventory'
                                    .tr,
                            value: state.queryParamShowNoInventory.value,
                          )),
                      Obx(() => CheckBox(
                            onChanged: (v) =>
                                state.queryParamReceived.value = v,
                            name:
                                'wait_picking_material_order_show_received'.tr,
                            value: state.queryParamReceived.value,
                          )),
                      Obx(() => CheckBox(
                            onChanged: (v) =>
                                state.queryParamIsShowAll.value = v,
                            name:
                                'wait_picking_material_order_show_all_material'
                                    .tr,
                            value: state.queryParamIsShowAll.value,
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: CombinationButton(
                        combination: Combination.left,
                        text: 'wait_picking_material_order_clear'.tr,
                        click: () => _clearQueryParam(),
                      ),
                    ),
                    Expanded(
                      child: CombinationButton(
                        combination: Combination.right,
                        text: 'page_title_with_drawer_query'.tr,
                        click: () {
                          scaffoldKey.currentState?.closeEndDrawer();
                          _query();
                        },
                      ),
                    ),
                  ],
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
              if (!didPop) {
                exitDialog(content: 'wait_picking_material_order_exit_tips'.tr);
              }
            }
          },
          child: Column(
            children: [
              Expanded(
                child: Obx(() => ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: state.orderList.length,
                      itemBuilder: (c, i) => _item(state.orderList[i]),
                    )),
              ),
              Row(
                children: [
                  Expanded(
                    child: CombinationButton(
                      combination: Combination.left,
                      text: 'wait_picking_material_order_move_deliver'.tr,
                      click: () => _pickingMaterial(
                        isMove: true,
                        isPosting: true,
                      ),
                    ),
                  ),
                  Expanded(
                    child: CombinationButton(
                      combination: Combination.middle,
                      text:
                          'wait_picking_material_order_preparing_materials'.tr,
                      click: () => _pickingMaterial(
                        isMove: false,
                        isPosting: false,
                      ),
                    ),
                  ),
                  Expanded(
                    child: CombinationButton(
                      combination: Combination.right,
                      text: 'wait_picking_material_order_picking_posting'.tr,
                      click: () => _pickingMaterial(
                        isMove: false,
                        isPosting: true,
                      ),
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
    Get.delete<WaitPickingMaterialLogic>();
    super.dispose();
  }
}
