import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/wait_picking_material_info.dart';
import 'package:jd_flutter/fun/warehouse/out/wait_picking_material/wait_picking_material_dialog.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/check_box_widget.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';

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
    buttonName: '开工日期',
  )..firstDate = DateTime(
      DateTime.now().year - 5, DateTime.now().month, DateTime.now().day);

  var dpcEndDate = DatePickerController(
    PickerType.endDate,
    buttonName: '完工日期',
  );

  var dpcPostingDate = DatePickerController(
    PickerType.date,
    buttonName: '过账日期',
  );
  var lopcFactoryWarehouse = LinkOptionsPickerController(
    hasAll: true,
    PickerType.sapFactoryWarehouse,
    saveKey:
        '${RouteConfig.waitPickingMaterial.name}${PickerType.sapFactoryWarehouse}-Factory',
    buttonName: '工厂仓库',
  );
  var lopcWorkshopWarehouse = LinkOptionsPickerController(
    hasAll: true,
    PickerType.sapFactoryWarehouse,
    saveKey:
        '${RouteConfig.waitPickingMaterial.name}${PickerType.sapFactoryWarehouse}-Workshop',
    buttonName: '车间仓库',
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

  _showDepartmentOptions() {
    if (state.companyDepartmentList.isNotEmpty) {
      var groupController = FixedExtentScrollController();
      var subController = FixedExtentScrollController();
      var groupList = <Widget>[
        for (var group in state.companyDepartmentList)
          Center(child: Text(group.companyName ?? ''))
      ];
      var subList = <List<Widget>>[
        for (var group in state.companyDepartmentList)
          (group.departmentList ?? [])
              .map((sub) => Center(child: Text(sub.departmentName ?? '')))
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
                  Expanded(child: Container()),
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

  _query() {
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
      factory: lopcFactoryWarehouse.getOptionsPicker1().pickerId(),
      factoryWarehouse: lopcFactoryWarehouse.getOptionsPicker2().pickerId(),
      workshopWarehouse: lopcWorkshopWarehouse.getOptionsPicker2().pickerId(),
      supplier: opcSupplier.selectedId.value,
      processFlow: opcProcessFlow.selectedId.value,
    );
  }

  _clearQueryParam() {
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

  _itemSubTitleFlag(String text, bool flag) => Text(
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

  _item(WaitPickingMaterialOrderInfo data) {
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
              '修改勾选项',
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
              '查看批次',
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
              hint: '库位：',
              text: data.location ?? '',
            ),
            Expanded(
              flex: 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _itemSubTitleFlag('配色', data.colorSeparationLogo == 'X'),
                  _itemSubTitleFlag('批次', data.batchIdentification == 'X'),
                  _itemSubTitleFlag('多领', data.multiCollarLogo == 'X'),
                  Obx(() => textSpan(
                        hint: '线边库存：',
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
                            '即时库存：${data.getRealTimeInventory().toFixed(3).toShowString()}',
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
                          onTap: () {
                            data.isBaseUnit.value = !data.isBaseUnit.value;
                          },
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
                        title: '总数',
                        data: data.getTotal().toFixed(3).toShowString(),
                      ),
                      _itemSubTitle(
                        title: '未下达数',
                        data: data.getUnRelease().toFixed(3).toShowString(),
                      ),
                      _itemSubTitle(
                        title: '已领',
                        data: data.getReceived().toFixed(3).toShowString(),
                      ),
                      _itemSubTitle(
                        title: '未领',
                        data: data.getUnreceived().toFixed(3).toShowString(),
                      ),
                      _itemSubTitle(
                        title: '本次领料',
                        data: data.getPickingString(
                          lopcWorkshopWarehouse.getOptionsPicker2().pickerId(),
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
          colors: [Colors.blue.shade100, Colors.green.shade50],
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
                    hint: '指令：',
                    text: data.moNo ?? '',
                    textColor: Colors.blue.shade900,
                  ),
                  const SizedBox(width: 20),
                  expandedTextSpan(
                    isBold: false,
                    hint: '部位：',
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

  _pickingMaterial() {
    logic.checkPickingMaterial(
      needCheck: () => checkPickerDialog(
        confirm: (picker) => livenFaceVerification(
          faceUrl: picker.picUrl ?? '',
          verifySuccess: (pickerBase64) => livenFaceVerification(
            faceUrl: userInfo?.picUrl ?? '',
            verifySuccess: (userBase64) => _picking(
              pickerNumber: picker.empCode ?? '',
              pickerBase64: pickerBase64,
              userBase64: userBase64,
            ),
          ),
        ),
      ),
      picking: () => _picking(),
    );
  }

  _picking({
    String? pickerNumber,
    String? pickerBase64,
    String? userBase64,
  }) {
    logic.pickingMaterial(
      pickerNumber: pickerNumber,
      pickerBase64: pickerBase64,
      userBase64: userBase64,
      refresh: (msg) => askDialog(
        title: 'dialog_default_title_information'.tr,
        content: msg,
        confirmText: '打印物料清单',
        confirm: () => logic.printMaterialList(),
        cancel: () => _query(),
      ),
      modifyLocation: (rList, msg) {
        modifyLocationDialog(
          list: rList,
          back: () => askDialog(
            content: msg,
            confirmText: '打印物料清单',
            confirm: () => logic.printMaterialList(),
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
                        hint: '指令(销售订单)',
                        controller: tecInstruction,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: EditText(
                        hint: '物料编码',
                        controller: tecMaterialCode,
                      ),
                    ),
                    Expanded(
                      child: EditText(
                        hint: '客户采购订单号',
                        controller: tecClientPurchaseOrder,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: EditText(
                        hint: '采购凭证',
                        controller: tecPurchaseVoucher,
                      ),
                    ),
                    Expanded(
                      child: EditText(
                        hint: '生产需求数量',
                        controller: tecProductionDemand,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: EditText(
                          hint: '领料人工号',
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
                            name: '所有',
                            value: state.queryParamOrderType.value == 0,
                          )),
                      Obx(() => CheckBox(
                            onChanged: (v) => v
                                ? state.queryParamOrderType.value = 1
                                : state.queryParamOrderType.value = 0,
                            name: '正单',
                            value: state.queryParamOrderType.value == 1,
                          )),
                      Obx(() => CheckBox(
                            onChanged: (v) => v
                                ? state.queryParamOrderType.value = 2
                                : state.queryParamOrderType.value = 0,
                            name: '正单委外',
                            value: state.queryParamOrderType.value == 2,
                          )),
                      Obx(() => CheckBox(
                            onChanged: (v) => v
                                ? state.queryParamOrderType.value = 3
                                : state.queryParamOrderType.value = 0,
                            name: '补单',
                            value: state.queryParamOrderType.value == 3,
                          )),
                      Obx(() => CheckBox(
                            onChanged: (v) => v
                                ? state.queryParamOrderType.value = 4
                                : state.queryParamOrderType.value = 0,
                            name: '补单委外',
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
                            name: '所有可领物料',
                            value: state.queryParamAllCanPick.value,
                          )),
                      Obx(() => CheckBox(
                            onChanged: (v) =>
                                state.queryParamShowNoInventory.value = v,
                            name: '显示无库存',
                            value: state.queryParamShowNoInventory.value,
                          )),
                      Obx(() => CheckBox(
                            onChanged: (v) =>
                                state.queryParamReceived.value = v,
                            name: '显示已领物料',
                            value: state.queryParamReceived.value,
                          )),
                      Obx(() => CheckBox(
                            onChanged: (v) =>
                                state.queryParamIsShowAll.value = v,
                            name: '显示全部物料',
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
                        text: '清空条件',
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
              if (!didPop) exitDialog(content: '确定要推出本次领料吗？');
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
                      text: '移库发货',
                      click: () {logic.printMaterialList();},
                    ),
                  ),
                  Expanded(
                    child: CombinationButton(
                      combination: Combination.right,
                      text: '领料',
                      click: _pickingMaterial,
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
