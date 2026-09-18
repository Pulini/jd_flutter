import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_scan_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_packing_scan/sap_packing_delivery_order_list_view.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_packing_scan/sap_packing_scan_label_view.dart';
import 'package:jd_flutter/route.dart';

import 'package:jd_flutter/utils/extension_util.dart';
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
    buttonName: 'sap_packing_scan_planned_ship_date'.tr,
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

  void _operationSheet() {
    var tecNumber = TextEditingController(
      text: spGet(spSavePackingScanActualCabinet) ?? '',
    );

    var number = EditText(
      hint: 'sap_packing_scan_actual_cabinet'.tr,
      controller: tecNumber,
      hasClose: false,
    );

    var cancel = CombinationButton(
      combination: Combination.left,
      backgroundColor: Colors.red,
      text: 'sap_packing_scan_exit'.tr,
      click: () => exitDialog(
        content: 'sap_packing_scan_exit_scan_confirm'.tr,
        confirm: () => Get.until((v) => v.isFirst),
      ),
    );

    var deliveryOrderList = CombinationButton(
      combination: Combination.middle,
      text: 'sap_packing_scan_delivery_order_list'.tr,
      click: () {
        if (tecNumber.text.trim().length>11) {
          errorDialog(content: 'sap_packing_scan_cabinet_length_error'.tr);
          return;
        }
        if (tecNumber.text.isEmpty) {
          errorDialog(content: 'sap_packing_scan_please_input_cabinet'.tr);
          return;
        }
        if (!opcDestination.isReady()) {
          errorDialog(content: 'sap_packing_scan_please_select_destination'.tr);
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
      text: 'sap_packing_scan_confirm'.tr,
      click: () {
        var actualCabinet = tecNumber.text;
        if (actualCabinet.isEmpty) {
          errorDialog(content: 'sap_packing_scan_please_input_cabinet'.tr);
          return;
        }
        if (!opcDestination.isReady()) {
          errorDialog(content: 'sap_packing_scan_please_select_destination'.tr);
          return;
        }
        if (!lopcFactoryAndWarehouse.isReady()) {
          errorDialog(content: 'sap_packing_scan_please_select_factory_warehouse'.tr);
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
                hint: 'sap_packing_scan_planned_ship_date_colon'.tr,
                text: getDateYMD(time: state.plannedDate),
              ),
              textSpan(
                hint: 'sap_packing_scan_destination_colon'.tr,
                text: state.destination?.toShow() ?? '',
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: textSpan(
            hint: 'sap_packing_scan_factory_colon'.tr,
            text: state.factory?.toShow() ?? '',
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
          child: textSpan(
            hint: 'sap_packing_scan_warehouse_colon'.tr,
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
        maxHeight: getScreenSize().height -
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

  Widget _item(SapPackingScanMaterialInfo data) =>
      _SapPackingScanMaterialItem(data: data);

  void _pickDate({DateTime? date, required Function(String) callback}) {
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

  void _initScan() {
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
      popTitle: 'sap_packing_scan_exit_scan_confirm'.tr,
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
                        hint: 'sap_packing_scan_piece_count_colon'.tr,
                        text: logic.getScanned().toString(),
                      )),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CupertinoSearchTextField(
                      decoration: BoxDecoration(
                        color: Colors.white54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      placeholder: 'sap_packing_scan_search_placeholder'.tr,
                      onChanged: (v) => state.materialSearchText.value = v,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ExpandedFrameText(
                    text: 'sap_packing_scan_track_no'.tr,
                    borderColor: Colors.black,
                    flex: 3,
                    backgroundColor: Colors.green.shade100,
                    alignment: Alignment.center,
                  ),
                  ExpandedFrameText(
                    text: 'sap_packing_scan_pending_qty'.tr,
                    borderColor: Colors.black,
                    flex: 2,
                    backgroundColor: Colors.green.shade100,
                    alignment: Alignment.center,
                  ),
                  ExpandedFrameText(
                    text: 'sap_packing_scan_unit'.tr,
                    borderColor: Colors.black,
                    flex: 1,
                    backgroundColor: Colors.green.shade100,
                    alignment: Alignment.center,
                  ),
                  ExpandedFrameText(
                    text: 'sap_packing_scan_scanned_qty'.tr,
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
                  text: 'sap_packing_scan_view_scanned'.tr,
                  combination: Combination.left,
                  click: () => Get.to(() => const SapPackingScanLabelPage()),
                )),
                Expanded(
                  child: CombinationButton(
                    text: 'sap_packing_scan_temp_save'.tr,
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
                    text: 'sap_packing_scan_submit'.tr,
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

class _SapPackingScanMaterialItem extends StatelessWidget {
  final SapPackingScanMaterialInfo data;

  const _SapPackingScanMaterialItem({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              hint: 'sap_packing_scan_material_colon'.tr,
              text: '(${data.materialNumber}) ${data.materialName}',
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }
}
