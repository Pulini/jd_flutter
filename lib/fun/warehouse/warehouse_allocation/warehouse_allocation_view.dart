import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/warehouse/warehouse_allocation/warehouse_allocation_logic.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/scanner.dart';

class WarehouseAllocationPage extends StatefulWidget {
  const WarehouseAllocationPage({super.key});

  @override
  State<WarehouseAllocationPage> createState() =>
      _WarehouseAllocationPageState();
}

class _WarehouseAllocationPageState extends State<WarehouseAllocationPage> {
  final logic = Get.put(WarehouseAllocationLogic());
  final state = Get.find<WarehouseAllocationLogic>().state;

  ///出仓库
  var outStockList = LinkOptionsPickerController(
    PickerType.stockList,
    saveKey: '${RouteConfig.warehouseAllocation.name}${'outStockList'}',
  );

  ///入仓库
  var onStockList = LinkOptionsPickerController(
    PickerType.stockList,
    saveKey: '${RouteConfig.warehouseAllocation.name}${'onStockList'}',
  );

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 10, right: 30),
          child: InkWell(
            child: const Text('清空'),
            onTap: () => {
              askDialog(
                title: '温馨提示',
                content: '确定要清空条码吗?',
                confirm: () {
                  state.clearData();
                },
              ),
            },
          ),
        )
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: EditText(
                  hint: 'warehouse_allocation_input'.tr,
                  onChanged: (v) => state.code = v,
                ),
              ),
              CombinationButton(
                text: '手动添加',
                click: () {
                  state.addCode(state.code);
                },
              ),
            ],
          ),
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: const EdgeInsets.only(left: 5, right: 5),
                itemCount: state.dataList.length,
                itemBuilder: (context, index) => GestureDetector(
                    onLongPress:()=> logic.deleteCode(index),
                    child: Container(
                      padding: const EdgeInsets.only(
                          left: 5, top: 3, right: 3, bottom: 3),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.blue, width: 1),
                          borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        state.dataList[index].code.toString(),
                      ),
                    )),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 10,
            ),
            child: Obx(() => Text(
                  '已扫描${state.dataList.length}条',
                  style: const TextStyle(color: Colors.red),
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              children: [
                const Text('出仓库：'),
                Expanded(
                  child: LinkOptionsPicker(
                    pickerController: outStockList,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              children: [
                const Text('入仓库：'),
                Expanded(
                  child: LinkOptionsPicker(pickerController: onStockList),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: CombinationButton(
              text: '提交',
              click: () => logic.goReport(
                onStockId: onStockList.getOptionsPicker2().pickerId(),
                outStockId: outStockList.getOptionsPicker2().pickerId(),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    pdaScanner(
      scan: (code) => state.addCode(code),
    );
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<WarehouseAllocationLogic>();
    super.dispose();
  }
}
