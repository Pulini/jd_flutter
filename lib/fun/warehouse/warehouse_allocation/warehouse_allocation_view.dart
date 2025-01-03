import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/warehouse/warehouse_allocation/warehouse_allocation_logic.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import '../../../constant.dart';
import '../../../route.dart';
import '../../../widget/combination_button_widget.dart';
import '../../../widget/dialogs.dart';
import '../../../widget/edit_text_widget.dart';
import '../../../widget/picker/picker_controller.dart';
import '../../../widget/picker/picker_view.dart';

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
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: EditText(
                    hint: 'warehouse_allocation_input'.tr,
                    onChanged: (v) => state.code = v,
                  ),
                ),
                Expanded(
                    child: CombinationButton(
                  text: '手动添加',
                  click: () {
                    state.addCode(state.code);
                  },
                )),
                const SizedBox(width: 5),
              ],
            ),
          ),
          Expanded(
            flex: 18,
            child: Obx(
              () => ListView.builder(
                padding: const EdgeInsets.only(left: 5, right: 5),
                itemCount: state.dataList.length,
                itemBuilder: (context, index) => Container(
                  padding: const EdgeInsets.only(
                      left: 5, top: 3, right: 3, bottom: 3),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.blue, width: 1),
                      borderRadius: BorderRadius.circular(5)),
                  child: Text(
                    state.dataList[index].code.toString(),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(
              () => Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                ),
                child: Text(
                  '已扫描${state.dataList.length}条',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
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
          ),
          Expanded(
            flex: 2,
            child: Padding(
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
          ),
          Container(
            height: 40,
            width: double.maxFinite,
            margin: const EdgeInsets.all(10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.only(left: 8, right:20),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              onPressed: () {
                logic.goReport(
                  onStockId: onStockList.getOptionsPicker2().pickerId(),
                  outStockId: outStockList.getOptionsPicker2().pickerId(),
                );
              },
              child: const Text('提 交',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  _methodChannel() {
    debugPrint('注册监听');
    const MethodChannel(channelScanFlutterToAndroid)
        .setMethodCallHandler((call) {
      switch (call.method) {
        case 'PdaScanner':
          {
            state.addCode(call.arguments.toString());
          }
          break;
      }
      return Future.value(call);
    });
  }

  @override
  void initState() {
    _methodChannel();
    super.initState();

  }

  @override
  void dispose() {
    Get.delete<WarehouseAllocationLogic>();
    super.dispose();
  }
}
