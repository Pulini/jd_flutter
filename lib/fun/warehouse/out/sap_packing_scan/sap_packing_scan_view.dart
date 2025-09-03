import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_scan_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_packing_scan/sap_packing_delivery_order_list_view.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_packing_scan/sap_packing_scan_label_view.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/scanner.dart';

import 'sap_packing_scan_logic.dart';
import 'sap_packing_scan_state.dart';

class SapPackingScanPage extends StatefulWidget {
  const SapPackingScanPage({super.key});

  @override
  State<SapPackingScanPage> createState() => _SapPackingScanPageState();
}

class _SapPackingScanPageState extends State<SapPackingScanPage> {
  final SapPackingScanLogic logic = Get.put(SapPackingScanLogic());
  final SapPackingScanState state = Get.find<SapPackingScanLogic>().state;

  var dpcDate = DatePickerController(
    PickerType.date,
    buttonName: '计划船期',
    saveKey: '${RouteConfig.sapPackingScan.name}${PickerType.date}',
  );
  var opcDestination = OptionsPickerController(
    PickerType.sapDestination,
    saveKey: '${RouteConfig.sapPackingScan.name}${PickerType.sapDestination}',
  );
  var lopcFactoryAndWarehouse = LinkOptionsPickerController(
    PickerType.sapFactoryWarehouse,
    saveKey:
        '${RouteConfig.sapPackingScan.name}${PickerType.sapFactoryWarehouse}',
  );

  _operationSheet() {
    var tecNumber = TextEditingController(
      text: spGet(spSavePackingScanActualCabinet) ?? '',
    );

    var number = EditText(
      hint: '实际柜号',
      controller: tecNumber,
      hasClose: false,
    );

    var cancel = CombinationButton(
      combination: Combination.left,
      backgroundColor: Colors.red,
      text: '退出',
      click: () => exitDialog(
        content: '确定要退出装柜扫码吗？',
        confirm: () => Get.until((v) => v.isFirst),
      ),
    );

    var deliveryOrderList = CombinationButton(
      combination: Combination.middle,
      text: '交货单列表',
      click: () {
        if (tecNumber.text.isEmpty) {
          errorDialog(content: '请输入实际柜号!');
          return;
        }
        if (!opcDestination.isReady()) {
          errorDialog(content: '请选择目的地!');
          return;
        }
        logic.queryDeliveryOrders(
          plannedDate: dpcDate.getDateFormatYMD(),
          destination: opcDestination.getPickItem().pickerId(),
          cabinetNumber: tecNumber.text,
          toDeliveryOrderList: () {
            Get.back();
            Get.to(() => const SapPackingDeliveryOrderListPage());
          },
        );
      },
    );

    var confirm = CombinationButton(
      combination: Combination.right,
      text: '确定',
      click: () {
        var actualCabinet = tecNumber.text;
        if (actualCabinet.isEmpty) {
          errorDialog(content: '请输入实际柜号!');
          return;
        }
        if (!opcDestination.isReady()) {
          errorDialog(content: '请选择目的地!');
          return;
        }
        if (!lopcFactoryAndWarehouse.isReady()) {
          errorDialog(content: '请选择工厂和仓库!');
          return;
        }
        state.plannedDate = dpcDate.getDate();
        state.destination = opcDestination.getPickItem();
        state.factory = lopcFactoryAndWarehouse.getPickItem1();
        state.warehouse = lopcFactoryAndWarehouse.getPickItem2();
        state.actualCabinet = actualCabinet;
        spSave(spSavePackingScanActualCabinet, actualCabinet);
        state.abnormalList.clear();
        state.materialSearchText.value = '';
        Get.back();
      },
    );

    var widgets = <Widget>[];
    if (state.plannedDate != null &&
        state.destination != null &&
        state.factory != null &&
        state.warehouse != null) {
      widgets = [
        const SizedBox(height: 20),
        number,
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              expandedTextSpan(
                hint: '计划船期：',
                text: getDateYMD(time: state.plannedDate),
              ),
              textSpan(
                hint: '目的地：',
                text: state.destination?.toShow() ?? '',
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: textSpan(
            hint: '工厂：',
            text: state.factory?.toShow() ?? '',
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
          child: textSpan(
            hint: '仓库：',
            text: state.warehouse?.toShow() ?? '',
          ),
        ),
        Row(
          children: [
            Expanded(child: cancel),
            Expanded(child: deliveryOrderList),
            Expanded(child: confirm),
          ],
        ),
      ];
    } else {
      widgets = [
        const SizedBox(height: 20),
        number,
        DatePicker(pickerController: dpcDate),
        OptionsPicker(pickerController: opcDestination),
        LinkOptionsPicker(pickerController: lopcFactoryAndWarehouse),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: cancel),
            Expanded(child: deliveryOrderList),
            Expanded(child: confirm),
          ],
        ),
      ];
    }

    showModalBottomSheet(
      isDismissible: false,
      context: context,
      elevation: 0,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      barrierColor: Colors.black.withValues(alpha: 0.25),
      constraints: BoxConstraints(
        maxHeight: context.getScreenSize().height -
            MediaQuery.of(context).viewInsets.top,
      ),
      isScrollControlled: true,
      builder: (ctx) => PopScope(
        canPop: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 10,
              top: 10,
              right: 10,
              bottom: 10 + MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: widgets,
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(SapPackingScanMaterialInfo data) => Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(data.trackNo ?? '', textAlign: TextAlign.center),
                ),
                Expanded(
                  flex: 2,
                  child: Text(data.quality.toShowString(),
                      textAlign: TextAlign.center),
                ),
                Expanded(
                  flex: 1,
                  child: Text(data.unit ?? '', textAlign: TextAlign.center),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    data.scannedCount().toShowString(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: textSpan(
                hint: '物料：',
                text: '(${data.materialNumber}) ${data.materialName}',
                maxLines: 3,
              ),
            ),
          ],
        ),
      );

  _pickDate({DateTime? date, required Function(String) callback}) {
    var pickDate = date ?? DateTime.now();
    showDatePicker(
      locale: View.of(Get.overlayContext!).platformDispatcher.locale,
      context: Get.overlayContext!,
      initialDate: pickDate,
      firstDate: DateTime(pickDate.year, pickDate.month - 1, pickDate.day),
      lastDate: DateTime(pickDate.year, pickDate.month + 1, pickDate.day),
    ).then((date) {
      if (date != null) {
        callback.call(getDateYMD(time: date));
      }
    });
  }

  _initScan() {
    pdaScanner(scan: (code) => logic.scanCode(code));
  }

  @override
  void initState() {
    _initScan();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _operationSheet();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      popTitle: '确定要退出装柜扫码吗？',
      actions: [
        IconButton(
          icon: const Icon(Icons.lock_outline),
          onPressed: () => logic.sealingCabinet(),
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => _operationSheet(),
        )
      ],
      body: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
          child: Column(
            children: [
              Row(
                children: [
                  Obx(() => textSpan(
                        hint: '件数：',
                        text: logic.getScanned().toString(),
                      )),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CupertinoSearchTextField(
                      decoration: BoxDecoration(
                        color: Colors.white54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      placeholder: '请输入物料编号货物料描或跟踪号述进行过滤',
                      onChanged: (v) => state.materialSearchText.value = v,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  expandedFrameText(
                    text: '跟踪号',
                    borderColor: Colors.black,
                    flex: 3,
                    backgroundColor: Colors.green.shade100,
                    alignment: Alignment.center,
                  ),
                  expandedFrameText(
                    text: '待装柜数',
                    borderColor: Colors.black,
                    flex: 2,
                    backgroundColor: Colors.green.shade100,
                    alignment: Alignment.center,
                  ),
                  expandedFrameText(
                    text: '单位',
                    borderColor: Colors.black,
                    flex: 1,
                    backgroundColor: Colors.green.shade100,
                    alignment: Alignment.center,
                  ),
                  expandedFrameText(
                    text: '扫码数量',
                    borderColor: Colors.black,
                    flex: 2,
                    backgroundColor: Colors.green.shade100,
                    alignment: Alignment.center,
                  ),
                ],
              ),
              Expanded(
                child: Obx(() {
                  var list = logic.showMaterialList();
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (c, i) => _item(list[i]),
                  );
                }),
              ),
              Row(children: [
                Expanded(
                    child: CombinationButton(
                  text: '查看扫码件',
                  combination: Combination.left,
                  click: () => Get.to(() => const SapPackingScanLabelPage()),
                )),
                Expanded(
                  child: CombinationButton(
                    text: '暂存',
                    combination: Combination.middle,
                    click: () => logic.checkMaterialSubmitData(
                      (list) => _pickDate(
                        callback: (date) => logic.saveLog(
                          postingDate: date,
                          submitList: list,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: CombinationButton(
                    text: '提交',
                    combination: Combination.right,
                    click: () => logic.checkMaterialSubmitData(
                      (list) => _pickDate(
                        callback: (date) => logic.submit(
                          postingDate: date,
                          submitList: list,
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
            ],
          )),
    );
  }

  @override
  void dispose() {
    Get.delete<SapPackingScanLogic>();
    super.dispose();
  }
}
