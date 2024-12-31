import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_info.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_print_picking/sap_print_picking_detail_view.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/spinner_widget.dart';
import 'sap_print_picking_logic.dart';
import 'sap_print_picking_state.dart';

class SapPrintPickingPage extends StatefulWidget {
  const SapPrintPickingPage({super.key});

  @override
  State<SapPrintPickingPage> createState() => _SapPrintPickingPageState();
}

class _SapPrintPickingPageState extends State<SapPrintPickingPage> {
  final SapPrintPickingLogic logic = Get.put(SapPrintPickingLogic());
  final SapPrintPickingState state = Get.find<SapPrintPickingLogic>().state;
  var noticeNoController = TextEditingController();
  var instructionNoController = TextEditingController();
  var purchaseOrderController = TextEditingController();
  var typeBodyController = TextEditingController();
  var pickerController = TextEditingController();
  var spinnerControllerWorkShop = SpinnerController(
    saveKey: RouteConfig.sapPrintPicking.name,
    dataList: ['补单', '正单', '委外'],
  );
  var dpcStartDate = DatePickerController(
    PickerType.startDate,
    firstDate: DateTime(2023, 1, 1),
    saveKey: '${RouteConfig.sapPrintPicking.name}${PickerType.startDate}',
  );

  var dpcEndDate = DatePickerController(
    PickerType.endDate,
    saveKey: '${RouteConfig.sapPrintPicking.name}${PickerType.endDate}',
  );

  var workCenterController = OptionsPickerController(
    PickerType.sapWorkCenterNew,
    saveKey:
        '${RouteConfig.sapPrintPicking.name}${PickerType.sapWorkCenterNew}',
  );
  var supplierController = OptionsPickerController(
    hasAll: true,
    PickerType.sapSupplier,
    saveKey: '${RouteConfig.sapPrintPicking.name}${PickerType.sapSupplier}',
  );
  late LinkOptionsPickerController factoryWarehouseController;

  _item(SapPickingInfo data) {
    return GestureDetector(
      onTap: () => setState(() => data.select = !data.select),
      child: Container(
        margin: const EdgeInsets.only(left: 4, right: 4, bottom: 10),
        padding: const EdgeInsets.only(left: 4, right: 4),
        decoration: BoxDecoration(
          color: data.select ? Colors.blue.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: data.select
              ? Border.all(color: Colors.green, width: 2)
              : Border.all(color: Colors.white, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                expandedTextSpan(
                  hint: '合同号：',
                  text: data.purchaseOrder ?? '',
                  textColor: Colors.green,
                ),
                expandedTextSpan(
                  hint: '供应商：',
                  isBold: false,
                  text: data.supplierName ?? '',
                ),
              ],
            ),
            Row(
              children: [
                expandedTextSpan(
                  hint: '指令：',
                  text: data.instructionNo ?? '',
                  isBold: false,
                  textColor: Colors.grey.shade700,
                  hintColor: Colors.grey.shade700,
                ),
                expandedTextSpan(
                  hint: '型体：',
                  text: data.typeBody ?? '',
                  isBold: false,
                  textColor: Colors.grey.shade700,
                  hintColor: Colors.grey.shade700,
                ),
              ],
            ),
            Row(
              children: [
                expandedTextSpan(
                  hint: '仓库',
                  text: data.warehouse ?? '',
                  isBold: false,
                  textColor: Colors.grey.shade700,
                  hintColor: Colors.grey.shade700,
                ),
                expandedTextSpan(
                  hint: '合同日期：',
                  text: data.orderDate ?? '',
                  isBold: false,
                  textColor: Colors.grey.shade700,
                  hintColor: Colors.grey.shade700,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    factoryWarehouseController = LinkOptionsPickerController(
        PickerType.sapFactoryWarehouse,
        saveKey:
            '${RouteConfig.sapPrintPicking.name}${PickerType.sapFactoryWarehouse}',
        onSelected: (i1, i2) {
      state.warehouse = i2.pickerId();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithBottomSheet(
      bottomSheet: [
        EditText(hint: '通知单号', controller: noticeNoController),
        EditText(hint: '指令号', controller: instructionNoController),
        EditText(hint: '委外订单号', controller: purchaseOrderController),
        EditText(hint: '型体', controller: typeBodyController),
        EditText(hint: '领料员工号', controller: pickerController),
        Row(
          children: [
            Expanded(child: DatePicker(pickerController: dpcStartDate)),
            Expanded(child: DatePicker(pickerController: dpcEndDate)),
          ],
        ),
        Spinner(controller: spinnerControllerWorkShop),
        OptionsPicker(pickerController: supplierController),
        OptionsPicker(pickerController: workCenterController),
        LinkOptionsPicker(pickerController: factoryWarehouseController),
      ],
      query: _query,
      body: Obx(() => Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: state.pickOrderList.length,
                  itemBuilder: (c, i) => _item(state.pickOrderList[i]),
                ),
              ),
              if (state.pickOrderList.any((v) => v.select))
                SizedBox(
                  width: double.infinity,
                  child: CombinationButton(
                    text: '扫码拣货',
                    click: () => Get.to(
                      () => const SapPrintPickingDetailPage(),
                    ),
                  ),
                ),
            ],
          )),
    );
  }

  _query() {
    logic.queryOrder(
      instructionNo: instructionNoController.text,
      typeBody: typeBodyController.text,
      picker: pickerController.text,
      purchaseOrder: purchaseOrderController.text,
      supplier: supplierController.selectedId.value,
      noticeNo: noticeNoController.text,
      startDate: dpcStartDate.getDateFormatSapYMD(),
      endDate: dpcEndDate.getDateFormatSapYMD(),
      workCenter: workCenterController.selectedId.value,
      factory: factoryWarehouseController.getOptionsPicker1().pickerId(),
      warehouse: factoryWarehouseController.getOptionsPicker2().pickerId(),
      orderType: spinnerControllerWorkShop.selectIndex,
    );
  }

  @override
  void dispose() {
    Get.delete<SapPrintPickingLogic>();
    super.dispose();
  }
}
