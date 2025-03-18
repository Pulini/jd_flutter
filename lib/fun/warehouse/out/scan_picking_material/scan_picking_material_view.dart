import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/bar_code.dart';
import 'package:jd_flutter/fun/warehouse/out/scan_picking_material/scan_picking_material_dialog.dart';
import 'package:jd_flutter/widget/check_box_widget.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'scan_picking_material_logic.dart';
import 'scan_picking_material_state.dart';

class ScanPickingMaterialPage extends StatefulWidget {
  const ScanPickingMaterialPage({super.key});

  @override
  State<ScanPickingMaterialPage> createState() =>
      _ScanPickingMaterialPageState();
}

class _ScanPickingMaterialPageState extends State<ScanPickingMaterialPage> {
  final ScanPickingMaterialLogic logic = Get.put(ScanPickingMaterialLogic());
  final ScanPickingMaterialState state =
      Get.find<ScanPickingMaterialLogic>().state;
  var controller = TextEditingController();

  _item(BarCodeInfo item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.green.shade50],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        // color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: item.isUsed ? Colors.red : Colors.blue, width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: item.isUsed
                ? textSpan(
                    hint: '已提交：',
                    text: item.code ?? '',
                  )
                : Text(
                    item.code ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
          ),
          IconButton(
            onPressed: () => askDialog(
              content: '确定要删除该条码吗？',
              confirm: () => logic.deleteItem(item),
            ),
            icon: const Icon(
              Icons.delete_forever,
              color: Colors.red,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        Obx(() => CheckBox(
              onChanged: (c) => state.reverse.value = c,
              name: '红冲',
              value: state.reverse.value,
            ))
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(
                  top: 0,
                  bottom: 0,
                  left: 10,
                  right: 10,
                ),
                filled: true,
                fillColor: Colors.white54,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: Colors.transparent,
                  ),
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                hintText: '手动录入登记',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: IconButton(
                    onPressed: () => controller.clear(),
                    icon: const Icon(
                      Icons.replay_circle_filled,
                      color: Colors.red,
                    )),
                suffixIcon: IconButton(
                  onPressed: () {
                    var text = controller.text;
                    if (text.trim().isEmpty) {
                      showSnackBar(message: '请输入条码');
                    } else {
                      FocusScope.of(context).requestFocus(FocusNode());
                      logic.scanCode(text);
                    }
                  },
                  icon: const Icon(
                    Icons.loupe_rounded,
                    color: Colors.green,
                  ),
                ),
              ),
              onChanged: (search) {},
            ),
          ),
          Expanded(
            child: Obx(() => ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: state.barCodeList.length,
                  itemBuilder: (c, i) => _item(state.barCodeList[i]),
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Obx(() =>
                textSpan(hint: '已扫码：', text: '${state.barCodeList.length} 条')),
          ),
          Row(
            children: [
              Expanded(
                child: Obx(() => CombinationButton(
                      combination: Combination.left,
                      isEnabled: state.barCodeList.isNotEmpty,
                      text: '清空',
                      click: () => askDialog(
                        content: '确定要清空条码吗？',
                        confirm: () => logic.clearBarCodeList(),
                      ),
                    )),
              ),
              Expanded(
                child: Obx(() => CombinationButton(
                      combination: Combination.right,
                      isEnabled: state.barCodeList.isNotEmpty,
                      text: '提交',
                      click: () => checkBarCodeProcessDialog(
                        list: state.barCodeList,
                        submit: (w, p) => logic.submit(worker: w, process: p),
                      ),
                    )),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<ScanPickingMaterialLogic>();
    super.dispose();
  }
}
