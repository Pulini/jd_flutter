import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/timely_inventory_info.dart';
import 'package:jd_flutter/bean/http/response/timely_inventory_show_info.dart';
import 'package:jd_flutter/fun/warehouse/manage/timely_inventory/timely_inventory_logic.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';

class TimelyInventoryPage extends StatefulWidget {
  const TimelyInventoryPage({super.key});

  @override
  State<TimelyInventoryPage> createState() => _TimelyInventoryPageState();
}

class _TimelyInventoryPageState extends State<TimelyInventoryPage> {
  final logic = Get.put(TimelyInventoryLogic());
  final state = Get.find<TimelyInventoryLogic>().state;

  var factoryWarehouseController = LinkOptionsPickerController(
    PickerType.sapFactoryWarehouse,
    hasAll: true,
    saveKey:
        '${RouteConfig.timelyInventory.name}${PickerType.sapFactoryWarehouse}',
  );

  _item(TimelyInventoryInfo data) {
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5, bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              expandedTextSpan(
                hint: 'timely_inventory_material_name'.tr,
                text: data.materialName ?? '',
                textColor: Colors.blue,
              ),
              expandedTextSpan(
                hint: 'timely_inventory_material_code'.tr,
                text: data.materialNumber ?? '',
                textColor: Colors.blue,
              ),
              expandedTextSpan(
                hint: 'timely_inventory_factory'.tr,
                text: data.factoryNumber ?? '',
                textColor: Colors.blue,
              )
            ],
          ),
          for (var v in data.items!)
            InkWell(
              child: Row(
                children: [
                  expandedTextSpan(
                    hint: 'timely_inventory_basic_quantity'.tr,
                    text: v.stockQty ?? '${v.unit}' ?? '',
                    textColor: Colors.grey,
                  ),
                  expandedTextSpan(
                    hint: 'timely_inventory_common_quantity'.tr,
                    text: v.stockQty1 ?? '${v.unit1}' ?? '',
                    textColor: Colors.grey,
                  ),
                  expandedTextSpan(
                    hint: 'timely_inventory_batch'.tr,
                    text: v.batch ?? '',
                    textColor: Colors.grey,
                  ),
                  expandedTextSpan(
                    hint: 'timely_inventory_storage_location'.tr,
                    text: v.zlocal ?? '',
                    textColor: Colors.grey,
                  )
                ],
              ),
              onTap: () => {
                reasonInputPopup(
                  title: [
                    Center(
                      child: Text(
                        'timely_inventory_warehouse_location'.tr,
                        style:
                            const TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    )
                  ],
                  hintText: 'timely_inventory_new_warehouse_location'.tr,
                  isCanCancel: true,
                  confirm: (s) => {
                    Get.back(),
                    logic.modifyStorageLocation(
                        success: logic.getImmediateStockList(
                            factoryNumber: factoryWarehouseController
                                .getOptionsPicker1()
                                .pickerId(),
                            stockId: factoryWarehouseController
                                .getOptionsPicker2()
                                .pickerId()),
                        data: data,
                        item: v,
                        newLocation: s)
                  },
                )
              },
            )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      queryWidgets: [
        EditText(
          hint: 'timely_inventory_input_command'.tr,
          onChanged: (v) => state.instructionNumber = v,
        ),
        const SizedBox(height: 10),
        EditText(
          hint: 'timely_inventory_input_batch'.tr,
          onChanged: (v) => state.batch = v,
        ),
        const SizedBox(height: 10),
        EditText(
          hint: 'timely_inventory_input_material_code'.tr,
          onChanged: (v) => state.materialCode = v,
        ),
        LinkOptionsPicker(pickerController: factoryWarehouseController),
      ],
      query: () => logic.getImmediateStockList(
          factoryNumber:
              factoryWarehouseController.getOptionsPicker1().pickerId(),
          stockId: factoryWarehouseController.getOptionsPicker2().pickerId()),
      body: Obx(() => ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: state.dataList.length,
            itemBuilder: (BuildContext context, int index) =>
                _item(state.dataList[index]),
          )),
    );
  }
}
