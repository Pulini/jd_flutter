import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/wait_picking_material_info.dart';
import 'package:jd_flutter/fun/warehouse/out/wait_picking_material/wait_picking_material_dialog.dart';
import 'package:jd_flutter/fun/warehouse/out/wait_picking_material/wait_picking_material_logic.dart';
import 'package:jd_flutter/fun/warehouse/out/wait_picking_material/wait_picking_material_state.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class WaitPickingMaterialDetailPage extends StatefulWidget {
  const WaitPickingMaterialDetailPage({super.key});

  @override
  State<WaitPickingMaterialDetailPage> createState() =>
      _WaitPickingMaterialDetailPageState();
}

class _WaitPickingMaterialDetailPageState
    extends State<WaitPickingMaterialDetailPage> {
  final WaitPickingMaterialLogic logic = Get.find<WaitPickingMaterialLogic>();
  final WaitPickingMaterialState state =
      Get.find<WaitPickingMaterialLogic>().state;

  _modifyQty({
    required List<WaitPickingMaterialOrderModelInfo> subItemList,
  }) {
    switch (state.detail.items?[0].msgType) {
      case '02':
      case '03':
      case '04':
      case '05':
        modifyDetailPickingQtyDialog(
          order: state.detail,
          data: subItemList,
        );
        break;
      default:
        msgDialog(content: state.detail.items?[0].msg);
        break;
    }
  }

  Widget _item(WaitPickingMaterialOrderSubInfo item) {
    return SizedBox(
      width: 120 * 11,
      child: Column(
        children: [
          Container(
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black54),
              color: Colors.yellow.shade100,
            ),
            child: Row(
              children: [
                const SizedBox(width: 20),
                textSpan(
                  hint: 'wait_picking_material_order_detail_instruction'.tr,
                  text: item.moNo ?? '',
                ),
                const SizedBox(width: 20),
                textSpan(
                  hint: 'wait_picking_material_order_detail_type_body'.tr,
                  text: item.models?[0].typeBody ?? '',
                ),
              ],
            ),
          ),
          for (WaitPickingMaterialOrderModelInfo sub in item.models ?? [])
            GestureDetector(
              onTap: () => _modifyQty(subItemList: [sub]),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black54),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Obx(() => Checkbox(
                          activeColor: Colors.blue,
                          side: const BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                          value: sub.isSelected.value,
                          onChanged: (v) {
                            sub.isSelected.value = !sub.isSelected.value;
                          },
                        )),
                    Expanded(
                      flex: 2,
                      child: Text(sub.size ?? ''),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(sub.batch ?? ''),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(sub.colorSystem ?? ''),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(sub.location ?? ''),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(sub.demandQuantity.toShowString()),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(sub.releaseQuantity.toShowString()),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(sub.unReleaseQuantity.toShowString()),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(sub.receivedQuantity.toShowString()),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(sub.releaseQuantity
                          .sub(sub.receivedQuantity ?? 0)
                          .toShowString()),
                    ),
                    Expanded(
                      flex: 3,
                      child:
                          Obx(() => Text(sub.pickingQty.value.toShowString())),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                          sub.workshopWarehousePickingQuantity.toShowString()),
                    ),
                    Expanded(
                      flex: 4,
                      child:
                          Text(sub.nowActIssuedCommonQuantity.toShowString()),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var list = logic.getDetailSelectedList();
    return pageBody(
      title:
          '(${state.detail.rawMaterialCode}) ${state.detail.rawMaterialDescription}',
      actions: [
        CombinationButton(
          text: 'wait_picking_material_order_detail_batch_set'.tr,
          click: () => _modifyQty(
            subItemList: logic.getDetailModifySelectedList(),
          ),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 120 * 11,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black54),
                  color: Colors.green.shade100,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      height: 40,
                      child: Obx(() => Checkbox(
                            activeColor: Colors.blue,
                            side: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                            value: logic.detailHasSelected(),
                            onChanged: (v) => logic.detailSelectAll(v!),
                          )),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'wait_picking_material_order_detail_size'.tr,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'wait_picking_material_order_detail_batch'.tr,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'wait_picking_material_order_detail_color_system'.tr,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'wait_picking_material_order_detail_location'.tr,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'wait_picking_material_order_detail_demand_qty'.tr,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'wait_picking_material_order_detail_release_qty'.tr,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'wait_picking_material_order_detail_un_release_qty'.tr,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'wait_picking_material_order_detail_received_qty'.tr,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'wait_picking_material_order_detail_un_received_qty'.tr,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'wait_picking_material_order_detail_picking_qty'.tr,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        'wait_picking_material_order_detail_workshop_warehouse_picking_qty'
                            .tr,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        'wait_picking_material_order_detail_this_issued_qty'.tr,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (c, i) => _item(list[i]),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
