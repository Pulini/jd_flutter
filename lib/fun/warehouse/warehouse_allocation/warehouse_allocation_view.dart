import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/warehouse/warehouse_allocation/warehouse_allocation_logic.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

import '../../../constant.dart';
import '../../../widget/combination_button_widget.dart';
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


  ///仓库
  var pcGroup = LinkOptionsPickerController(
    PickerType.sapFactoryWarehouse,
  );


  @override
  Widget build(BuildContext context) {
    return pageBody(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
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
          )),
          Expanded(
            flex: 16,
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
                        child: Text(state.dataList[index].code.toString()),
                      )),
            ),
          ),
           Expanded(child: Obx(()=>Padding( padding: const EdgeInsets.only(left: 10,),child: Text('已扫描${state.dataList.length}条',style: const TextStyle(color: Colors.red),),))),
          Expanded(
              child: Row(
            children: [
              Expanded(child:  LinkOptionsPicker(pickerController: pcGroup),),
              Expanded(child: CombinationButton(text: '报工', click: () => {})),
              Expanded(child: CombinationButton(text: '报工', click: () => {}))
            ],
          ))
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
