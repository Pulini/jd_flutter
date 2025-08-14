import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_info.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_item.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/scanner.dart';

import 'print_pallet_logic.dart';
import 'print_pallet_state.dart';

class PrintPalletPage extends StatefulWidget {
  const PrintPalletPage({super.key});

  @override
  State<PrintPalletPage> createState() => _PrintPalletPageState();
}

class _PrintPalletPageState extends State<PrintPalletPage> {
  final PrintPalletLogic logic = Get.put(PrintPalletLogic());
  final PrintPalletState state = Get.find<PrintPalletLogic>().state;
  var controller = TextEditingController();
  late OptionsPickerController factoryController;

  _item(int index) {
    var pallet = state.palletList[index];
    var isSelected = state.selectedList[index];
    var materialList = groupBy(pallet, (v) => v.materialCode).values.toList();
    return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding:  EdgeInsetsGeometry.only(left: 10, right: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade200, Colors.blue.shade200],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Obx(() => Checkbox(
                      value: isSelected.value,
                      onChanged: (v) => isSelected.value = v!,
                    )),
                expandedTextSpan(
                  hint: '托盘号：',
                  text: pallet.first.palletNumber ?? '',
                ),
                IconButton(
                  onPressed: () => askDialog(
                      content: '确定要删除该托盘码？',
                      confirm: () => logic.deletePallet(index)),
                  icon: const Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            for (var item in materialList) _materialItem(item)
          ],
        ));
  }

  _materialItem(List<SapPalletDetailInfo> material) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blue,
          width: 2,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              expandedTextSpan(
                hint: '物料：',
                maxLines: 3,
                text:
                    '(${material.first.materialCode})${material.first.materialName}',
                textColor: Colors.green.shade700,
              ),
              textSpan(
                hint: '总数：',
                text:
                    '${material.map((v) => v.quantity ?? 0).reduce((a, b) => a.add(b)).toShowString()} ${material.first.unit}',
                textColor: Colors.green.shade700,
              ),
            ],
          ),
          for (var item in material) ...[
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('件号：${item.pieceNo}'),
                Text('数量：${item.quantity.toShowString()} ${item.unit}')
              ],
            )
          ]
        ],
      ),
    );
  }

  @override
  void initState() {
    factoryController = OptionsPickerController(
      PickerType.sapFactory,
      saveKey: '${RouteConfig.printPallet.name}${PickerType.sapFactory}',
      onSelected: (pi) {
        state.factory = (pi as PickerSapFactory).pickerId();
      },
    );
    pdaScanner(scan: (code) => logic.scanPallet(code));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        Obx(() => state.selectedList.any((v) => v.value)
            ? IconButton(
                onPressed: () => logic.printPallet(),
                icon: const Icon(
                  Icons.print,
                  color: Colors.blueAccent,
                ),
              )
            : Container())
      ],
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OptionsPicker(pickerController: factoryController),
              ),
              Container(
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsetsGeometry.only(left: 10, right: 10),
                height: 40,
                width: 230,
                child: Obx(() => TextField(
                      controller: controller,
                      onChanged: (v) => state.palletNo.value = v,
                      onSubmitted: (v) =>
                          logic.addPallet(() => controller.clear()),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(
                          top: 0,
                          bottom: 0,
                          left: 15,
                          right: 10,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade300,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                          ),
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        labelText: '输入托盘号',
                        prefixIcon: state.palletNo.value.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  controller.clear();
                                  state.palletNo.value = '';
                                },
                                icon: const Icon(
                                  Icons.replay_circle_filled,
                                  color: Colors.red,
                                ),
                              )
                            : null,
                        suffixIcon: state.palletNo.value.isNotEmpty
                            ? IconButton(
                                onPressed: () =>
                                    logic.addPallet(() => controller.clear()),
                                icon: const Icon(
                                  Icons.add_circle,
                                  color: Colors.blueAccent,
                                ),
                              )
                            : null,
                      ),
                    )),
              ),
            ],
          ),
          Expanded(
            child: Obx(() => ListView.builder(
                  padding: const EdgeInsetsGeometry.all(10),
                  itemCount: state.palletList.length,
                  itemBuilder: (c, i) => _item(i),
                )),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<PrintPalletLogic>();
    super.dispose();
  }
}
