import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/bar_code.dart';
import 'package:jd_flutter/fun/warehouse/out/production_scan_picking_material/production_scan_picking_material_dialog.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/check_box_widget.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/scanner.dart';

import 'production_scan_picking_material_logic.dart';
import 'production_scan_picking_material_state.dart';

class ProductionScanPickingMaterialPage extends StatefulWidget {
  const ProductionScanPickingMaterialPage({super.key});

  @override
  State<ProductionScanPickingMaterialPage> createState() =>
      _ProductionScanPickingMaterialPageState();
}

class _ProductionScanPickingMaterialPageState
    extends State<ProductionScanPickingMaterialPage> {
  final ProductionScanPickingMaterialLogic logic =
      Get.put(ProductionScanPickingMaterialLogic());
  final ProductionScanPickingMaterialState state =
      Get.find<ProductionScanPickingMaterialLogic>().state;
  var inputController = TextEditingController();
  var refreshController = EasyRefreshController(controlFinishRefresh: true);

  Container _item(BarCodeInfo item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            item.isUsed ? Colors.red.shade100 : Colors.blue.shade100,
            Colors.green.shade50
          ],
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
                    hint: 'production_scan_picking_material_submitted'.tr,
                    hintColor: Colors.red,
                    text: item.code ?? '',
                    textColor: Colors.grey,
                  )
                : Text(
                    item.code ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
          ),
          IconButton(
            onPressed: () => askDialog(
              content: 'production_scan_picking_material_delete_tips'.tr,
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
  void initState() {
    pdaScanner(scan: (code) => logic.scanCode(code));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshController.callRefresh();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        Obx(() => CheckBox(
              onChanged: (c) => state.reverse.value = c,
              name: 'production_scan_picking_material_reverse'.tr,
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
              controller: inputController,
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
                hintText: 'production_scan_picking_material_manual_input'.tr,
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: IconButton(
                    onPressed: () => inputController.clear(),
                    icon: const Icon(
                      Icons.replay_circle_filled,
                      color: Colors.red,
                    )),
                suffixIcon: IconButton(
                  onPressed: () {
                    var text = inputController.text;
                    if (text.trim().isEmpty) {
                      showSnackBar(
                          message:
                              'production_scan_picking_material_input_code'.tr);
                    } else {
                      hidKeyboard();
                      logic.scanCode(text);
                    }
                  },
                  icon: const Icon(
                    Icons.loupe_rounded,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(
              () => EasyRefresh(
                controller: refreshController,
                header: const MaterialHeader(),
                onRefresh: () => logic.refreshBarCodeStatus(
                  refresh: () => refreshController.finishRefresh(),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: state.barCodeList.length,
                  itemBuilder: (c, i) => _item(state.barCodeList[i]),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Obx(() => textSpan(
                  hint: 'production_scan_picking_material_scanned'.tr,
                  text: 'production_scan_picking_material_qty'.trArgs(
                    ['${state.barCodeList.length}'],
                  ),
                )),
          ),
          Row(
            children: [
              Expanded(
                child: Obx(() => CombinationButton(
                      combination: Combination.left,
                      isEnabled: state.barCodeList.isNotEmpty,
                      text: 'production_scan_picking_material_clear'.tr,
                      click: () => askDialog(
                        content:
                            'production_scan_picking_material_clear_tips'.tr,
                        confirm: () => logic.clearBarCodeList(),
                      ),
                    )),
              ),
              Expanded(
                child: Obx(() => CombinationButton(
                      combination: Combination.right,
                      isEnabled: state.barCodeList.isNotEmpty,
                      text: 'production_scan_picking_material_submit'.tr,
                      click: () => selectSupplierAndDepartmentDialog(
                        submit: (w, s, d) => logic.submit(
                          worker: w,
                          supplier: s,
                          department: d,
                        ),
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
    Get.delete<ProductionScanPickingMaterialLogic>();
    super.dispose();
  }
}
