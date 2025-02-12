import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/timely_inventory_show_info.dart';
import 'package:jd_flutter/fun/warehouse/timely_inventory/timely_inventory_logic.dart';
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

  _item(TimelyInventoryShowInfo data) {
    return InkWell(
      onTap: () => {
        reasonInputPopup(
          title: [
            const Center(
              child: Text(
                '库位',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            )
          ],
          hintText: '请输入新的库位',
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
                newLocation: s)
          },
        )
      },
      child: Container(
        height: 100,
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
                  hint: '物料名称：',
                  text: data.materialName.toString(),
                  textColor: Colors.blue,
                ),
                expandedTextSpan(
                  hint: '物料编码：',
                  text: data.materialNumber.toString(),
                  textColor: Colors.blue,
                ),
                expandedTextSpan(
                  hint: '工厂：',
                  text: data.factoryNumber.toString(),
                  textColor: Colors.blue,
                )
              ],
            ),
            Row(
              children: [
                expandedTextSpan(
                  hint: '基本数量：',
                  text: data.stockQty.toString() + data.unit.toString(),
                  textColor: Colors.grey,
                ),
                expandedTextSpan(
                  hint: '常用数量：',
                  text: data.stockQty1.toString() + data.unit1.toString(),
                  textColor: Colors.grey,
                ),
                expandedTextSpan(
                  hint: '批次：',
                  text: data.batch.toString(),
                  textColor: Colors.grey,
                ),
                expandedTextSpan(
                  hint: '货位：',
                  text: data.zlocal.toString(),
                  textColor: Colors.grey,
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      queryWidgets: [
        EditText(
          hint: '请输入指令号'.tr,
          onChanged: (v) => state.instructionNumber = v,
        ),
        const SizedBox(height: 10),
        EditText(
          hint: '请输入批次'.tr,
          onChanged: (v) => state.batch = v,
        ),
        const SizedBox(height: 10),
        EditText(
          hint: '请输入物料编码'.tr,
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
